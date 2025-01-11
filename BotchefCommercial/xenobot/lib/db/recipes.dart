import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/models/recipe.dart';

class RecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "recipes";

  Future<String> create({
    required String uid,
    required String kid,
    required String name,
    required String description,
    required List base,
    required List sweetners,
    required List flavours,
    required String imageUrl,
  }) async {
    try {
      return await _firestore.collection(collection).add({
        "uid": uid,
        "kid": kid,
        "name": name,
        "description": description,
        "base": base,
        "sweetners": sweetners,
        "flavors": flavours,
        "imageUrl": imageUrl,
        "price": 0,
        "rating": 0,
        "noOfRatings": 0
      }).then((value) {
        return value.id;
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      Fluttertoast.showToast(
          msg: "Recipe creation Failed!", backgroundColor: Colors.red);
      return "";
    }
  }

  update({
    required String rid,
    required String name,
    required String description,
    required List base,
    required List sweetners,
    required List flavors,
    required String imageUrl,
    required int price,
  }) async {
    try {
      await _firestore.collection(collection).doc(rid).update({
        "name": name,
        "description": description,
        "base": base,
        "sweetners": sweetners,
        "flavors": flavors,
        "imageUrl": imageUrl,
        "price": price,
      });
      Fluttertoast.showToast(
          msg: "Recipe updated successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Recipe updation Failed!", backgroundColor: Colors.red);
    }
  }

  Future<RecipeModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return RecipeModel.fromSnapshot(doc);
      });

  Future<List<RecipeModel>> getRecipes() =>
      _firestore.collection(collection).get().then((value) {
        List<RecipeModel> recipes = [];
        for (var recipe in value.docs) {
          recipes.add(RecipeModel.fromSnapshot(recipe));
        }
        return recipes;
      });
  Future<List<RecipeModel>> getMyRecipes({required String uid}) => _firestore
          .collection(collection)
          .where("uid", isEqualTo: uid)
          .get()
          .then((value) {
        List<RecipeModel> recipes = [];
        for (var recipe in value.docs) {
          recipes.add(RecipeModel.fromSnapshot(recipe));
        }
        return recipes;
      });
  Future<List<RecipeModel>> getKioskRecipes({required String kid}) => _firestore
          .collection(collection)
          .where("kid", isEqualTo: kid)
          .get()
          .then((value) {
        List<RecipeModel> recipes = [];
        for (var recipe in value.docs) {
          recipes.add(RecipeModel.fromSnapshot(recipe));
        }
        return recipes;
      });
  updateRating({
    required String rid,
    required int oldRating,
    required int newRating,
    required int noOfRatings,
  }) async {
    try {
      await _firestore.collection(collection).doc(rid).update({
        "rating": ((oldRating * noOfRatings) + newRating) / noOfRatings + 1,
        "noOfRatings": noOfRatings + 1
      });
      Fluttertoast.showToast(
          msg: "Recipe updated successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Recipe updation Failed!", backgroundColor: Colors.red);
    }
  }
}
