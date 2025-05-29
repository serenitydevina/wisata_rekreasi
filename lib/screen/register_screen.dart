import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:wisata_rekreasi/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullnameController = TextEditingController();
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
                child: Image.asset(
                'assets/location.png',
                width: 150,
                height: 150
              ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Register',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _fullnameController, 
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nama',
                            hintText: "Masukkan Nama",
                            labelStyle: const TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Silahkan Masukkan Nama anda';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: "Masukkan Email",
                            labelStyle: const TextStyle(color: Color.fromRGBO(73, 69, 79, 1.0)),
                             focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(121, 116, 126, 1.0)
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || !value.contains('@')) {
                              return 'Silahkan Masukkan Email anda';
                            }
                            return null;
                          },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
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
                            if (value == null || value.isEmpty || _isValidEmail(value)) {
                              return 'Silahkan Masukkan Password anda';
                            }if(value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                            _isLoading ? const CircularProgressIndicator() :
                          ElevatedButton(
                            onPressed: () {
                             _register();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Color.fromRGBO(141, 153, 174, 1.0),
                             foregroundColor: Colors.white
                            ),
                             child: const Text('Save'),
                             

                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: const TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                               recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _register() async {
     if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() => _isLoading = true);
    try{
      final UserCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final role = email.endsWith('@admin.com') ? 'admin' : 'user';
    await FirebaseFirestore.instance.collection('users').doc(UserCredential.user!.uid).set({ 
      'fullname': _fullnameController.text.trim(),
      'email': email,
      'role': role,
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    //Navigator.pushReplacementNamed(context, role == 'admin' ? '/admin' : '/user');
    }on FirebaseAuthException catch(error){
      _showErrorMessage(_getAuthErrorMessage(error.code));
    }catch(error){
      _showErrorMessage('An error occurred: $error',);
    }finally{
      setState(() => _isLoading = false);
    }
  }
  void _showErrorMessage(String message) {
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
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

