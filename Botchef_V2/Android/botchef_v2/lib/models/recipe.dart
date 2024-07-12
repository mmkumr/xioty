// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  static const PHOTOURL = "photoUrl";
  static const RID = "rid";
  static const UID = "uid";
  static const RECIPE_NAME = "recipeName";
  static const CHEF_NAME = "chefName";
  static const DESCRIPTION = "description";
  static const CALORIES = "calories";
  static const TYPE = "type";
  static const PUBLISHED = "published";
  static const NO_OF_TIMES = "no_of_times";
  static const EARNINGS = "earnings";
  static const PRICE = "price";
  static const RATING = "rating";

  String? _photoUrl;
  String? _rid;
  String? _uid;
  String? _recipeName;
  String? _chefName;
  String? _description;
  String? _calories;
  String? _type;
  bool? _published;
  int? _noOfTimes;
  int? _earings;
  int? _price;
  double? _rating;

  //  getters
  String? get photoUrl => _photoUrl;
  String? get rid => _rid;
  String? get uid => _uid;
  String? get recipeName => _recipeName;
  String? get chefName => _chefName;
  String? get description => _description;
  String? get calories => _calories;
  String? get type => _type;
  bool? get published => _published;
  int? get noOfTimes => _noOfTimes;
  int? get earnings => _earings;
  int? get price => _price;
  double? get rating => _rating;

  // public variables
  RecipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    _photoUrl = snapshot[PHOTOURL];
    _rid = snapshot.id;
    _uid = snapshot[UID];
    _recipeName = snapshot[RECIPE_NAME];
    _chefName = snapshot[CHEF_NAME];
    _description = snapshot[DESCRIPTION];
    _calories = snapshot[CALORIES];
    _type = snapshot[TYPE];
    _published = snapshot[PUBLISHED];
    _noOfTimes = snapshot[NO_OF_TIMES];
    _earings = snapshot[EARNINGS];
    _price = snapshot[PRICE];
    _rating = snapshot[RATING].toDouble();
  }
}
