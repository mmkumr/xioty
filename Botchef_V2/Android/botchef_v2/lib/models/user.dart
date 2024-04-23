// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const PROFILEURL = "profileUrl";
  static const ID = "uid";
  static const NAME = "name";
  static const EMAIL = "email";
  static const CREATEDON = "created_on";
  static const MACHINE_ID = "machineId";

  String? _profileUrl;
  String? _name;
  String? _email;
  String? _id;
  Timestamp? _createdOn;
  String? _machineId;

//  getters
  String get profileUrl => _profileUrl!;
  String get name => _name!;
  String get email => _email!;
  String get id => _id!;
  Timestamp get createdOn => _createdOn!;
  String? get machineId => _machineId;

  // public variables
  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _profileUrl = snapshot[PROFILEURL];
    _name = snapshot[NAME];
    _email = snapshot[EMAIL];
    _id = snapshot[ID];
    _createdOn = snapshot[CREATEDON];
    _machineId = snapshot[MACHINE_ID];
  }
}
