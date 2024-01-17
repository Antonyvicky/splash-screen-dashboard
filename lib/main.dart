import 'dart:async';
import 'package:carmodel/dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FirestoreService {
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  void startListeningToRealtimeData() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference collectionRef = firestore.collection(
        'cockpit-intelligence'); // Replace with your Firestore collection

    FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('/') // Replace with your Realtime Database path
        .onValue
        .listen((event) {
      if (event.snapshot.value is Map<dynamic, dynamic>) {
        Map<String, dynamic> realtimeData =
            event.snapshot.value as Map<String, dynamic>;

        collectionRef.add(realtimeData);
        _dataStreamController.add(realtimeData);
      } else {
        if (kDebugMode) {
          print('Invalid data format from Realtime Database');
        }
      }
    });
  }

  void dispose() {
    _dataStreamController.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCWh8wa26iKZcelJXRIZ9NDO8-arjE5DCg',
      appId: '1:401716840671:web:2d0d5ef2c4960d252f416a',
      messagingSenderId: '401716840671',
      projectId: 'cockpit-intelligence',
      authDomain: 'cockpit-intelligence.firebaseapp.com',
      databaseURL: 'https://cockpit-intelligence-default-rtdb.firebaseio.com',
      storageBucket: 'cockpit-intelligence.appspot.com',
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp_2());
}

class MyApp_2 extends StatelessWidget {
  const MyApp_2({super.key});

  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                if (kDebugMode) {
                  print("You have an error: ${snapshot.error.toString()}");
                }
                return const Text("Something went wrong!");
              } else {
                return const Dashboard();
              }
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Check'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Check connection to Realtime Database
            // ignore: deprecated_member_use
            DatabaseReference reference = FirebaseDatabase.instance.reference();
            await reference.once().then((DataSnapshot snapshot) {
                  if (kDebugMode) {
                    print("Connected to Realtime Database");
                  }
                } as FutureOr Function(DatabaseEvent value));

            // Check connection to Cloud Firestore
            CollectionReference collectionReference = FirebaseFirestore.instance
                .collection(
                    'https://cockpit-intelligence-default-rtdb.firebaseio.com');
            // ignore: unused_local_variable
            QuerySnapshot querySnapshot = await collectionReference.get();
            if (kDebugMode) {
              print("Connected to Cloud Firestore");
            }
          },
          child: const Text('Check Firebase Connection'),
        ),
      ),
    );
  }
}
