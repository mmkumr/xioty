import 'package:cloud_firestore/cloud_firestore.dart';

class RecipesServices {
  String collection = 'recipes';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  addRecipe(Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  updateRecipe(Map<String, dynamic> data, String id) async {
    await _firestore.collection(collection).doc(id).update(data);
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

  runRecipe(List<String> data) async {
    await _firestore
        .collection('run')
        .doc('aadkVC7gURqOpZquVHWH')
        .update({'run': data});
  }

  removeRecipe(String id) async {
    _firestore.collection(collection).doc(id).delete();
  }
}
