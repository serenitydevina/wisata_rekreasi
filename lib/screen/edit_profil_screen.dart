import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wisata_rekreasi/screen/profile_screen.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _base64Image;

  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _compressAndEncodeImage();
    }
  }

  Future<void> _compressAndEncodeImage() async {
    if (_image == null) return;
    final compressedImage = await FlutterImageCompress.compressWithFile(
      _image!.path,
      quality: 50,
    );
    if (compressedImage == null) return;
    setState(() {
      _base64Image = base64Encode(compressedImage);
    });
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

    final data = doc.data();
    if (data != null) {
      _nameController.text = data['fullname'] ?? 'Anonim';
    }
    final prefs = await SharedPreferences.getInstance();
    final gambar = prefs.getString('profile_image_$uid');
    if (gambar != null) {
      setState(() {
        _image = File(gambar);
      });
    }
  }

  Future<void> _saveName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newName = _nameController.text.trim();

    if (newName.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fullname': newName,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nama berhasil disimpan")));

      // Arahkan ke halaman profil utama
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
      // );
    }
  }

  Future<void> _saveProfileImagePath(String path) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_$uid', path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
        ),
        title: Text('Edit Profil'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child:
                // const CircleAvatar(
                //   radius: 100,
                //   backgroundImage: AssetImage('assets/location.png'),
                //   child: Align(
                //     alignment: Alignment.bottomRight,
                //     child: CircleAvatar(
                //       child: Icon(Icons.edit),
                //     ),
                //   ),
                // ),
                Stack(
                  alignment: Alignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
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
                    // Align(
                    // alignment: Alignment.bottomRight,
                    // child: CircleAvatar(
                    //   child: Icon(Icons.edit),
                    // ),
                    // ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: CircleAvatar(
                          radius: 25,
                          child: Icon(
                            Icons.edit,
                            color: Color.fromRGBO(141, 153, 174, 1),
                          ),
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Edit Nama',
                          hintText: "Masukkan nama",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _nameController.text = '';
                              });
                            },
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(73, 69, 79, 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(121, 116, 126, 1.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              //  _saveName();
                              //  _saveProfileImagePath(_image!.path);
                              await _saveName();
                              if (_image != null) {
                                await _saveProfileImagePath(_image!.path);
                              }
                              Navigator.pop(context, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
