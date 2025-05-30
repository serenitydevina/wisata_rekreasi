import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    //ClipOval(
                      Image.asset(
                        'assets/location.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain
                    ),
                   // ),
                    // Align(
                    // alignment: Alignment.bottomRight,
                    // child: CircleAvatar(
                    //   child: Icon(Icons.edit),
                    // ),
                    // ), 
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 25,
                        child: Icon(Icons.edit),
                      ),
                    ) 
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
                           labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                      focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                         ),
                       ),
                       const SizedBox(
                         height: 16,
                       ),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.end,
                         children: [
                           ElevatedButton(
                             onPressed:(){},
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