import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ignore: deprecated_member_use
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot snapshot = (await databaseReference
      .child('https://cockpit-intelligence-default-rtdb.firebaseio.com')
      .once()) as DataSnapshot;

  if (snapshot.value != null) {
    Map<String, dynamic> data = Map<String, dynamic>.from(DataSnapshot as Map);
    await FirebaseFirestore.instance
        .collection('/cockpit-intelligence/sensor')
        .add(data);
    if (kDebugMode) {
      print('Data migrated successfully!');
    }
  } else {
    if (kDebugMode) {
      print('No data found in the Realtime Database.');
    }
  }
}
