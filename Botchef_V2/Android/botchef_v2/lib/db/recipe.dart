import 'package:algolia/algolia.dart';
import 'package:botchef_v2/commons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/recipe.dart';

class RecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "recipes";
  Algolia algoliaApp = Algolia.init(
    applicationId: algoliaAppId, //ApplicationID,
    apiKey: algoliaWriteAPIKey, //Admin api key in flutter code
  );

  Future<void> create({
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
        "price": 0,
        "earnings": 0,
        "rating": 0.0,
      }).timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('ERROR creating recipe: ${e.toString()}');
      // Rethrow so callers (e.g. the Save button handler) actually find out
      // the write failed instead of silently treating it as a success.
      rethrow;
    }
  }

  Future<void> update({
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
      }).timeout(const Duration(seconds: 15));

      // Algolia sync is best-effort: if it fails or times out, the recipe
      // update itself has already succeeded, so we swallow errors here on
      // purpose - but with a timeout so a stalled network call can't hang
      // the whole save flow forever.
      List algoMacros = [];
      try {
        algoMacros = await algoliaApp.instance
            .index("xara")
            .getObjectsByIds([id]).timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('WARN: Algolia lookup failed/timed out: ${e.toString()}');
        algoMacros = [];
      }
      if (algoMacros.isNotEmpty) {
        try {
          await algoliaApp.instance.index("xara").addObject({
            "objectID": id,
            'macros': algoMacros[0].data['macros'],
            'recipeName': recipeName,
            'chefName': chefName,
            "photo": photoUrl,
            "type": algoMacros[0].data['type'],
          }).timeout(const Duration(seconds: 8));
        } catch (e) {
          debugPrint(
              'WARN: Algolia addObject failed/timed out: ${e.toString()}');
        }
      }

      debugPrint("Recipe has Updated");
    } catch (e) {
      debugPrint('ERROR updating recipe: ${e.toString()}');
      // Rethrow so callers actually find out the write failed instead of
      // silently treating it as a success.
      rethrow;
    }
  }

  updateEarnings({
    required String rid,
    required int earnings,
  }) async {
    _firestore.collection(collection).doc(rid).update({
      "earnings": FieldValue.increment(earnings),
      "no_of_times": FieldValue.increment(1),
    });
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
    //FirebaseStorage.instance.refFromURL(photoUrl).delete();
    try {
      algoliaApp.instance.index("xara").object(id).deleteObject();
    } catch (e) {
      debugPrint(
          'WARN: Algolia deleteObject failed/timed out: ${e.toString()}');
    }
  }

  Future<RecipeModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return RecipeModel.fromSnapshot(doc);
      });
}
