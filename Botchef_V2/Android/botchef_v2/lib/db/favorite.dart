import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavoriteServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "favorites";

  Future update({
    required String uid,
    required String rid,
  }) async {
    try {
      await _firestore.collection(collection).doc(uid).update({
        "favorites": FieldValue.arrayUnion([rid]),
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      await _firestore.collection(collection).doc(uid).set({
        "favorites": [rid],
      });
    }
  }

  Future delete({
    required String uid,
    required String rid,
  }) async {
    try {
      await _firestore.collection(collection).doc(uid).update({
        "favorites": FieldValue.arrayRemove([rid]),
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List> getById({
    required String uid,
  }) async {
    try {
      return _firestore.collection(collection).doc(uid).get().then((value) {
        if (value.data() != null) {
          return value.data()!["favorites"];
        } else {
          return [];
        }
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      return [];
    }
  }
}
