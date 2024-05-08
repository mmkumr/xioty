import 'package:botchef_v2/models/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "history";

  Future add({
    required String? uid,
    required String? photoUrl,
    required String? recipeName,
    required String? chefName,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "uid": uid,
        "photoUrl": photoUrl,
        "recipeName": recipeName,
        "chefName": chefName,
        "dateTime": DateTime.now().toString(),
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List<HistoryModel>> history(String uid) {
    return _firestore
        .collection(collection)
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      return value.docs.map((e) {
        return HistoryModel.fromSnapshot(e);
      }).toList();
    });
  }
}
