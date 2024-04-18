import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "recipe";

  create({
    required String photoUrl,
    required String uid,
    required String recipeName,
    required String chefName,
    required String description,
    required String calories,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "uid": uid,
        "photoUrl": photoUrl,
        "recipeName": recipeName,
        "chefName": chefName,
        "description": description,
        "calories": calories
      });
      debugPrint("Recipe has CREATED");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  update({
    required String id,
    required String photoUrl,
    required String uid,
    required String recipeName,
    required String chefName,
    required String description,
    required String calories,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "uid": uid,
        "photoUrl": photoUrl,
        "recipeName": recipeName,
        "chefName": chefName,
        "description": description,
        "calories": calories
      });
      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<RecipeModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return RecipeModel.fromSnapshot(doc);
      });
}
