import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_16/User/Add_Info.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _imageUrl='https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg';

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
        phoneController.text.trim(),
        _imageUrl
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => addInfo(),
          settings: RouteSettings(
            arguments: {
              'email': emailController.text.trim(),
              'password': passwordController.text.trim(),
              'name': nameController.text.trim(),
              'phone': phoneController.text.trim(),
              'Image':_imageUrl
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

  Future<void> addUsersDetails(
      String name, String email, String password, String phoneNumber,String _imageUrl) async {
    await FirebaseFirestore.instance.collection('Users').add({
      'Name': name,
      'Email': email,
      'Password': password,
      'Phone_no': phoneNumber,
        'Image':_imageUrl,
      'Role':'User'
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      
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
                          hintText: 'Name',
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
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: phoneController,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
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
