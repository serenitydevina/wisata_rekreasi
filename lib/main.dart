import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisata_rekreasi/firebase_options.dart';
import 'package:wisata_rekreasi/screen/add_post_kota_screen.dart';
import 'package:wisata_rekreasi/screen/add_post_wisata_screen.dart';
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
  runApp(ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MainApp()
      )
      );
}
class ThemeNotifier extends ChangeNotifier{
    ThemeMode _themeMode = ThemeMode.system;
    ThemeMode get themeMode => _themeMode;
    ThemeNotifier() {
    _loadThemeMode();
  }
  void _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = 
     _themeMode == ThemeMode.dark;  
    // prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('isDarkMode', !isDark);
    notifyListeners();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color.fromRGBO(237, 242, 244, 1.0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(207, 224, 195, 1),
          foregroundColor: Colors.black,
          ),
          cardColor:Colors.white,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16),
            bodySmall: TextStyle(color: Colors.black,fontWeight: FontWeight.w500, fontSize: 14),
            headlineSmall: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(207, 224, 195, 1),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            ),  
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color.fromRGBO( 1,42,74, 1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(112,151,117, 1),
          foregroundColor: Colors.white,
          ),
          cardColor: Color.fromRGBO(1,79,134, 1),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
             bodySmall: TextStyle(color: Colors.white,fontWeight: FontWeight.w500, fontSize: 14),
              headlineSmall: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(112,151,117, 1),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            ),
        ),
      themeMode: themeNotifier.themeMode,
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
            context: context,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.favorite,
            label: 'Favorite',
            isSelected: _currentIndex == 1,
            context: context,
          ),
          _buildBottomNavigationBarItem(
            icon: Icons.person,
            label: 'Account',
            isSelected: _currentIndex == 2,
            context: context,
          ),
        ],
        backgroundColor: 
        // const Color.fromRGBO(207, 224, 195, 1),
        Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
        //  Colors.black,
        Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: 
        // Colors.grey,
        Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      ),
       floatingActionButton: widget.role == 'admin' && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddPostKotaScreen()));
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
    required BuildContext context,
  }) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color:
                //  Color.fromRGBO(202, 240, 248, 1) // Lingkaran saat terpilih
                isDark ? Color.fromRGBO(42,111,151 , 1) : Color.fromRGBO(202, 240, 248, 1),
              ),
            ),
          Icon(icon),
        ],
      ),
      label: label,
    );
}
  }
