import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _image;
  String? _base64Image;
  final TextEditingController _namawisataController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _isUploading = false;
  double? _latitude;
  double? _longitude;

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

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if(permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.deniedForever|| permission == LocationPermission.denied){
      throw Exception('Location permissions are denied.');
      }
    }

    try{
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
      ).timeout(const Duration(seconds: 10));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch(e){
      debugPrint('Failed to retrieve location: $e');
      setState(() {
        _latitude = null;
        _longitude = null;
      });
    }
  }

  Future<void> _submitPost() async {
    if(_base64Image == null|| _descriptionController.text.isEmpty) return;

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
      await _getLocation();

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullname = userDoc.data()?['fullname'] ?? 'Anonymous';
      await FirebaseFirestore.instance.collection('posts').add({
        'image':_base64Image,
        'description':_descriptionController.text,
        'createdAt': now,
        'latitude': _latitude,
        'longitude': _longitude,
        'fullname':fullname,
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
        title: Text('Choose Image Source'),
        actions : [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            } ,
            child: Text('Camera'),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery'),
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
          title: Text('Tambah Wisata'),
        ),
        body:SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
             Container(
              alignment: Alignment.center,
              child: _image == null
              ? Text('No image selected')
              : Image.file(_image!),
             ),
             ElevatedButton.icon(
              onPressed: _showImageSourceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)
                ),
                iconColor: Colors.white,
                textStyle: TextStyle(
                color: Colors.white,
                ),
              ), 
              icon: Icon(Icons.file_upload_outlined),
              label: const Text('Upload Foto'),
              ),
            ],
            ),
        ) ,
    );
  }
}