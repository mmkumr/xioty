import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xenobot/models/ingredients_price.dart';

class IngredientsPricesServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "ingredientsPrice";

  Future<IngredientsPriceModel> get() =>
      _firestore.collection(collection).doc("0").get().then((doc) {
        return IngredientsPriceModel.fromSnapshot(doc);
      });
}
