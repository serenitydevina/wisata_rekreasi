import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/models/kota.dart';
import 'package:wisata_rekreasi/models/wisata.dart';
import 'package:wisata_rekreasi/screen/add_post_wisata_screen.dart';

class KategoriWisataScreen extends StatefulWidget {
   final String role;
  final Kota kota;
  const KategoriWisataScreen({super.key, required this.kota, required this.role});

  @override
  State<KategoriWisataScreen> createState() => _KategoriWisataScreenState();
}

class _KategoriWisataScreenState extends State<KategoriWisataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(207, 224, 195, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(widget.kota.nama),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('kotas').doc(widget.kota.id).collection('wisatas').snapshots(), 
        builder: (context, snapshot) {
          // if(snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (!snapshot.hasData) return CircularProgressIndicator();
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty) 
          return const Text('Data Kosong', style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,);
          final wisata = snapshot.data!.docs.map((doc){
            final data = doc.data() as Map<String, dynamic>;
          DateTime createdAt;
                        if (data['createdAt'] is Timestamp) {
                  createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                       createdAt = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
                  } else {
                    createdAt = DateTime.now();
                          }
          return Wisata(
            id: doc.id,
            nama : data['nama'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            deskripsi: data['deskripsi'],
            gambarUrl: data['gambarUrl'],
            jamBuka: data['jamBuka'],
            jamTutup: data['jamTutup'],
            kotaId: data['kotaId'],
            createdAt: createdAt,
          );
          }).toList();
           return ListView.builder(
            
            itemCount: wisata.length,
            itemBuilder: (context, index) {
             final place = wisata[index];
             ListTile(
              title: Text(place.nama),
              subtitle: Image.memory(
                 base64Decode(place.gambarUrl),
                 fit: BoxFit.cover,
                 height: 120,
                 ),
             );
        },
        );
          // final wisata = snapshot.data!.docs.map((doc) => Wisata.fromDocument(doc)).toList();
          // return ListView.builder(
          //   itemCount: wisata.length,
          //   itemBuilder: (context, index) => 
          //   ListTile(
          //     title: Text(wisata[index].nama),
          //     subtitle: Image.memory(
          //       base64Decode(wisata[index].gambarUrl),
          //       fit: BoxFit.cover,
          //       height: 120,
          //       ),
          //   ),
          // );
        }),
       floatingActionButton: widget.role == 'admin'?
       FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddPostWisataScreen()));
        },
        backgroundColor: const Color.fromRGBO(141, 153, 174, 1),
        foregroundColor: Colors.white,
       shape: CircleBorder(),
        child: const Icon(Icons.add, size: 50,),
      ) :null
    );
  }
}