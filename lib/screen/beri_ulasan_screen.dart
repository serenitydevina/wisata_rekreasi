import 'package:flutter/material.dart';

class BeriUlasanScreen extends StatefulWidget {
  const BeriUlasanScreen({super.key});

  @override
  State<BeriUlasanScreen> createState() => _BeriUlasanScreenState();
}

class _BeriUlasanScreenState extends State<BeriUlasanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          onPressed: (){
          //  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
          Navigator.pop(context);
          }, 
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          )),
          title: Text('Beri Ulasan'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 50.0),
                alignment: Alignment.center,
                child: const Image(
                    image: AssetImage('assets/location.png'), 
                    width: 200, 
                    height: 200,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}