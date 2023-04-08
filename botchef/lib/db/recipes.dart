import 'package:cloud_firestore/cloud_firestore.dart';

class RecipesServices {
  String collection = 'recipes';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  addRecipe(Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Future<List<DocumentSnapshot>> getAllRecipes() async {
    return _firestore.collection(collection).get().then((value) {
      return value.docs;
    });
  }

  Future<Map<String, dynamic>> getRecipe(String id) async {
    return _firestore.collection(collection).doc(id).get().then((value) {
      return value.data()!;
    });
  }

  removeRecipe(String id) async {
    _firestore.collection(collection).doc(id).delete();
  }
}
