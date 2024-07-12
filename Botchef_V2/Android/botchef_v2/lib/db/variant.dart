import 'package:algolia/algolia.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VariantServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "variants";
  Algolia algoliaApp = const Algolia.init(
    applicationId: 'KWPCAWUHDW', //ApplicationID,
    apiKey: 'bf30ae35483ea194e02366cd3bf0737e', //Admin api key in flutter code
  );

  fill() async {
    await _firestore.collection(collection).get().then((value) async {
      for (var e in value.docs) {
        DocumentReference ref = _firestore.collection(collection).doc(e.id);
        List macros = [];
        List liquidMicros = [];
        List solidMicros = [];
        await _firestore.collection(collection).doc(e.id).get().then((value) {
          macros = value.data()!["macros"].map((e) {
            return {
              "name": e["name"],
              "quantity": e["quantity"],
              "photoUrl": "",
              "description": "",
            };
          }).toList();
          solidMicros = value.data()!["solidMicros"].map((e) {
            return {
              "name": e["name"],
              "quantity": e["quantity"],
              "photoUrl": "",
              "description": "",
            };
          }).toList();
          liquidMicros = value.data()!["liquidMicros"].map((e) {
            return {
              "name": e["name"],
              "quantity": e["quantity"],
              "photoUrl": "",
              "description": "",
            };
          }).toList();
          //end of macro, solid, liquid micro declaration.
        });
        ref.update({
          "macros": macros,
          "liquidMicros": liquidMicros,
          "solidMicros": solidMicros
        });
      }
    });
  }

  Future<String> create({
    required String rid,
    required String description,
    required String spicy,
    required String portionSize,
  }) async {
    try {
      DocumentReference data = await _firestore.collection(collection).add({
        "rid": rid,
        "description": description,
        "spicy": spicy,
        "portionSize": portionSize,
        "macros": [],
        "liquidMicros": [],
        "solidMicros": [],
        "operations": [],
        "cookingTime": "",
      });
      debugPrint("Variant has CREATED");
      return data.id;
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
      return "";
    }
  }

  update({
    required String vid,
    required String description,
    required String spicy,
    required String portionSize,
  }) async {
    try {
      await _firestore.collection(collection).doc(vid).update({
        "description": description,
        "spicy": spicy,
        "portionSize": portionSize,
      });
      debugPrint("Variant has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateMacros({
    required String vid,
    required List<Map>? macros,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(vid)
          .update({"macros": macros});
      debugPrint("Macros has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateLiquidMicros({
    required String vid,
    required List<Map>? liquidMicros,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(vid)
          .update({"liquidMicros": liquidMicros});
      debugPrint("Liquid Micro has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateSolidMicros({
    required String vid,
    required List<Map>? solidMicros,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(vid)
          .update({"solidMicros": solidMicros});
      debugPrint("Solid Micros has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  updateOperations({
    required VariantModel variant,
    required RecipeModel recipe,
    required List<Map>? operations,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(variant.vid)
          .update({"operations": operations});
      List algoMacros = [];
      try {
        algoMacros = await algoliaApp.instance
            .index("xara")
            .getObjectsByIds([variant.rid!]);
      } catch (e) {
        algoMacros = [];
      }

      List macros = variant.macros!.map((e) {
        if (e["name"].isNotEmpty) {
          return e["name"];
        }
      }).toList();
      if (algoMacros.isNotEmpty) {
        algoMacros = algoMacros[0].data["macros"];
        algoMacros.removeWhere(
            (element) => macros.contains(element) || element == null);
      }
      algoliaApp.instance.index("xara").addObject({
        "objectID": variant.rid,
        'macros': macros + algoMacros,
        'recipeName': recipe.recipeName,
        'chefName': recipe.chefName,
        "photo": recipe.photoUrl,
        "type": recipe.type,
      });
      debugPrint("Operations has Updated");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
    }
  }

  Future<List<VariantModel>> getVariants(String rid) {
    return _firestore
        .collection(collection)
        .where("rid", isEqualTo: rid)
        .get()
        .then((value) {
      return value.docs.map((e) {
        return VariantModel.fromSnapshot(e);
      }).toList();
    });
  }

  delete(String vid) {
    _firestore.collection(collection).doc(vid).delete();
  }

  Future<VariantModel> getById(String vid) =>
      _firestore.collection(collection).doc(vid).get().then((doc) {
        return VariantModel.fromSnapshot(doc);
      });
}
