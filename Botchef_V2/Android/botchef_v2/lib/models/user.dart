// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  static const PROFILEURL = "profileUrl";
  static const ID = "uid";
  static const NAME = "name";
  static const EMAIL = "email";
  static const CREATEDON = "created_on";

  String? _profileUrl;
  String? _name;
  String? _email;
  String? _id;
  Timestamp? _createdOn;

//  getters
  String get profileUrl => _profileUrl!;
  String get name => _name!;
  String get email => _email!;
  String get id => _id!;
  Timestamp get createdOn => _createdOn!;

  // public variables
  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _profileUrl = snapshot[PROFILEURL];
    _name = snapshot[NAME];
    _email = snapshot[EMAIL];
    _id = snapshot[ID];
    _createdOn = snapshot[CREATEDON];
  }
}
