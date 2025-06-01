// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';

// class AddPostWisataScreen extends StatefulWidget {
//   const AddPostWisataScreen({super.key});

//   @override
//   State<AddPostWisataScreen> createState() => _AddPostWisataScreenState();
// }

// class _AddPostWisataScreenState extends State<AddPostWisataScreen> {
//   File? _image;
//   String? _base64Image;
//   final TextEditingController _namawisataController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   TimeOfDay jamBuka = TimeOfDay.now();
//   TimeOfDay jamTutup = TimeOfDay.now();
//   bool _isUploading = false;
//   double? _latitude;
//   double? _longitude;

//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await _picker.pickImage(source: source);
//     if(pickedFile !=null){
//       setState((){
//         _image = File(pickedFile.path);
//       });
//       await _compressAndEncodeImage();
//     }
//   }

//   Future<void> _compressAndEncodeImage() async {
//     if(_image == null) return;
//     final compressedImage = await FlutterImageCompress.compressWithFile(
//       _image!.path,
//       quality: 50,
//     );
//     if(compressedImage == null) return;
//     setState(() {
//       _base64Image = base64Encode(compressedImage);
//     });
//   }

//   Future<void> _getLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//   }
//   permission = await Geolocator.checkPermission();
//   if(permission == LocationPermission.denied){
//     permission = await Geolocator.requestPermission();
//     if(permission == LocationPermission.deniedForever|| permission == LocationPermission.denied){
//       throw Exception('Location permissions are denied.');
//       }
//     }

//     try{
//       final position = await Geolocator.getCurrentPosition(
//         locationSettings: LocationSettings(accuracy: LocationAccuracy.high)
//       ).timeout(const Duration(seconds: 10));
//       setState(() {
//         _latitude = position.latitude;
//         _longitude = position.longitude;
//       });
//     } catch(e){
//       debugPrint('Failed to retrieve location: $e');
//       setState(() {
//         _latitude = null;
//         _longitude = null;
//       });
//     }
//   }

//   Future<void> _submitPost() async {
//     if(_base64Image == null|| _descriptionController.text.isEmpty) return;

//     setState(() => _isUploading = true);
//     final now = DateTime.now().toIso8601String();
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if(uid == null){
//       setState(() => _isUploading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('User not found.')),
//       );
//       return;
//     }

//     try{
//       await _getLocation();

//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
//       final fullname = userDoc.data()?['fullname'] ?? 'Anonymous';
//       await FirebaseFirestore.instance.collection('posts_wisata').add({
//         'image':_base64Image,
//         'description':_descriptionController.text,
//         'createdAt': now,
//         'latitude': _latitude,
//         'longitude': _longitude,
//         'fullname':fullname,
//         'userId': uid,
//       });
//       if(!mounted)return;
//       Navigator.pop(context);
//   }catch(e){}
//   }

//   void _showImageSourceDialog() {
//     showDialog(
//       context: context, 
//       builder: (context) =>AlertDialog(
//         backgroundColor:  Color.fromRGBO(141, 153, 174, 1),
//         title: Text('Choose Image Source', style: TextStyle(color: Colors.white),
//         ),
//         actions : [
//           TextButton(
//             onPressed: (){
//               Navigator.pop(context);
//               _pickImage(ImageSource.camera);
//             } ,
//             child: Text('Camera', style: TextStyle(color: Colors.white)),
//           ),
//           TextButton(
//             onPressed: (){
//               Navigator.pop(context);
//               _pickImage(ImageSource.gallery);
//             },
//             child: Text('Gallery', style: TextStyle(color: Colors.white)),
            
//           ),
//         ],
//       ), 
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: 
//         AppBar(
//           leading: IconButton(
//             onPressed: (){
//               Navigator.pop(context);
//             }, 
//           icon: Icon(Icons.arrow_back)
//           ),
//           title: Text('Tambah Wisata'),
//         ),
//         body:SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//              Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: Colors.grey,
//                 ),
//               alignment: Alignment.center,
//               child: _image == null
//               ? Text('No image selected')
//               : Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover,),
//              ),
//              const SizedBox(height: 16.0),
//              ElevatedButton.icon(
//               onPressed: _showImageSourceDialog,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromRGBO(141, 153, 174, 1),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)
//                 ),
//                 iconSize: 24,
//                 iconColor: Colors.white,
//                 foregroundColor: Colors.white,
//                 textStyle: TextStyle(
//                 //color: Colors.white,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 ),
//               ), 
//               icon: Icon(Icons.file_upload_outlined),
//               label: const Text('Upload Foto'),
//               ),
//               TextField()
//             ],
            
//             ),
//         ) ,
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wisata_rekreasi/models/kota.dart';

class AddPostWisataScreen extends StatefulWidget {
  final Kota kota;
  const AddPostWisataScreen({super.key, required this.kota});
  @override
  _AddPostWisataScreenState createState() => _AddPostWisataScreenState();
}

class _AddPostWisataScreenState extends State<AddPostWisataScreen> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  TimeOfDay _jamBuka = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _jamTutup = TimeOfDay(hour: 19, minute: 0);

  File? _image;
  bool _isLoading = false;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _jamBuka : _jamTutup,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _jamBuka = picked;
        } else {
          _jamTutup = picked;
        }
      });
    }
  }

  TimeOfDay parseTimeOfDay(String timeString) {
  final format = DateFormat.Hm(); // atau DateFormat("hh:mm a");
  final dateTime = format.parse(timeString);
  return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
}


  // Future<void> _submitData() async {
  //   if (_image == null ||
  //       _namaController.text.isEmpty ||
  //       _deskripsiController.text.isEmpty ||
  //       _latitudeController.text.isEmpty ||
  //       _longitudeController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Semua field wajib diisi')),
  //     );
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final bytes = await _image!.readAsBytes();
  //     final base64Image = base64Encode(bytes);

  //     final newData = {
  //       'nama': _namaController.text,
  //       'deskripsi': _deskripsiController.text,
  //       'jam_buka': _jamBuka.format(context),
  //       'jam_tutup': _jamTutup.format(context),
  //       'latitude': _latitudeController.text,
  //       'longitude': _longitudeController.text,
  //       'gambar': base64Image,
  //       'created_at': Timestamp.now(),
  //     };

  //     await FirebaseFirestore.instance.collection("wisata").add(newData);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Wisata berhasil ditambahkan')),
  //     );
  //     Navigator.pop(context);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Gagal menyimpan data: $e')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _submitData() async {
    if (_image == null ||
        _namaController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User tidak ditemukan')),
        );
        return;
      }

      // Ambil lokasi user jika pakai lokasi dinamis (jika tidak bisa dihapus)
      // await _getLocation(); // Uncomment jika butuh ambil lokasi otomatis

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final fullname = userDoc.data()?['fullname'] ?? 'Anonymous';

      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

     final newData = {
  'gambarUrl': base64Image,                     
  'nama': _namaController.text,
  'deskripsi': _deskripsiController.text,       
  'jamBuka':
   _jamBuka.format(context),  
  // parseTimeOfDay(_jamBuka.format(context)).format(context),       
  'jamTutup': 
   _jamTutup.format(context),  
  // parseTimeOfDay(_jamTutup.format(context)).format(context),      
  'latitude':  double.parse(_latitudeController.text),
  'longitude':  double.parse(_longitudeController.text),
  'createdAt': DateTime.now().toIso8601String(),
  'fullname': fullname,
  'userId': uid,
  'kotaId': widget.kota.id,
};

      await FirebaseFirestore.instance
  .collection('kotas')
  .doc(widget.kota.id)
  .collection('wisatas')
  .add(newData);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTimeButton(TimeOfDay time, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
      child: Text(DateFormat.jm().format(
        DateTime(0, 0, 0, time.hour, time.minute),
      ),
      style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Tambah Wisata",  style: Theme.of(context).textTheme.bodyLarge ,),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey,
              child: _image != null
                  ? Image.file(_image!, fit: BoxFit.cover)
                  : Center(child: Text("No image selected")),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload, color: Colors.white,),
              label: Text("Upload Foto", style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(141, 153, 174, 1),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Nama Wisata",
                labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1)),
               focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "Deskripsi",
                focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: [
                Text("Jam Buka: "),
                _buildTimeButton(_jamBuka, () => _pickTime(true),),
                SizedBox(width: 16),
                Text("Jam Tutup: "),
                _buildTimeButton(_jamTutup, () => _pickTime(false)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Lintang",
                       labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1)),
                      prefixIcon: Icon(Icons.location_on),
                     focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Bujur",
                       labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1)),
                      prefixIcon: Icon(Icons.location_on),
                     focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(141, 153, 174, 1),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("Simpan", style: TextStyle(color: Colors.white,),),
                  ),
          ],
        ),
      ),
    );
  }
}