import 'dart:async';

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Menu extends StatefulWidget {
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late String email='' ;
List<String> _imageUrls = [];
  Uint8List? _selectedImageBytes;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
   List<int> numbers = [];

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
        _imageUrls.add( downloadUrl);
      });

      await _updateUser();
      print('Image uploaded successfully. URL: $_imageUrls');
    } catch (e) {
      print('Error uploading image: $e');
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
          'menuImages': _imageUrls,
          
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
  @override
Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'];
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      title: const Text('Home Page'),
    ),
   
   
    body: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            const BoxShadow(color: Colors.white),
          ],
        ),
        child: SizedBox(
     
          child: Card(
            color: const Color.fromARGB(255, 5, 61, 107),
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
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, 
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        _imageUrls[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              Padding(padding: const EdgeInsets.all(10),
              child: ElevatedButton(onPressed:(){
                 Navigator.pushNamed(context, '/morePictures',
                         arguments: {
                'email': email,
              
              });
              }
              ,style: ElevatedButton.styleFrom(backgroundColor:  const Color.fromARGB(255, 255, 206, 59)),
              child: const Text('Add Restaurant Pictures',style: TextStyle(color: Color.fromARGB(255, 5, 61, 107)
              ),
              ),
              )
              ,),

Padding(padding: const EdgeInsets.all(10),
              child: ElevatedButton(onPressed:(){
                 Navigator.pushNamed(context, '/addAddress',
                         arguments: {
                'email': email,
              
              });
              }
              ,style: ElevatedButton.styleFrom(backgroundColor:  const Color.fromARGB(255, 255, 206, 59)),
              child: const Text('Add Address and Capacity',style: TextStyle(color: Color.fromARGB(255, 5, 61, 107)
              ),
              ),
              )
              ,)

              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}