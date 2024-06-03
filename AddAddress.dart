import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatefulWidget {
  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  late String email;
  List<String> addresses = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  int? capacity;

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
          'Addresses': addresses,
          'Capacity': capacity,
        }, SetOptions(merge: true));
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
      } else {
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

  void _addAddress() {
    setState(() {
      addresses.add(_addressController.text);
      _addressController.clear();
    });
  }

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
            boxShadow: const [
              BoxShadow(color: Colors.white),
            ],
          ),
          child: SizedBox(
            height: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Add Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Capacity (max 100)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_capacityController.text.isNotEmpty &&
                        int.tryParse(_capacityController.text)! <= 100) {
                      setState(() {
                        capacity = int.parse(_capacityController.text);
                      });
                    }
                  },
                  child: const Text('Add Capacity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 206, 59),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addAddress,
                  child: const Text('Add Address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 206, 59),
                  ),
                ),
                const SizedBox(height: 10),
                if (_isSaving) const CircularProgressIndicator(),
                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(addresses[index]),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 206, 59),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
