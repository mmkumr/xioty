import 'package:botchef_v2/models/comments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "comments";

  create({
    required String rid,
    required String name,
    required String comment,
    required double rating,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "rid": rid,
        "name": name,
        "comment": comment,
        "rating": rating,
      });
      double prevRating =
          await _firestore.collection(collection).doc(rid).get().then((value) {
        return value.data()!["rating"].toDouble();
      });
      await _firestore.collection(collection).doc(rid).update({
        "rating": (prevRating.toDouble() + rating) / 2,
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<CommentModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        debugPrint(doc.data().toString());
        return CommentModel.fromSnapshot(doc);
      });
}
