class Wisata {
  final String id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final String gambarUrl;
  final String jamBuka;
  final String jamTutup;
  final String kotaId; 

  Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.gambarUrl,
    required this.jamBuka,
    required this.jamTutup,
    required this.kotaId, 
  });

  factory Wisata.fromMap(String id, Map<dynamic, dynamic> map) {
    return Wisata(
      id: id,
      nama: map['nama'] ?? '',
      lokasi: map['lokasi'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      jamBuka: map['jamBuka'] ?? '',
      jamTutup: map['jamTutup'] ?? '',
      kotaId: map['kotaId'] ?? '', 
    );
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
