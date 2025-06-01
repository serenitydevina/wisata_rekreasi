import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/models/wisata.dart';

class DetailScreen extends StatefulWidget {
  final Wisata wisata;
  const DetailScreen({super.key, required this.wisata});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final docId = '${user!.uid}_${widget.wisata.id}';
    final doc = await FirebaseFirestore.instance.collection('favorites').doc(docId).get();
    setState(() {
      isFavorited = doc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    final favRef = FirebaseFirestore.instance
        .collection('favorites')
        .doc('${user!.uid}_${widget.wisata.id}');

    if (isFavorited) {
      await favRef.delete();
    } else {
      await favRef.set({
        'userId': user!.uid,
        'wisataId': widget.wisata.id,
        'nama': widget.wisata.nama,
        'gambarUrl': widget.wisata.gambarUrl,
        'deskripsi': widget.wisata.deskripsi,
        'jamBuka': widget.wisata.jamBuka,
        'jamTutup': widget.wisata.jamTutup,
      });
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.wisata.nama, style: Theme.of(context).textTheme.bodyLarge ,),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(widget.wisata.gambarUrl),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.wisata.deskripsi),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 4),
              Text('${widget.wisata.jamBuka} - ${widget.wisata.jamTutup}')
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.map),
              SizedBox(width: 4),
              Text("Maps")
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.star),
              SizedBox(width: 4),
              Text("4.4")
            ],
          ),
          const SizedBox(height: 16),
          const Text("Ulasan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("serenity devina", style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text("5")
                  ],
                ),
                SizedBox(height: 4),
                Text("Wisatanya Menarik! Balas")
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF97AABF),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text("Tambah Ulasan", style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}
