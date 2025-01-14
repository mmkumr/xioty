// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientsPrice {
  String key;
  int value;
  IngredientsPrice({required Map ingredientPrice})
      : key = ingredientPrice.keys.toList()[0],
        value = int.parse(
            ingredientPrice[ingredientPrice.keys.toList()[0]].toString());
}

class IngredientsPriceModel {
  static const BASES = "bases";
  static const SWEETNERS = "sweetners";
  static const FLAVOURS = "flavours";

  List<IngredientsPrice>? _bases;
  List<IngredientsPrice>? _sweetners;
  List<IngredientsPrice>? _flavours;

//  getters
  List<IngredientsPrice> get bases => _bases!;
  List<IngredientsPrice> get sweetners => _sweetners!;
  List<IngredientsPrice> get flavours => _flavours!;

  // public variables
  IngredientsPriceModel.fromSnapshot(DocumentSnapshot snapshot) {
    _bases = snapshot[BASES].map<IngredientsPrice>((value) {
      return IngredientsPrice(ingredientPrice: value);
    }).toList();
    _sweetners = snapshot[SWEETNERS].map<IngredientsPrice>((value) {
      return IngredientsPrice(ingredientPrice: value);
    }).toList();
    _flavours = snapshot[FLAVOURS].map<IngredientsPrice>((value) {
      return IngredientsPrice(ingredientPrice: value);
    }).toList();
  }
}
