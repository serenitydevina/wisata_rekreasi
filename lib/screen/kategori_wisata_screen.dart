import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/models/kota.dart';

class KategoriWisataScreen extends StatefulWidget {
  final Kota kota;
  const KategoriWisataScreen({super.key, required this.kota});

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
      // body: StreamBuilder(
      //   stream: FirebaseFirestore.instance.collection('kotas').doc(widget.kota.id).collection('wisatas').snapshots(), 
      //   builder: (context, snapshot) {
      //     if(snapshot.hasError) return Text('Error: ${snapshot.error}');
      //     if (!snapshot.hasData) return CircularProgressIndicator();
      //   }),
    );
  }
}