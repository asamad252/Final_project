import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_16/Manager/Manager_Add_Info.dart';
import 'package:image_picker_web/image_picker_web.dart';

class managerHomePage extends StatefulWidget {
  const managerHomePage({Key? key}) : super(key: key);

  @override
  State<managerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<managerHomePage> {
  late String email;
  String _imageUrl = '';
  Uint8List? _selectedImageBytes;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEditing = false;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    try {
      var mediaData = await ImagePickerWeb.getImageInfo;
      if (mediaData != null) {
        setState(() {
          _selectedImageBytes = mediaData.data!;
        });
        _uploadImage(_selectedImageBytes!, mediaData.fileName!);
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes, String fileName) async {
    try {
      print('Starting image upload...');
      Reference storageRef = _storage.ref().child('user_images/$fileName');

      UploadTask uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = downloadUrl;
      });

      await _updateUser();
      print('Image uploaded successfully. URL: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<String?> getNameByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Restaurants')
          .where('Email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var document = querySnapshot.docs.first;
        var data = document.data() as Map<String, dynamic>;
        return data['Name'].toString();
      } else {
        print('No restaurant found with email: $email');
        return null;
      }
    } catch (e) {
      print('Error retrieving name: $e');
      return null;
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isSaving = true;
    });

    try {
      CollectionReference users = _firestore.collection('Restaurants');
      QuerySnapshot querySnapshot =
          await users.where('Email', isEqualTo: email).get();

      if (querySnapshot.size > 0) {
        var document = querySnapshot.docs.first;
        await document.reference.set({
          'Image': _imageUrl,
        }, SetOptions(merge: true));
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        print('Image URL updated successfully in Firestore.');
      } else {
        print('No user found with email: $email');
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      print('Error updating Firestore: $e');
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments =
        ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 206, 59),
        title: const Text('Home Page'),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 5, 61, 107),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 5, 61, 107),
                ),
                child: FutureBuilder<String?>(
                  future: getNameByEmail(email),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 206, 59),
                          fontSize: 24,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return Text(
                        snapshot.data ?? 'No Name Found',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 206, 59),
                          fontSize: 24,
                        ),
                      );
                    } else {
                      return const Text(
                        'No Name Found',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 206, 59),
                          fontSize: 24,
                        ),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_circle,
                  color: Color.fromARGB(255, 255, 206, 59),
                ),
                title: const Text(
                  'Account Info',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 206, 59),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const managerAddInfo(),
                      settings: RouteSettings(
                        arguments: {
                          'email': email.trim(),
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Color.fromARGB(255, 255, 206, 59),
                ),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 206, 59),
                  ),
                ),
                onTap: () async {
                Navigator.pushNamed(context,'/mLogin');
                },
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 12.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(color: Colors.white),
            ],
          ),
          child: SizedBox(
            height: 350,
            width: 450,
            child: Card(
              color: const Color.fromARGB(255, 5, 61,
107),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo),
                    color: const Color.fromARGB(255, 255, 206, 59),
                    iconSize: 50,
                  ),
                  if (_isSaving) const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl: _imageUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/menu',
                              arguments: {
                                'email': email,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 206, 59),
                          ),
                          child: const Text(
                            'Add Menu',
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 61, 107),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/viewReservations',
                              arguments: {
                                'email': email,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 206, 59),
                          ),
                          child: const Text(
                            'View Reservations',
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 61, 107),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
