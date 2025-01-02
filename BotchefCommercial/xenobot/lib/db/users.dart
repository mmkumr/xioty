import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/user.dart';

enum UserType { normal, chef, admin }

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "users";

  createUser(
      {required String id,
      required String name,
      required String email,
      required String profileUrl}) async {
    try {
      await _firestore.collection(collection).doc(id).set({
        "uid": id,
        "name": name,
        "email": email,
        "profileUrl": profileUrl,
        "wallet": 0,
        "type": 0,
        'created_on': DateTime.now(),
      });
      Fluttertoast.showToast(
          msg: "User creation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "User creation Failed!", backgroundColor: Colors.red);
    }
  }

  updateType({
    required String id,
    required UserType type,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "type": type.index,
      });
      Fluttertoast.showToast(
          msg: "User type updated successfully.",
          backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "User type updating Failed!", backgroundColor: Colors.red);
    }
  }

  Future<UserModel> getUserById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });
}
