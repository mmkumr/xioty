// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
//rid, kid, uid, name, description, base[4], sweetners[3], flavors[3], imageUrl

class EditedRecipeModel {
  static const RID = "rid";
  static const UID = "uid";
  static const KID = "kid";
  static const NAME = "name";
  static const BASES = "bases";
  static const SWEETNERS = "sweetners";
  static const FLAVORS = "flavours";
  static const PRICE = "price";

  String? _rid;
  String? _uid;
  String? _kid;
  String? _name;
  List? _bases;
  List? _sweetners;
  List? _flavours;
  int? _price;
  String? _id;

//  getters
  String get rid => _rid!;
  String get uid => _uid!;
  String get kid => _kid!;
  String get name => _name!;
  List get bases => _bases!;
  List get sweetners => _sweetners!;
  List get flavours => _flavours!;
  int get price => _price!;
  String get id => _id!;

  // public variables
  EditedRecipeModel.fromSnapshot(DocumentSnapshot snapshot) {
    _rid = snapshot[RID];
    _uid = snapshot[UID];
    _kid = snapshot[KID];
    _name = snapshot[NAME];
    _bases = snapshot[BASES];
    _sweetners = snapshot[SWEETNERS];
    _flavours = snapshot[FLAVORS];
    _price = snapshot[PRICE];
    _id = snapshot.id;
  }
}
