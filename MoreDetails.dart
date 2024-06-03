import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoreDetails extends StatefulWidget{
  @override
  State<MoreDetails> createState() => _MoreDetailsState();
}

class _MoreDetailsState extends State<MoreDetails> {

   bool _customTileExpanded = false;
   late String nameRestaurant;

   
StreamBuilder<QuerySnapshot<Object?>> restaurantMenu(String nameRestaurants) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Restaurants')
        .where('Name', isEqualTo: nameRestaurants)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Something went wrong'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = snapshot.requireData;

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: data.size,
        itemBuilder: (context, index) {
          final doc = data.docs[index];
          final List<dynamic> imageUrls = doc['menuImages'] ?? [];

          print('Document Data: ${doc.data()}');

          return Container(
            height: 100,
            width: 100,
            child: Card(
              color: const Color.fromARGB(255, 5, 61, 107),
              
              child: Column(
                children: [
                  if (imageUrls.isNotEmpty)
                    for (var url in imageUrls)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        ),
                      )
                  else
                    const Text('No Image Available'),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

StreamBuilder<QuerySnapshot<Object?>> restaurantPictures(String nameRestaurants) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Restaurants')
        .where('Name', isEqualTo: nameRestaurants)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Something went wrong'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = snapshot.requireData;

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: data.size,
        itemBuilder: (context, index) {
          final doc = data.docs[index];
          final List<dynamic> imageUrls = doc['morePictures'] ?? [];

          print('Document Data: ${doc.data()}');

          return Container(
            height: 100,
            width: 100,
            child: Card(
              color: const Color.fromARGB(255, 5, 61, 107),
              
              child: Column(
                children: [
                  if (imageUrls.isNotEmpty)
                    for (var url in imageUrls)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        ),
                      )
                  else
                    const Text('No Image Available'),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

StreamBuilder<QuerySnapshot<Object?>> restaurantAddress(String nameRestaurants) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Restaurants')
        .where('Name', isEqualTo: nameRestaurants)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Something went wrong'));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = snapshot.requireData;

      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: data.size,
        itemBuilder: (context, index) {
          final doc = data.docs[index];
          final List<dynamic> addAddresses = doc['Addresses'] ?? [];
          
      
          String allAddresses = addAddresses.join(', '); 

          print('Document Data: ${doc.data()}');

          return Container(
            height: 100,
            width: 100,
            child: Card(
              color: const Color.fromARGB(255, 5, 61, 107),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      allAddresses.isNotEmpty ? allAddresses : 'No Address Available',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 206, 59),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}




  
  @override
  Widget build(BuildContext context) {

     final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    nameRestaurant = arguments['nr'] ?? '';
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor:  const Color.fromARGB(255, 255, 206, 59),
        title: const Text('More Details',
        style:TextStyle(
          color: Color.fromARGB(255, 5, 61, 107),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
   body:   SingleChildScrollView(
     child: Column(
        children: <Widget>[
          ExpansionTile(

            title:const Text('Menu',
          style:TextStyle(
            color:  Color.fromARGB(255, 255, 206, 59) ,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
           
            children: <Widget>[
              SizedBox(
                  height: 300,

                  child: restaurantMenu(nameRestaurant),
                ), 
            ],
          ),
          ExpansionTile(
           
            title: const Text('Restaurant Pictures',
          style:TextStyle(
            color:  Color.fromARGB(255, 255, 206, 59) ,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
          
            // trailing: Icon(
            //   _customTileExpanded
            //       ? Icons.arrow_drop_down_circle
            //       : Icons.arrow_drop_down,
            // ),
            children:  <Widget>[
             SizedBox(
                  height: 300,

                  child: restaurantPictures(nameRestaurant),
                ), 
            
            ],
            onExpansionChanged: (bool expanded) {
              setState(() {
                _customTileExpanded = expanded;
              });
            },
          ),
           ExpansionTile(
       
            title: const Text('Location',
          style:TextStyle(
            color:  Color.fromARGB(255, 255, 206, 59) ,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          ),
        
           
            children: <Widget>[
              SizedBox(
                  height: 300,
             
                  child:restaurantAddress(nameRestaurant),
                ),  
            ],
          ),
        ],
      ),
   ));
  }
}