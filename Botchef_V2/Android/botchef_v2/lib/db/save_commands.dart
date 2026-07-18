import 'package:botchef_v2/models/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedCommandsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "savedCommands";

  Future add({
    required String? uid,
    required String? commandName,
    required List<String>? commands,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "uid": uid,
        "commandName": commandName,
        "commands": commands,
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List<QueryDocumentSnapshot>> get(String uid) {
    return _firestore
        .collection(collection)
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      return value.docs;
    });
  }

  Future update({
    required String? id,
    required String? commands,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "commands": commands,
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }
}
