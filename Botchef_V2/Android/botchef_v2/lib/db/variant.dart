import 'package:botchef_v2/models/variant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VariantServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "variants";

  create({
    required String rid,
    required String description,
    required String spicy,
    required String portionSize,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "rid": rid,
        "description": description,
        "spicy": spicy,
        "portionSize": portionSize,
        "macros": [],
        "liquidMicros": [],
        "solidMicros": [],
        "operations": [],
      });
      debugPrint("Variant has CREATED");
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');
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
    required String vid,
    required List<Map>? operations,
  }) async {
    try {
      await _firestore
          .collection(collection)
          .doc(vid)
          .update({"operations": operations});
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
