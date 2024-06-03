import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class managerAddInfo extends StatefulWidget {
  const managerAddInfo({Key? key}) : super(key: key);

  @override
  State<managerAddInfo> createState() => _MAddInfoState();
}

class _MAddInfoState extends State<managerAddInfo> {
 
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _email = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isEditing = false;
  bool _isSaving = false; 

  @override
  void initState() {
    super.initState();
  }

  void _updateUser() async {
    setState(() {
      _isSaving = true;
    });

    CollectionReference users = FirebaseFirestore.instance.collection('Restaurants');
    QuerySnapshot querySnapshot = await users.where('Email', isEqualTo: _email).get();

    if (querySnapshot.size > 0) {
      var document = querySnapshot.docs.first;
      await document.reference.set({
        
        'Name': _nameController.text.trim(),
        'Password': _passwordController.text.trim(),
      }, SetOptions(merge: true));
      setState(() {
        _isEditing = false; 
        _isSaving = false; 
      });
    } else {
      print('No user found with email: $_email');
      setState(() {
        _isSaving = false; 
      });
    }
  }

 @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    _email = arguments['email'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      appBar: AppBar(
        title: const Text("Edit Info"),
        backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Restaurants').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          for (var doc in data.docs) {
            if (doc['Email'] == _email) {
             
              _nameController.text = doc['Name'];
              _passwordController.text = doc['Password'];
          
            }
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  const SizedBox(height: 20),
                 
            
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: TextEditingController(text: _email),
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
                  _isSaving ? CircularProgressIndicator() : Row(
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
                      const SizedBox(width: 20),
                       ElevatedButton(
                        onPressed: (){ Navigator.pushNamed(context,'mHomePage');},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 5, 61, 107),
                        ),
                        child: Text(
                          'Home',
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
