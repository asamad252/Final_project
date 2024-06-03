import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeReservation extends StatefulWidget {
  @override
  State<MakeReservation> createState() => _MakeReservationState();
}

class _MakeReservationState extends State<MakeReservation> {
  List<String> peopleList = [
    'Select Number Of People',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15'
  ];

  List<String> timeList = [
    'Select Time',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
    '10:00 PM',
    '11:00 PM',
    '12:00 AM'
  ];

  String selectedPeople = 'Select Number Of People';
  String selectedTime = 'Select Time';

  late String restaurantEmail;
  late String email;
  late int restaurantCapacity;
  late int newCapacity;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;
  bool _isSaving = false;
  bool _reservationMade = false;

  Future<void> _makeReservation() async {
    if (selectedPeople == 'Select Number Of People' ||
        selectedTime == 'Select Time') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select valid options for reservation.')),
      );
      return;
    }

    int numberOfPeople = int.parse(selectedPeople);
    newCapacity = restaurantCapacity - numberOfPeople;

    if (newCapacity < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not enough capacity for this reservation.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      CollectionReference restaurants = _firestore.collection('Restaurants');
      QuerySnapshot querySnapshot = await restaurants
          .where('Email', isEqualTo: restaurantEmail)
          .get();

      if (querySnapshot.size > 0) {
        var document = querySnapshot.docs.first;
        await document.reference.update({
          'Capacity': newCapacity,
          'Reservations': FieldValue.arrayUnion([
            {
              'Capacity': numberOfPeople,
              'Time': selectedTime,
              'UserEmail': email,
            }
          ])
        });
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _reservationMade = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation successful!')),
        );
      } else {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restaurant not found.')),
        );
      }
    } catch (e) {
      print('Error updating Firestore: $e');
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reservation.')),
      );
    }
  }

 void _cancelReservation() async {
  setState(() {
    _reservationMade = false;
  });

  try {
    CollectionReference restaurants = _firestore.collection('Restaurants');
    QuerySnapshot querySnapshot = await restaurants
        .where('Email', isEqualTo: restaurantEmail)
        .get();

    if (querySnapshot.size > 0) {
      var document = querySnapshot.docs.first;
      List<dynamic> reservations = document['Reservations'];
    
      for (var reservation in reservations) {
        if (reservation['UserEmail'] == email &&
            reservation['Time'] == selectedTime) {
          reservations.remove(reservation);
          await document.reference.update({
            'Reservations': reservations,
            'Capacity': restaurantCapacity + reservation['Capacity']
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reservation canceled!')),
          );
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation not found.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restaurant not found.')),
      );
    }
  } catch (e) {
    print('Error canceling reservation: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error canceling reservation.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final Map arguments =
        ModalRoute.of(context)!.settings.arguments as Map;
    restaurantEmail = arguments['re'] ?? '';
    email = arguments['email'] ?? '';
    restaurantCapacity = arguments['rc'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Reservation'),
        backgroundColor: const Color.fromARGB(255, 255, 206, 59),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 206, 59),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 255, 206, 59),
                value: selectedPeople,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPeople = newValue!;
                  });
                },
                iconEnabledColor: Colors.black, 
                underline: Container(), 
                items: peopleList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black), // Text color
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 206, 59),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                dropdownColor: const Color.fromARGB(255, 255, 206, 59),
                value: selectedTime,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTime = newValue!;
                  });
                },
                iconEnabledColor: Colors.black, 
                underline: Container(), 
                items: timeList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.black), 
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor:   Color.fromARGB(255, 5, 61, 107))
             , onPressed: _makeReservation,
              child: const Text('Make Reservation',
              style: TextStyle(color: const Color.fromARGB(255, 255, 206, 59)),),
            ),
            Padding(padding:EdgeInsets.all(20)),
            if (_reservationMade)
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor:   Color.fromARGB(255, 5, 61, 107))
              ,  onPressed: _cancelReservation,
                child: const Text('Cancel Reservation',
                style: TextStyle(color: const Color.fromARGB(255, 255, 206, 59)),),
              ),
          ],
        ),
      ),
    );
  }
}
