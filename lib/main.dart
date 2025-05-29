import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/firebase_options.dart';
import 'package:wisata_rekreasi/screen/add_post_screen.dart';
import 'package:wisata_rekreasi/screen/home_screen.dart';
// import 'package:wisata_rekreasi/screen/home_screen_admin.dart';
// import 'package:wisata_rekreasi/screen/home_screen_user.dart';
// import 'package:wisata_rekreasi/screen/home_screen_user.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';
import 'package:wisata_rekreasi/screen/profile_screen.dart';
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
      initialRoute: '/',
      routes: {
         '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user': (context) =>const MainScreen(role: 'user',),
        '/admin': (context) =>const MainScreen(role: 'admin',),
        //'/user': (context) =>HomeScreenUser(),
        //'/admin': (context) =>HomeScreenAdmin(),
      },
    );
  }
}
class MainScreen extends StatefulWidget {
  final String role; 
  const MainScreen({super.key, required this.role});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  late List<Widget> _screens = [
    //widget.role == 'admin' ? HomeScreenAdmin() : HomeScreenUser(),
    HomeScreen(role: widget.role,),
    FavoriteScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items:  [
          _buildBottomNavigationBarItem(
            icon: Icons.home,
            label: 'Home',
            isSelected: _currentIndex == 0,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.favorite,
            label: 'Favorite',
            isSelected: _currentIndex == 1,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.person,
            label: 'Account',
            isSelected: _currentIndex == 2,
          ),
        ],
        backgroundColor: const Color.fromRGBO(207, 224, 195, 1),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
       floatingActionButton: widget.role == 'admin' && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddPostScreen()));
              },
              child: const Icon(Icons.add, size: 50),
               backgroundColor: const Color.fromRGBO(141, 153, 174, 1),
          foregroundColor: Colors.white,
       shape: CircleBorder(),
            )
          : null,
    );
  }
  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          if (isSelected)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(202, 240, 248, 1) // Lingkaran saat terpilih
              ),
            ),
          Icon(icon),
        ],
      ),
      label: label,
    );
}
  }
