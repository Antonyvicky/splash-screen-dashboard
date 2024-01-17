import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final StreamController<Map<String, dynamic>> _dataStreamController =
      StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;

  void startListeningToRealtimeData() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference collectionRef =
        firestore.collection('/cockpit-intelligence');

    FirebaseDatabase.instance
        // ignore: deprecated_member_use
        .reference()
        .child('https://cockpit-intelligence-default-rtdb.firebaseio.com')
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
