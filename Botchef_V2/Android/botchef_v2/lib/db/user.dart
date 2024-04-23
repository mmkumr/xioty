import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

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
        'created_on': DateTime.now(),
        "machineId": "",
      });
      debugPrint("USER has CREATED");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateMachineId({
    required String uid,
    required String machineId,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(uid)
          .update({"machineId": machineId});
      debugPrint("Machine Id has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<UserModel> getUserById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });
}
