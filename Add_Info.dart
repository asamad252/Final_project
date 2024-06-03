import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';

class addInfo extends StatefulWidget {
  const addInfo({Key? key}) : super(key: key);

  @override
  State<addInfo> createState() => _AddInfoState();
}

class _AddInfoState extends State<addInfo> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email = '';
  String _imageUrl = '';
  Uint8List? _selectedImageBytes;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

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

      print('Image uploaded successfully. URL: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _isSaving = true;
    });

    try {
      CollectionReference users = _firestore.collection('Users');
      QuerySnapshot querySnapshot = await users.where('Email', isEqualTo: email).get();

      if (querySnapshot.size > 0) {
        var document = querySnapshot.docs.first;
        await document.reference.update({
          'Image': _imageUrl,
          'Phone_no': _phoneNumberController.text,
          'Name': _nameController.text,
          'Password': _passwordController.text,
        });
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        print('User info updated successfully in Firestore.');
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
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      appBar: AppBar(
        title: const Text("Edit Info"),
        backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Users').where('Email', isEqualTo: email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final doc = snapshot.data!.docs.first;
            _phoneNumberController.text = doc['Phone_no'];
            _nameController.text = doc['Name'];
            _passwordController.text = doc['Password'];
            _imageUrl = doc['Image'];
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey,
                        backgroundImage: _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (_imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null) as ImageProvider?,
                        child: _selectedImageBytes == null && _imageUrl.isEmpty
                            ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _phoneNumberController,
                    readOnly: !_isEditing,
                    decoration: const InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(color: Color.fromARGB(40, 72, 71, 71)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: TextEditingController(text: email),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      enabled: false,
                      hintStyle: TextStyle(color: Color.fromARGB(40, 72, 71, 71)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _nameController,
                    readOnly: !_isEditing,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                      hintStyle: TextStyle(color: Color.fromARGB(40, 72, 71, 71)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _passwordController,
                    obscureText: true,
                    readOnly: !_isEditing,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Color.fromARGB(40, 72, 71, 71)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isSaving
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isEditing ? _updateUser : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 5, 61, 107),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 206, 59),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 5, 61, 107),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 206, 59),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
