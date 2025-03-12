import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/models/edited_recipe.dart';

class EditedRecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "editedRecipes";

  Future<String> create({
    required String rid,
    required String uid,
    required String kid,
    required String name,
    required int price,
    required List bases,
    required List sweetners,
    required List flavours,
  }) async {
    try {
      return await _firestore.collection(collection).add({
        "rid": rid,
        "uid": uid,
        "kid": kid,
        "name": name,
        "bases": bases,
        "sweetners": sweetners,
        "flavours": flavours,
        "price": price,
      }).then((value) {
        Fluttertoast.showToast(
            msg: "Recipe created successfully.", backgroundColor: Colors.green);
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
    required String id,
    required int price,
    required List bases,
    required List sweetners,
    required List flavours,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "bases": bases,
        "sweetners": sweetners,
        "flavours": flavours,
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

  Future<EditedRecipeModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return EditedRecipeModel.fromSnapshot(doc);
      });

  Future<List<EditedRecipeModel>> getRecipes({
    required String uid,
    required String kid,
  }) =>
      _firestore
          .collection(collection)
          .where("uid", isEqualTo: uid)
          .where("kid", isEqualTo: kid)
          .get()
          .then((value) {
        List<EditedRecipeModel> recipes = [];
        for (var recipe in value.docs) {
          recipes.add(EditedRecipeModel.fromSnapshot(recipe));
        }
        return recipes;
      });
  delete(String id) {
    try {
      _firestore.collection(collection).doc(id).delete();
      Fluttertoast.showToast(
          msg: "Recipe deleted successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      Fluttertoast.showToast(
          msg: "Recipe deletion Failed!", backgroundColor: Colors.red);
    }
  }
}
