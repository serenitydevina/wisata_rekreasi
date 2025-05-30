import 'package:cloud_firestore/cloud_firestore.dart';

class Kota {
  final String id;
  final String nama;
  final String gambarUrl;
  final DateTime createdAt;

  Kota({required this.id, required this.nama, required this.gambarUrl, required this.createdAt});

  // factory Kota.fromdoc(Map data, String id) {
  //   return Kota(
  //     id: id,
  //     nama: data['nama']??'',
  //     gambarUrl: data['gambarUrl']??'',
  //   );
  // }
  factory Kota.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Kota(
      id: doc.id,
      nama: data['name'] ?? '',
      gambarUrl: data['imageUrl'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  // Map<String, dynamic> toMap() {
  //  return {
  // 'nama': nama,
  // 'gambarUrl': gambarUrl,
  //  };
  // }
}