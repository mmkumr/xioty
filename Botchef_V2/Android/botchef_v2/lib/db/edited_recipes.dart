import 'package:botchef_v2/models/edited_recipes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditedRecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "editedRecipes";

  Future update({
    required String uid,
    required EditedRecipeModel editRecipe,
  }) async {
    try {
      await _firestore.collection(collection).doc(uid).update({
        editRecipe.vid!: {
          "rid": editRecipe.rid!,
          "solidMicro": editRecipe.solidMicro!,
          "liquidMicro": editRecipe.liquidMicro!,
        },
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List> getById({
    required String uid,
    required String vid,
  }) async {
    try {
      return _firestore.collection(collection).doc(uid).get().then((value) {
        if (value.data() != null) {
          return value.data()![vid];
        } else {
          return [];
        }
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      return [];
    }
  }

  Future<List<EditedRecipeModel>> myEditedRecipes(String uid) {
    return _firestore.collection(collection).doc(uid).get().then((value) {
      return value.data()!.keys.map((e) {
        return EditedRecipeModel.fromMap({
          "uid": uid,
          "vid": e,
          "rid": value.data()![e]["rid"],
          "solidMicro": value.data()![e]["solidMicro"],
          "liquidMicro": value.data()![e]["liquidMicro"],
        });
      }).toList();
    });
  }
}
