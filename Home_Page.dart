import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_16/User/Add_Info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class homePage extends ConsumerWidget {
  late String email;
  late String password;
  late String name;
  late String phone_no;
  late String image;

  Future<Map<String, dynamic>> getUserData(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('Email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userData = querySnapshot.docs.first.data();
      return userData as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(searchFieldProvider);
    final questions = ref.watch(questionsProvider);

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    email = arguments['email'] ?? '';

    return Scaffold(
      appBar: AppBar(backgroundColor:  const Color.fromARGB(255, 255, 206, 59),
        title: const Text('Home Page',
        style: TextStyle(color: Color.fromARGB(255, 5, 61, 107),
        fontSize: 20,
        fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 5, 61, 107),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Add Info'),
              onTap: () async {
                var userData = await getUserData(email);

                email = userData['Email'] ?? '';
                password = userData['Password'] ?? '';
                name = userData['Name'] ?? '';
                image = userData['Image'] ?? '';
                phone_no = userData['Phone_no'] ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const addInfo(),
                    settings: RouteSettings(
                      arguments: {
                        'email': email,
                        'password': password,
                        'name': name,
                        'image': image,
                        'phone_no': phone_no,
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
                Navigator.pushNamed(context,'/userLogin');
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          TextField(
             decoration: const InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor:Colors.amber,
                        hintStyle: TextStyle(color: Colors.yellow),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.yellow),
                        ),
                      ),
            onChanged: (value) =>
                ref.read(searchFieldProvider.notifier).state = value,
                
          ),
          // Expanded(
            
          //   child: Container(
          //     color:  Color.fromARGB(255, 255, 206, 59),
          //     child: questions.when(
              
          //       data: (value) => ListView.builder(
          //         itemCount: value.length,
          //         itemBuilder: (context, index) {
          //           final question = value[index];
              
          //           return ListTile(
          //             title: Text(
          //               question.toString(),
          //             ),
          //           );
          //         },
          //       ),
          //       error: (error, stackTrace) => Center(child: Text('Error $error')),
          //       loading: () => const Center(child: CircularProgressIndicator()),
          //     ),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Restaurants').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                final filteredRestaurants = data.docs.where((doc) {
                  final nameRestaurant = doc['Name'] ?? '';
                  return nameRestaurant.toLowerCase().contains(search.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredRestaurants.length,
                  itemBuilder: (context, index) {
                    final doc = filteredRestaurants[index];
                    final imageUrl = doc['Image'] ?? '';
                    final nameRestaurant = doc['Name'] ?? '';
                    final restaurantEmail = doc['Email'] ?? '';
                    final restaurantCapacity= doc['Capacity'] ?? '';

                    return Card(
                      color: const Color.fromARGB(255, 5, 61, 107),
                      child: Column(
                        children: [
                          imageUrl.isNotEmpty
                              ? Image.network(imageUrl)
                              : const Text('No Image Available'),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: Text(
                              nameRestaurant,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 206, 59),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/moreDetails',
                                    arguments: {'email': email, 'nr': nameRestaurant});
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 206, 59)),
                              child: const Text(
                                'More Details',
                                style: TextStyle(color: Color.fromARGB(255, 5, 61, 107)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/makeReservation',
                                    arguments: {'email': email, 're': restaurantEmail, 'rc': restaurantCapacity});
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 206, 59)),
                              child: const Text(
                                'Make Reservation',
                                style: TextStyle(color: Color.fromARGB(255, 5, 61, 107)),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final searchFieldProvider = StateProvider<String>((ref) => '');
final questionsProvider = FutureProvider<List>((ref) async {
  final search = ref.watch(searchFieldProvider);

  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Restaurants')
      .where('Name', isGreaterThanOrEqualTo: search)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.map((doc) => doc['Name']).toList();
  } else {
    return [];
  }
});
