import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Wisata {
  final String id;
  final String nama;
  // final String lokasi;
  final double latitude;
  final double longitude;
  final String deskripsi;
  final String gambarUrl;
  final TimeOfDay jamBuka;
  final TimeOfDay jamTutup;
  final String kotaId; 
  final DateTime createdAt;

  Wisata({
    required this.id,
    required this.nama,
    // required this.lokasi,
    required this.latitude,
    required this.longitude,
    required this.deskripsi,
    required this.gambarUrl,
    required this.jamBuka,
    required this.jamTutup,
    required this.kotaId, 
    required this.createdAt
  });

  factory Wisata.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    TimeOfDay parseTime(String timestr){
       final parts = timestr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
    return Wisata(
      id: doc.id,
      nama: data['nama'] ?? '',
      // lokasi: map['lokasi'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      deskripsi: data['deskripsi'] ?? '',
      gambarUrl: data['gambarUrl'] ?? '',
      jamBuka:  parseTime(data['jamBuka']),
      jamTutup: parseTime(data['jamTutup']),
      kotaId: data['kotaId'] ?? '', 
       createdAt: DateTime.parse(data['createdAt']),
    );
  }
  String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

  // Map<String, dynamic> toMap() {
  //   return {
  //     'nama': nama,
  //     'lokasi': lokasi,
  //     'deskripsi': deskripsi,
  //     'gambarUrl': gambarUrl,
  //     'jamBuka': jamBuka,
  //     'jamTutup': jamTutup,
  //     'kotaId': kotaId, 
  //   };
  // }
}
