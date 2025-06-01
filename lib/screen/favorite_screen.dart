import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wisata_rekreasi/models/wisata.dart';
import 'package:wisata_rekreasi/screen/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Favorite', style: Theme.of(context).textTheme.bodyLarge),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteDocs = snapshot.data!.docs;

          if (favoriteDocs.isEmpty) {
            return const Center(child: Text('Belum ada wisata favorit.'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: favoriteDocs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 12,
                childAspectRatio: 1, // Biar tidak memanjang
              ),
              itemBuilder: (context, index) {
                final doc = favoriteDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final imageBase64 = data['gambarUrl'];
                final bytes = base64Decode(imageBase64);

                return InkWell(
                  onTap: () {
                    final wisata = Wisata(
                      id: data['wisataId'],
                      nama: data['nama'] ?? '',
                      latitude:
                          double.tryParse(data['latitude'].toString()) ?? 0.0,
                      longitude:
                          double.tryParse(data['longitude'].toString()) ?? 0.0,
                      deskripsi: data['deskripsi'] ?? '',
                      gambarUrl: data['gambarUrl'] ?? '',
                      jamBuka: data['jamBuka'] ?? '',
                      jamTutup: data['jamTutup'] ?? '',
                      kotaId: data['kotaId'] ?? '',
                      createdAt:
                          DateTime.tryParse(data['createdAt'].toString()) ??
                              DateTime.now(),
                      isFavorite: true,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(wisata: wisata),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.memory(
                            bytes,
                            height: 115, // Ukuran gambar tetap
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['nama'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('favorites')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
