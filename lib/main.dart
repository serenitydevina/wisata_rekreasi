import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';
import 'package:wisata_rekreasi/screen/register_screen.dart';
import 'package:wisata_rekreasi/screen/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
     title: 'Wisata Rekreasi',
      home: 
      // SplashScreen(),
       LoginScreen(),
      // RegisterScreen(),
    );
  }
}
