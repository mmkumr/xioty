// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xenobot/db/users.dart';

class UserModel {
  static const PROFILEURL = "profileUrl";
  static const ID = "uid";
  static const NAME = "name";
  static const EMAIL = "email";
  static const WALLET = "wallet";
  static const TYPE = "type";
  static const CREATEDON = "created_on";
  static const PAYMENT_METHOD = "paymentMethod";

  String? _profileUrl;
  String? _name;
  String? _email;
  String? _id;
  UserType? _type;
  double? _wallet;
  Timestamp? _createdOn;
  PaymentMethod? _paymentMethod;

//  getters
  String get profileUrl => _profileUrl!;
  String get name => _name!;
  String get email => _email!;
  String get id => _id!;
  double get wallet => _wallet!;
  UserType get type => _type!;
  Timestamp get createdOn => _createdOn!;
  PaymentMethod get paymentMethod => _paymentMethod!;

  // public variables
  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    _profileUrl = snapshot[PROFILEURL];
    _name = snapshot[NAME];
    _email = snapshot[EMAIL];
    _id = snapshot[ID];
    _wallet = snapshot[WALLET].toDouble();
    _type = UserType.values[snapshot[TYPE]];
    _paymentMethod = PaymentMethod.values[snapshot[PAYMENT_METHOD]];
    _createdOn = snapshot[CREATEDON];
  }
}
