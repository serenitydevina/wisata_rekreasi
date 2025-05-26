import 'package:flutter/material.dart';
import 'package:wisata_rekreasi/screen/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
   final _emailController = TextEditingController();
   final _passwordController = TextEditingController();
   bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
       child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              child:Image.asset(
                'assets/location.png',
                width: 150,
                height: 150
              ),
            ),
            const SizedBox(
              height: 16,
              ),
            const Text(
              'Login',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(padding: const EdgeInsets.all(5.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: "Masukkan Email",
                    ),
                  )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _passwordController,
                       decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            hintText: "Masukkan password",
                             suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                          ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                             
                            },
                            child: const Text('Login'))
                ]
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                 RichText(text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: const TextStyle(
                    color: Colors.black
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      ), 
                       recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                    )
                  ]
                 ),
                 ),
                ],
              ),
            ),
            )
          ],
        ),
       ) ,
      )
      );
  }
}