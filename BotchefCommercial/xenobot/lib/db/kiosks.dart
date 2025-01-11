import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/models/kiosk.dart';

class KioskServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "kiosks";

  create({
    required String id,
    required String name,
    required String address,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).set({
        "kid": id,
        "name": name,
        "address": address,
        'created_on': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
          msg: "Kiosk creation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Kiosk creation Failed!", backgroundColor: Colors.red);
    }
  }

  update({
    required String id,
    required String name,
    required String address,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "kid": id,
        "name": name,
        "address": address,
        'created_on': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
          msg: "Kiosk creation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Kiosk creation Failed!", backgroundColor: Colors.red);
    }
  }

  Future<KioskModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return KioskModel.fromSnapshot(doc);
      });
}
