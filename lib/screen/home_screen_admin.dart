import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/screen/add_post_screen.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';

class HomeScreenAdmin extends StatelessWidget {
  const HomeScreenAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const  EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/location.png',
                    width: 80,
                    height: 80,
                  ),
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
                        IconButton(
                        onPressed: () => signOut(context), 
                        icon: const Icon(Icons.logout),
                        ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10,),
              const Divider(),
              const SizedBox(height: 5),
              Padding(padding: const EdgeInsets.symmetric(horizontal:0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddPostScreen()));
        },
        backgroundColor: const Color.fromRGBO(141, 153, 174, 1),
        foregroundColor: Colors.white,
       shape: CircleBorder(),
        child: const Icon(Icons.add, size: 50,),
      ),
    );
  }
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Hapus semua route sebelumnya
    );
  }
}