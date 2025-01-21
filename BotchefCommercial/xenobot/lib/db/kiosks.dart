// Todo: Plan a way for generating ID for kiosks.
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
    required List bases,
    required List flavours,
    required List sweetners,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).set({
        "kid": id,
        "name": name,
        "address": address,
        'created_on': FieldValue.serverTimestamp(),
        "bases": bases,
        "flavours": flavours,
        "sweetners": sweetners
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
          msg: "Kiosk updation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Kiosk updation Failed!", backgroundColor: Colors.red);
    }
  }

  delete({
    required String id,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      Fluttertoast.showToast(
          msg: "Kiosk deletion successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Kiosk deletion Failed!", backgroundColor: Colors.red);
    }
  }

  Future<KioskModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return KioskModel.fromSnapshot(doc);
      });
  updateIngredients({
    required String id,
    required List bases,
    required List flavours,
    required List sweetners,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update(
          {"bases": bases, "flavours": flavours, "sweetners": sweetners});
      Fluttertoast.showToast(
          msg: "Ingredients quantities updated successfully.",
          backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Failed to update ingredients quantities!",
          backgroundColor: Colors.red);
    }
  }
}
