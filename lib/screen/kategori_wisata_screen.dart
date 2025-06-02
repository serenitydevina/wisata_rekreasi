import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/models/kota.dart';
import 'package:wisata_rekreasi/models/wisata.dart';
import 'package:wisata_rekreasi/screen/add_post_wisata_screen.dart';
import 'package:wisata_rekreasi/screen/detail_screen.dart';

class KategoriWisataScreen extends StatefulWidget {
  final String role;
  final Kota kota;
  const KategoriWisataScreen({
    super.key,
    required this.kota,
    required this.role,
  });

  @override
  State<KategoriWisataScreen> createState() => _KategoriWisataScreenState();
}

class _KategoriWisataScreenState extends State<KategoriWisataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(widget.kota.nama),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('kotas')
                .doc(widget.kota.id)
                .collection('wisatas')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Data Kosong',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          }

          final wisataList =
              snapshot.data!.docs
                  .map((doc) {
                    try {
                      final data = doc.data() as Map<String, dynamic>;

                      // Handle createdAt dengan null safety
                      DateTime createdAt;
                      if (data['createdAt'] is Timestamp) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                        createdAt =
                            DateTime.tryParse(data['createdAt']) ??
                            DateTime.now();
                      } else {
                        createdAt = DateTime.now();
                      }

                      return Wisata(
                        id: doc.id,
                        nama: data['nama'] ?? 'Nama tidak tersedia',
                        latitude: (data['latitude'] ?? 0.0).toDouble(),
                        longitude: (data['longitude'] ?? 0.0).toDouble(),
                        deskripsi:
                            data['deskripsi'] ?? 'Deskripsi tidak tersedia',
                        gambarUrl: data['gambarUrl'] ?? '',
                        jamBuka: data['jamBuka'] ?? '00:00',
                        jamTutup: data['jamTutup'] ?? '23:59',
                        kotaId: data['kotaId'] ?? widget.kota.id,
                        alamat: data['alamat'] ?? 'Alamat tidak tersedia',
                        createdAt: createdAt,
                      );
                    } catch (e) {
                      // Log error untuk debugging
                      print('Error parsing wisata document ${doc.id}: $e');
                      print('Document data: ${doc.data()}');
                      return null;
                    }
                  })
                  .where((wisata) => wisata != null)
                  .cast<Wisata>()
                  .toList();

          if (wisataList.isEmpty) {
            return Center(
              child: Text(
                'Data Kosong atau Bermasalah',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: wisataList.length,
            itemBuilder: (context, index) {
              final place = wisataList[index];
              return Card(
                color: Theme.of(context).cardColor,
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(
                    place.nama,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    place.alamat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing:
                      place.gambarUrl.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 80,
                              height: 80,
                              child: _buildImage(place.gambarUrl),
                            ),
                          )
                          : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[600],
                              size: 40,
                            ),
                          ),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(wisata: place),
                        ),
                      ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          widget.role == 'admin'
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => AddPostWisataScreen(kota: widget.kota),
                    ),
                  );
                },
                backgroundColor: const Color.fromRGBO(141, 153, 174, 1),
                foregroundColor: Colors.white,
                shape: CircleBorder(),
                child: const Icon(Icons.add, size: 50),
              )
              : null,
    );
  }

  Widget _buildImage(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
      );
    }
  }
}
