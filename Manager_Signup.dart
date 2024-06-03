import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_16/Manager/Manager_Add_Info.dart';

class managerSignup extends StatefulWidget {
  @override
  State<managerSignup> createState() => _managerSignupState();
}

class _managerSignupState extends State<managerSignup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  

  registration() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        ),
      ));

      await addUsersDetails(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>managerSignup(),
          settings: RouteSettings(
            arguments: {
              'email': emailController.text.trim(),
              'password': passwordController.text.trim(),
              'name': nameController.text.trim(),
              
            },
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Password Provided is too Weak",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Account Already exists",
            style: TextStyle(fontSize: 18.0),
          ),
        ));
      }
    }
  }

  Future<void> addUsersDetails(String name, String email, String password) async {
    await FirebaseFirestore.instance.collection('Restaurants').add({
      'Name': name,
      'Email': email,
      'Password': password,
      'Role':'Manager'
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope( onWillPop: () async {
      
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Signup",
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
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Restaurant Name',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      Center(child: Container(height: 20)),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        obscureText: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(height: 20),
                      ),
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
                      const Padding(padding: EdgeInsets.all(10)),
                      const Padding(padding: EdgeInsets.all(10)),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: registration,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
