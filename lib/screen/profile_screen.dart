import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_rekreasi/main.dart';
import 'package:wisata_rekreasi/screen/edit_profil_screen.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';
import 'package:provider/provider.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String name = '';
  String email = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['fullname'] ?? 'Anonim';
          email = data['email'] ?? 'Tidak ada email';
        });
      }
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_${user!.uid}');
        if (imagePath != null) {
          setState(() {
              _image = File(imagePath);
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 ClipOval(
                      child: 
                    _image != null ?
                      Image.file(
                        _image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover
                      )
                      :
                      Image.asset(
                        'assets/location.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain
                    ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama',
                          // style: TextStyle(
                          //   fontSize: 14,
                          //   fontWeight: FontWeight.w500,
                          style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: 
                          // const TextStyle(
                          //   fontSize: 16,
                          // ),
                          Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email',
                          style: 
                          // TextStyle(
                          //   fontSize: 14,
                          //   fontWeight: FontWeight.w500,
                          // ),
                         Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: 
                          // const TextStyle(
                          //   fontSize: 16,
                          // ),
                          Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const SizedBox(height: 5),
              ListTile(
                leading: 
                // const Icon(Icons.dark_mode_outlined),
                Icon(
              Theme.of(context).brightness == Brightness.dark
               ? Icons.light_mode_outlined
               : Icons.dark_mode_outlined,
                  ),
                title: Text(
                // const Text('Dark Mode'),
                Theme.of(context).brightness == Brightness.dark
                ? 'Light Mode'
                : 'Dark Mode',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                   Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
                },
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 5),
               ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profil'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EditProfilScreen()));
                  final result = await Navigator.push(
                  context,
                   MaterialPageRoute(builder: (context) => const EditProfilScreen()),
                    );
                    if (result == true) {
                     await loadUserData(); // refresh nama dan foto setelah kembali
                     }
                },
              ),
             
            ],
          ),
        ),
      ),
    );
  }
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
