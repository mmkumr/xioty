import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/models/ingredients_price.dart';

class IngredientPriceServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "ingredientsPrice";

  Future<IngredientsPriceModel> get() =>
      _firestore.collection(collection).doc("0").get().then((doc) {
        return IngredientsPriceModel.fromSnapshot(doc);
      });
  update(List<Map<String, int>> bases, List<Map<String, int>> sweetners,
      List<Map<String, int>> flavours) {
    _firestore.collection(collection).doc("0").update({
      "bases": bases,
      "flavours": flavours,
      "sweetners": sweetners,
    });
    Fluttertoast.showToast(
        msg: "Successfully Updated ingredients price",
        backgroundColor: Colors.green);
  }
}
