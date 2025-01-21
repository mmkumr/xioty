// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  static const NAME = "name";
  static const VALUE = "value";

  String? _id;
  String? _name;
  int? _value;

//  getters
  String get id => _id!;
  String get name => _name!;
  int get value => _value!;

  // public variables
  CouponModel.fromSnapshot(DocumentSnapshot snapshot) {
    _name = snapshot[NAME];
    _value = snapshot[VALUE];
    _id = snapshot.id;
  }
}
