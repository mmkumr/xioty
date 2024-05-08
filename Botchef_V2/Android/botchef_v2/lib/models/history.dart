// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  static const UID = "uid";
  static const PHOTO_URL = "photoUrl";
  static const RECIPE_NAME = "recipeName";
  static const CHEF_NAME = "chefName";
  static const DATE_TIME = "dateTime";

  String? _uid;
  String? _photoUrl;
  String? _recipeName;
  String? _chefName;
  String? _dateTime;

  //  getters
  String? get uid => _uid;
  String? get photoUrl => _photoUrl;
  String? get recipeName => _recipeName;
  String? get chefName => _chefName;
  String? get dateTime => _dateTime;
  // public variables
  HistoryModel.fromSnapshot(DocumentSnapshot snapshot) {
    _uid = snapshot[UID];
    _photoUrl = snapshot[PHOTO_URL];
    _recipeName = snapshot[RECIPE_NAME];
    _chefName = snapshot[CHEF_NAME];
    _dateTime = snapshot[DATE_TIME];
  }
}
