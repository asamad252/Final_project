import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reservationsProvider = StreamProvider.family<QuerySnapshot<Map<String, dynamic>>, String>((ref, email) {
  return FirebaseFirestore.instance
      .collection('Restaurants')
      .where('Email', isEqualTo: email)
      .snapshots();
});

class ViewReservations extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final email = arguments['email'] ?? '';

    final reservationStream = ref.watch(reservationsProvider(email));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 206, 59),
        title: const Text(
          'View Reservations',
          style: TextStyle(
            color: Color.fromARGB(255, 5, 61, 107),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: reservationStream.when(
          data: (snapshot) {
            final data = snapshot.docs;

            if (data.isEmpty) {
              return Center(child: Text('No Reservations Available'));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final doc = data[index];
                final List<dynamic> addAddresses = doc['Reservations'] ?? [];

                String allAddresses = addAddresses.join(', ');

                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color.fromARGB(255, 5, 61, 107),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allAddresses.isNotEmpty
                                ? allAddresses
                                : 'No Reservations Available',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 206, 59),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Something went wrong: $error')),
        ),
      ),
    );
  }
}
