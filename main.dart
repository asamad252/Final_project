import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_16/Manager/AddAddress.dart';
import 'package:flutter_application_16/Manager/Manager_HomePage.dart';
import 'package:flutter_application_16/Manager/Manager_Login.dart';
import 'package:flutter_application_16/Manager/Manager_Signup.dart';
import 'package:flutter_application_16/Manager/Menu.dart';
import 'package:flutter_application_16/Manager/ViewReservation.dart';
import 'package:flutter_application_16/RoleDecider.dart';
import 'package:flutter_application_16/User/Add_Info.dart';
import 'package:flutter_application_16/User/Home_Page.dart';
import 'package:flutter_application_16/User/Login_Page.dart';
import 'package:flutter_application_16/User/MakeReservation.dart';
import 'package:flutter_application_16/User/MoreDetails.dart';
import 'package:flutter_application_16/User/Signup_Page.dart';
import 'package:flutter_application_16/morePictues.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAi086rZjwqM-CzlLHwFB9P3GemZSMfGfk',
        appId: '1:69634161986:android:188dbdd64d5bef1f181cdb',
        messagingSenderId: '69634161986',
        projectId: 'resturantreservationapp',
        storageBucket: 'resturantreservationapp.appspot.com',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    ProviderScope(
      child: MaterialApp(
        home: RoleDecider(),
        routes: {
          '/signupPage': (context) => Signup(),
          '/HomePage': (context) => homePage(),
          '/addInfo': (context) => const addInfo(),
          '/managerSignup': (context) => managerSignup(),
          '/mLogin': (context) => managerLogin(),
          '/userLogin': (context) => Login(),
          '/menu': (context) => Menu(),
          '/morePictures': (context) => MorePictures(),
          '/addAddress': (context) => AddAddress(),
          '/moreDetails': (context) => MoreDetails(),
          '/makeReservation': (context) => MakeReservation(),
          '/viewReservations': (context) => ViewReservations(),
          '/mHomePage':(context) => managerHomePage(),
        },
      ),
    ),
  );
}
