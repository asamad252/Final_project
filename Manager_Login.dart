import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_16/Manager/Manager_HomePage.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class managerLogin extends StatefulWidget {
  @override
  State<managerLogin> createState() => _MLoginState();
}

class _MLoginState extends State<managerLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


Future<bool> checkRole() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = firestore.collection('Restaurants');

    QuerySnapshot querySnapshot = await users.where('Email', isEqualTo: usernameController.text.trim()).get();

    return querySnapshot.size > 0;
  }
  userLogin() async {
    String email = usernameController.text.trim();
    String password = passwordController.text.trim();

    try {
      bool roleCheck = await checkRole();
      if (roleCheck) {
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => managerHomePage(),
            settings: RouteSettings(
              arguments: {
                'email': email,
                'password': password,
                
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Access Denied",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  _signinWithGoogle() async {
    final GoogleSignIn _googleSignin = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignin.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await
        googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        showToast(message: 'Signed in with Google successfully');
      }
    } catch (e) {
      showToast(message: 'Error signing in with Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login/Signup",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 206, 59),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 5, 61, 107),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 5, 61, 107),
                  Color.fromARGB(255, 255, 206, 59),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 120,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    Center(child: Container(height: 20)),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: passwordController,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      obscureText: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              userLogin();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 5, 61, 107),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 206, 59),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/managerSignup');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 5, 61, 107),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 206, 59),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                    label: const Text(
                      'Google Sign in',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      print('Google Sign-In Pressed');
                      _signinWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
