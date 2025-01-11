// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
//rid, kid, uid, name, description, base[4], sweetners[3], flavors[3], imageUrl

class RecipeModel {
  static const UID = "uid";
  static const KID = "kid";
  static const NAME = "name";
  static const DESCRIPTION = "description";
  static const BASE = "base";
  static const SWEETNERS = "sweetners";
  static const FLAVORS = "flavors";
  static const IMAGE_URL = "imageUrl";
  static const PRICE = "price";
  static const RATING = "rating";
  static const NO_OF_RATINGS = "noOfRatings";

  String? _rid;
  String? _uid;
  String? _kid;
  String? _name;
  String? _description;
  List? _base;
  List? _sweetners;
  List? _flavors;
  String? _imageUrl;
  int? _price;
  int? _noOfRatings;
  int? _rating;

//  getters
  String get rid => _rid!;
  String get uid => _uid!;
  String get kid => _kid!;
  String get name => _name!;
  String get description => _description!;
  List get base => _base!;
  List get sweetners => _sweetners!;
  List get flavors => _flavors!;
  String get imageUrl => _imageUrl!;
  int get price => _price!;
  int get noOfRatings => _noOfRatings!;
  int get rating => _rating!;

  // public variables
  RecipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    _rid = snapshot.id;
    _uid = snapshot[UID];
    _kid = snapshot[KID];
    _name = snapshot[NAME];
    _description = snapshot[DESCRIPTION];
    _base = snapshot[BASE];
    _sweetners = snapshot[SWEETNERS];
    _flavors = snapshot[FLAVORS];
    _imageUrl = snapshot[IMAGE_URL];
    _price = snapshot[PRICE];
    _rating = snapshot[RATING];
    _noOfRatings = snapshot[NO_OF_RATINGS];
  }
}
