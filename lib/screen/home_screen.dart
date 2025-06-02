import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:wisata_rekreasi/screen/detail_screen.dart';
import 'package:wisata_rekreasi/screen/kategori_wisata_screen.dart';
import 'package:wisata_rekreasi/models/kota.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final List<Map<String, String>> cities = [
    //   {'name': 'Lampung', 'imagePath': 'assets/Lampung.jpg'},
    //   {'name': 'Bogor', 'imagePath': 'assets/Bogor.jpg'},
    //   {'name': 'Bandung', 'imagePath': 'assets/Bandung.jpg'},
    //   {'name': 'Yogyakarta', 'imagePath': 'assets/Jogja.jpg'},
    //   {'name': 'Jakarta', 'imagePath': 'assets/Jakarta.jpg'},
    //   {'name': 'Denpasar', 'imagePath': 'assets/Denpasar.jpg'},
    // ];
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/location.png', width: 80, height: 80),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi!',
                        style:
                            // TextStyle(
                            //   fontSize: 12,
                            //   fontWeight: FontWeight.w500,
                            // ),
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Kota mana yang ingin dikunjungi?',
                        style:
                            // TextStyle(
                            //   fontSize: 12,
                            //   fontWeight: FontWeight.w500,
                            // ),
                            Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.logout),
                  //   onPressed: () => signOut(context),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 5),
              StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('kotas')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  // final kota = snapshot.data!.docs.map(
                  //   (doc) {
                  //     final data = doc.data() as Map<String, dynamic>;
                  //     return {
                  //      ' nama': data['nama'],
                  //       'gambarUrl': data['gambarUrl'],
                  //     };
                  //   }).toList();
                  // final kota =
                  // snapshot.data!.docs.where((doc){
                  //   final data = doc.data();
                  // }).toList();
                  final kota =
                      snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
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
                        return Kota(
                          id: doc.id,
                          nama: data['nama'],
                          gambarUrl: data['gambarUrl'],
                          createdAt: createdAt,
                        );
                      }).toList();
                  return GridView.builder(
                    itemCount: kota.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final city = kota[index];
                      //final city = kota[index];
                      // final imageBase64 = data['gambarUrl'];
                      // final nama = data['nama'];
                      // final createdAtStr = data['createdAt'];
                      // final createdAt = DateTime.parse(createdAtStr);
                      String heroTag =
                          'wisata-image-${city.createdAt.millisecondsSinceEpoch}';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => KategoriWisataScreen(
                                    kota: city,
                                    role: widget.role,
                                  ),
                            ),
                          );
                        },
                        child: SizedBox(
                          // width: 175,
                          // height: 175,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Theme.of(context).cardColor,
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  //borderRadius: BorderRadius.circular(10),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Hero(
                                    tag: heroTag,
                                    child: Image.memory(
                                      base64Decode(city.gambarUrl),
                                      fit: BoxFit.cover,
                                      height: 120,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        city.nama,
                                        style:
                                            //    const TextStyle(
                                            //     fontSize: 16,
                                            //     fontWeight: FontWeight.bold,
                                            //  ),
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 0),
              //   child: GridView.builder(
              //     shrinkWrap: true,
              //     physics: const NeverScrollableScrollPhysics(),
              //     itemCount: cities.length,
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 2,
              //       crossAxisSpacing: 10,
              //       mainAxisSpacing: 10,

              //     ),
              //     itemBuilder: (context, index) {
              //       final city = cities[index];
              //       return GestureDetector(
              //         //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(city: city))),
              //         child: SizedBox(
              //           width: 175,
              //           height: 175,
              //           child: Card(
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(10),
              //             ),
              //             elevation: 3,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.stretch,
              //               children: [
              //                 SizedBox(
              //                   width: 154.41,
              //                   height: 110.63,
              //                   child: ClipRRect(
              //                     borderRadius: const BorderRadius.vertical(
              //                       top: Radius.circular(10),
              //                     ),
              //                     child: Image.asset(
              //                       city['imagePath']!,
              //                       fit: BoxFit.cover,
              //                     ),
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.all(8.0),
              //                   child: Row(
              //                     mainAxisAlignment:
              //                         MainAxisAlignment.spaceBetween,
              //                     children: [
              //                       Text(
              //                         city['name']!,
              //                         style: const TextStyle(
              //                           fontSize: 16,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
