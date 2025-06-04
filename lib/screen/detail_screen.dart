// detail_screen.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisata_rekreasi/models/wisata.dart';
import 'package:wisata_rekreasi/screen/beri_ulasan_screen.dart';
import 'package:wisata_rekreasi/screen/full_image%20screen.dart';

class DetailScreen extends StatefulWidget {
  final Wisata wisata;
  const DetailScreen({super.key, required this.wisata});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isFavorited = false;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _calculateAverageRating();
  }

  Future<void> _checkIfFavorited() async {
    final docId = '${user!.uid}_${widget.wisata.id}';
    final doc =
        await FirebaseFirestore.instance
            .collection('favorites')
            .doc(docId)
            .get();
    setState(() {
      isFavorited = doc.exists;
    });
  }

  Future<void> openMap() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${widget.wisata.latitude},${widget.wisata.longitude}',
    );
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
      );
    }
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
        'latitude': widget.wisata.latitude,
        'longitude': widget.wisata.longitude,
        'alamat': widget.wisata.alamat,
        'kotaId': widget.wisata.kotaId,
        'createdAt': widget.wisata.createdAt.toIso8601String(),
      });
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  Future<void> _calculateAverageRating() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('kotas')
            .doc(widget.wisata.kotaId)
            .collection('wisatas')
            .doc(widget.wisata.id)
            .collection('ulasans')
            .get();

    if (snapshot.docs.isNotEmpty) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }
      setState(() {
        averageRating = total / snapshot.docs.length;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.wisata.nama,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
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
          GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(widget.wisata.gambarUrl),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FullscreenImageScreen(
                      imageBase64: widget.wisata.gambarUrl,
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text("Deskripsi", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(widget.wisata.deskripsi),
          const SizedBox(height: 16),

          // Jam Operasional
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jam Operasional",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${widget.wisata.jamBuka} - ${widget.wisata.jamTutup}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alamat",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      widget.wisata.alamat ?? 'Alamat tidak tersedia',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rating",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      averageRating > 0
                          ? averageRating.toStringAsFixed(1)
                          : "Belum ada rating",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Lihat di Maps
          ElevatedButton.icon(
            onPressed: () {
              openMap();
            },
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text(
              "Lihat di Maps",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Ulasan",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection("kotas")
                    .doc(widget.wisata.kotaId)
                    .collection('wisatas')
                    .doc(widget.wisata.id)
                    .collection('ulasans')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'Belum ada ulasan untuk wisata ini.\nJadilah yang pertama memberikan ulasan!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['name'] ?? 'Anonymous',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < (data['rating'] ?? 0)
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['ulasan'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (data['createdAt'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            data['createdAt'],
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BeriUlasanScreen(wisata: widget.wisata),
                ),
              ).then((_){
                _calculateAverageRating();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF97AABF),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              "Tambah Ulasan",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
