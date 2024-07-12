import 'package:botchef_v2_admin/models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "recipes";

  updatePublished({
    required String id,
    required bool published,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "published": published,
      });
      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updatePrice({
    required String id,
    required int price,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "price": price,
      });
      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateEarnings({
    required String id,
    required int earnings,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "earnings": earnings,
      });
      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List<RecipeModel>> getRecipes({
    required bool published,
  }) {
    return _firestore
        .collection(collection)
        .where("published", isEqualTo: published)
        .get()
        .then((value) {
      return value.docs.map((e) {
        return RecipeModel.fromSnapshot(e);
      }).toList();
    });
  }
}
