import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_rekreasi/models/wisata.dart';

class BeriUlasanScreen extends StatefulWidget {
  final Wisata wisata;
  const BeriUlasanScreen({super.key, required this.wisata});

  @override
  State<BeriUlasanScreen> createState() => _BeriUlasanScreenState();
}

class _BeriUlasanScreenState extends State<BeriUlasanScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String name = '';
  File? _image;
  double rating = 0.0;
  bool _isLoading = false;
  final TextEditingController _ulasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['fullname'] ?? 'Anonim';
        });
      }
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${user!.uid}');
      if (imagePath != null) {
        setState(() {
          _image = File(imagePath);
        });
      }
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              rating = index + 1.0;
            });
          },
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color:
                index < rating
                    ? Colors.amber
                    : Color.fromRGBO(141, 153, 174, 1),
            size: 40.0,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        title: Text(
          'Beri Ulasan',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: ClipOval(
                  child:
                      _image != null
                          ? Image.file(
                            _image!,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            'assets/location.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                ),
              ),
              const SizedBox(height: 16),
              Text(name, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Text(
                "Berikan Rating:",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              _buildStarRating(),
              const SizedBox(height: 8),
              Text(
                "${rating.toInt()} dari 5 bintang",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ulasanController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Masukkan Ulasan Anda",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(121, 116, 126, 1.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Silakan berikan rating terlebih dahulu',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (_ulasanController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Silakan tulis ulasan Anda'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        await FirebaseFirestore.instance
                            .collection('kotas')
                            .doc(widget.wisata.kotaId)
                            .collection('wisatas')
                            .doc(widget.wisata.id)
                            .collection('ulasans')
                            .add({
                              'name': name,
                              'rating': rating,
                              'ulasan': _ulasanController.text,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menyimpan ulasan. Coba lagi.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
