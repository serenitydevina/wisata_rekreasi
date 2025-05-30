import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/models/wisata.dart';

class DetailScreen extends StatelessWidget {
  final Wisata wisata;
  const DetailScreen({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: Text(wisata.nama),
        backgroundColor: const Color(0xFFD9E5D6),
        actions: const [
          Icon(Icons.favorite_border),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              wisata.gambarUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(wisata.deskripsi),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 4),
              Text('${wisata.jamBuka} - ${wisata.jamTutup}')
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
              color: Colors.white,
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
            child: const Text("Tambah Ulasan"),
          )
        ],
      ),
    );
  }
}