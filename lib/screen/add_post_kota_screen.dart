import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class AddPostKotaScreen extends StatefulWidget {
  const AddPostKotaScreen({super.key});

  @override
  State<AddPostKotaScreen> createState() => _AddPostKotaScreenState();
}

class _AddPostKotaScreenState extends State<AddPostKotaScreen> {
   File? _image;
  String? _base64Image;
  final TextEditingController _namaKotaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
   bool _isUploading = false;

   Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if(pickedFile !=null){
      setState((){
        _image = File(pickedFile.path);
      });
      await _compressAndEncodeImage();
    }
  }

  Future<void> _compressAndEncodeImage() async {
    if(_image == null) return;
    final compressedImage = await FlutterImageCompress.compressWithFile(
      _image!.path,
      quality: 50,
    );
    if(compressedImage == null) return;
    setState(() {
      _base64Image = base64Encode(compressedImage);
    });
  }

  Future<void> _submitPost() async {
    if(_base64Image == null|| _namaKotaController.text.isEmpty) return;

    setState(() => _isUploading = true);
    final now = DateTime.now().toIso8601String();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if(uid == null){
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User not found.')),
      );
      return;
    }

    try{

      //final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      //final fullname = userDoc.data()?['fullname'] ?? 'Anonymous';
      await FirebaseFirestore.instance.collection('posts_kota').add({
        'image':_base64Image,
        'name':_namaKotaController.text,
        'createdAt': now,
        'userId': uid,
      });
      if(!mounted)return;
      Navigator.pop(context);
  }catch(e){}
  }

   void _showImageSourceDialog() {
    showDialog(
      context: context, 
      builder: (context) =>AlertDialog(
        backgroundColor:  Color.fromRGBO(141, 153, 174, 1),
        title: Text('Choose Image Source', style: TextStyle(color: Colors.white),
        ),
        actions : [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            } ,
            child: Text('Camera',style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery',style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
        AppBar(
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
          icon: Icon(Icons.arrow_back)
          ),
          title: Text('Tambah Kota'),
        ),
        body:SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
             Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey,
                ),
              alignment: Alignment.center,
              child: _image == null
              ? Text('No image selected')
              : Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover,),
             ),
             const SizedBox(height: 16.0),
             ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)
                ),
                iconSize: 24,
                iconColor: Colors.white,
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                //color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                ),
              ), 
              icon: Icon(Icons.file_upload_outlined),
              label: const Text('Upload Foto'),
              ),
             const SizedBox(height: 16.0),
             TextFormField(
              controller: _namaKotaController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nama Kota',
                      hintText: "Masukkan Nama Kota",
                      labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                      focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                    ),
                 validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Silahkan Masukkan Nama Kota';
                            }
                            return null;
                          },
             ),
             const SizedBox(height: 16.0),
             ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)
                ),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                ),
              ), 
              child: const Text('Submit'),
             )
            ],
            
            ),
        ) ,
    );

  }
}