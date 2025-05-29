import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/screen/detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> cities = [
      {'name': 'Lampung', 'imagePath': 'assets/Lampung.jpg'},
      {'name': 'Bogor', 'imagePath': 'assets/Bogor.jpg'},
      {'name': 'Bandung', 'imagePath': 'assets/Bandung.jpg'},
      {'name': 'Yogyakarta', 'imagePath': 'assets/Jogja.jpg'},
      {'name': 'Jakarta', 'imagePath': 'assets/Jakarta.jpg'},
      {'name': 'Denpasar', 'imagePath': 'assets/Denpasar.jpg'},
    ];
    return Scaffold(
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
                      const Text(
                        'Hi!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Kota mana yang ingin dikunjungi?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      //untuk sementara
                      // IconButton(
                      //   onPressed: () => signOut(context),
                      //   icon: const Icon(Icons.logout),
                      //   ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                   
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return GestureDetector(
                      //onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(city: city))),
                      child: SizedBox(
                        width: 175,
                        height: 175,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 154.41,
                                height: 110.63,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Image.asset(
                                    city['imagePath']!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      city['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> signOut(BuildContext context) async {
  //   await FirebaseAuth.instance.signOut();
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     (route) => false, // Hapus semua route sebelumnya
  //   );
  // }
}
