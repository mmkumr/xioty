import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/edited_recipes.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditedRecipeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "editedRecipes";

  Future update({
    required String uid,
    required String rid,
    required String vid,
    required List solidMicro,
    required List liquidMicro,
  }) async {
    try {
      await _firestore.collection(collection).doc(uid).update({
        vid: {
          "rid": rid,
          "solidMicro": solidMicro,
          "liquidMicro": liquidMicro,
        },
      });
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      await _firestore.collection(collection).doc(uid).set({
        vid: {
          "rid": rid,
          "solidMicro": solidMicro,
          "liquidMicro": liquidMicro,
        },
      });
    }
  }

  Future<EditedRecipeModel> getById({
    required String uid,
    required String vid,
  }) async {
    return _firestore.collection(collection).doc(uid).get().then((value) async {
      Map data = value.data()![vid];
      VariantModel variant = await VariantServices().getById(vid);
      RecipeModel recipe = await RecipeServices().getById(data["rid"]);
      return EditedRecipeModel.fromMap({
        "uid": uid,
        "vModel": variant,
        "rModel": recipe,
        "solidMicro": data["solidMicro"],
        "liquidMicro": data["liquidMicro"],
      });
    });
  }

  Future<List<EditedRecipeModel>> myEditedRecipes(String uid) {
    return _firestore.collection(collection).doc(uid).get().then((value) async {
      List<EditedRecipeModel> data = [];
      for (var element in value.data()!.keys) {
        EditedRecipeModel editedRecipe = await getById(uid: uid, vid: element);
        debugPrint(editedRecipe.rModel!.photoUrl);
        data.add(editedRecipe);
      }
      return data;
    });
  }
}
