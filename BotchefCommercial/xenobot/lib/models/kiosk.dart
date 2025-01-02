// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class KioskModel {
  static const KID = "kid";
  static const NAME = "name";
  static const ADDRESS = "address";
  static const CREATEDON = "created_on";

  String? _name;
  String? _address;
  String? _kid;
  Timestamp? _createdOn;

//  getters
  String get name => _name!;
  String get address => _address!;
  String get id => _kid!;
  Timestamp get createdOn => _createdOn!;

  // public variables
  KioskModel.fromSnapshot(DocumentSnapshot snapshot) {
    _name = snapshot[NAME];
    _address = snapshot[ADDRESS];
    _kid = snapshot[KID];
    _createdOn = snapshot[CREATEDON];
  }
}
