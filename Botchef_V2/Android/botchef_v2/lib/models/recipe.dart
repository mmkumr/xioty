// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  static const PHOTOURL = "photoUrl";
  static const RID = "rid";
  static const UID = "uid";
  static const RECIPENAME = "recipeName";
  static const CHEFNAME = "chefName";
  static const DESCRIPTION = "description";
  static const CALORIES = "calories";

  String? _photoUrl;
  String? _rid;
  String? _uid;
  String? _recipeName;
  String? _chefName;
  String? _description;
  String? _calories;

  //  getters
  String? get photoUrl => _photoUrl;
  String? get rid => _rid;
  String? get uid => _uid;
  String? get recipeName => _recipeName;
  String? get chefName => _chefName;
  String? get description => _description;
  String? get calories => _calories;

  // public variables
  RecipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    _photoUrl = snapshot[PHOTOURL];
    _rid = snapshot.id;
    _uid = snapshot[UID];
    _recipeName = snapshot[RECIPENAME];
    _chefName = snapshot[CHEFNAME];
    _description = snapshot[CALORIES];
  }
}
