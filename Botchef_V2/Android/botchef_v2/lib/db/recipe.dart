import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "recipes";
  Algolia algoliaApp = const Algolia.init(
    applicationId: 'KWPCAWUHDW', //ApplicationID,
    apiKey: 'bf30ae35483ea194e02366cd3bf0737e', //Admin api key in flutter code
  );

  create({
    required String photoUrl,
    required String uid,
    required String recipeName,
    required String chefName,
    required String description,
    required String calories,
    required String type,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "uid": uid,
        "photoUrl": photoUrl,
        "recipeName": recipeName,
        "chefName": chefName,
        "description": description,
        "calories": calories,
        "type": type,
        "published": false,
        "no_of_times": 0,
        "earnings": 0,
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  update({
    required String id,
    required String photoUrl,
    required String recipeName,
    required String chefName,
    required String description,
    required String calories,
    required String type,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "photoUrl": photoUrl,
        "recipeName": recipeName,
        "chefName": chefName,
        "description": description,
        "calories": calories,
        "type": type,
      });
      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List<RecipeModel>> myRecipes(String uid) {
    return _firestore
        .collection(collection)
        .where("uid", isEqualTo: uid)
        .get()
        .then((value) {
      return value.docs.map((e) {
        return RecipeModel.fromSnapshot(e);
      }).toList();
    });
  }

  delete({required String id, required String photoUrl}) {
    _firestore.collection(collection).doc(id).delete();
    FirebaseStorage.instance.refFromURL(photoUrl).delete();
    algoliaApp.instance.index("xara").object(id).deleteObject();
  }

  Future<RecipeModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return RecipeModel.fromSnapshot(doc);
      });
}
