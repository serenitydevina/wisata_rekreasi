import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advance_slider/AdvanceSlider.dart';
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
  bool _isLoading= false;
   final TextEditingController _ulasanController = TextEditingController();


void initState() {
    super.initState();
    loadUserData();
  }
  Future<void> loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
       appBar: AppBar(
        leading: IconButton(
          onPressed: (){
          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          Navigator.pop(context);
          }, 
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
          title: Text('Beri Ulasan',style: Theme.of(context).textTheme.bodyLarge,),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: 
                 ClipOval(
                      child: 
                    _image != null ?
                      Image.file(
                        _image!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover
                      )
                      :
                      Image.asset(
                        'assets/location.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain
                    ),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16 ,),
              Text("Rating: $rating"),
              FlutterAdvanceSlider(
                min: 0, 
                max: 5,
                displayDivders: true,
                showLable: true,
                activeTrackColor: Color.fromRGBO(141, 153, 174, 1),
                 onChanged: (rating) {
                    setState(() {
                      this.rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 16,),
                 TextField(
              controller: _ulasanController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Masukkan Ulasan Anda",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25,),
            _isLoading ? CircularProgressIndicator() :
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                      minimumSize: Size(double.infinity, 48),
                    ),
              child: const Text('Simpan', style: TextStyle(color: Colors.white),),
              onPressed: () async {
                await FirebaseFirestore.instance .collection('kotas')
  .doc(widget.wisata.kotaId).collection('wisatas').doc(widget.wisata.id).collection('ulasans').add({
                  'name': name,
                  'rating': rating,
                  'ulasan': _ulasanController.text,
                });
                Navigator.pop(context);
              },
            )
            ],
          ),
        ),
      );

  }
}