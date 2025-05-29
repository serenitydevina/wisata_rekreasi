import 'package:cloud_firestore/cloud_firestore.dart';
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
    final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
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
              key: _formKey,
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
                      labelStyle: TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                      focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                    ),
                     validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !_isValidEmail(value)) {
                        return 'Masukkan email yang sesuai';
                      }
                      return null;
                    },
                  )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      controller: _passwordController,
                       obscureText: !_isPasswordVisible,
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
                       labelStyle: const TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                        focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                          ),
                            validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silahkan masukkan password anda';
                      }
                      return null;
                    },
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
                             _login();
                            },
                             style: ElevatedButton.styleFrom(
                              backgroundColor:Color.fromRGBO(141, 153, 174, 1.0),
                             foregroundColor: Colors.white
                            ),
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
  void _login() async{
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() => _isLoading = true);
    try{
      final UserCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      final doc = await FirebaseFirestore.instance.collection('users').doc(UserCredential.user!.uid).get();
      final role = doc['role'];
      if(role == 'admin'){
        Navigator.pushReplacementNamed(context, '/admin');
      }else{
        Navigator.pushReplacementNamed(context, '/user');
      }
    }on FirebaseAuthException catch (error) {
      _showSnackBar(_getAuthErrorMessage(error.code));
    } catch (error) {
      _showSnackBar('An error occurred: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }
    void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isValidEmail(String email) {
    String emailRegex =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zAZ0-9-]+)*$";
    return RegExp(emailRegex).hasMatch(email);
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with that email';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}