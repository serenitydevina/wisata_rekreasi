import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/firebase_options.dart';
import 'package:wisata_rekreasi/screen/home_screen_admin.dart';
import 'package:wisata_rekreasi/screen/home_screen_user%20copy.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';
import 'package:wisata_rekreasi/screen/register_screen.dart';
import 'package:wisata_rekreasi/screen/splash_screen.dart';
import 'package:wisata_rekreasi/screen/favorite_screen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     title: 'Wisata Rekreasi',
      home: 
      SplashScreen(),
      //  LoginScreen(),
      // RegisterScreen(),
      // FavoriteScreen(),
      // initialRoute: '/',
      routes: {
        // '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user': (context) =>HomeScreenUser(),
        '/admin': (context) =>HomeScreenAdmin(),
      },
    );
  }
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    //if (role == 'admin') HomeScreenAdmin() else HomeScreenUser(),
  ];
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
