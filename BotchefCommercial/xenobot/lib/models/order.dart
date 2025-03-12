// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xenobot/db/users.dart';

class OrderModel {
  static const UID = "uid";
  static const KID = "kid";
  static const PAYMENT_METHOD = "paymentMethod";
  static const STATUS = "status";
  static const SUBTOTAL = "subtotal";
  static const TAX = "tax";
  static const DISCOUNT = "discount";
  static const TOTAL = "total";
  static const ITEM_NAME = "itemName";
  static const ITEM_IMAGE = "itemImage";
  static const DATE = "date";

  String? _uid;
  String? _kid;
  PaymentMethod? _paymentMethod;
  String? _status;
  double? _subtotal;
  double? _discount;
  double? _tax;
  double? _total;
  String? _itemName;
  String? _itemImage;
  Timestamp? _date;

//  getters
  String get uid => _uid!;
  String get kid => _kid!;
  PaymentMethod get paymentMode => _paymentMethod!;
  String get status => _status!;
  double get subtotal => _subtotal!;
  double get tax => _tax!;
  double get discount => _discount!;
  double get total => _total!;
  String get itemName => _itemName!;
  String get itemImage => _itemImage!;
  Timestamp get date => _date!;

  // public variables
  OrderModel.fromSnapshot(DocumentSnapshot snapshot) {
    _uid = snapshot[UID];
    _kid = snapshot[KID];
    _status = snapshot[STATUS];
    _subtotal = snapshot[SUBTOTAL];
    _tax = snapshot[TAX];
    _discount = snapshot[DISCOUNT];
    _total = snapshot[TOTAL];
    _itemName = snapshot[ITEM_NAME];
    _itemImage = snapshot[ITEM_IMAGE];
    _date = snapshot[DATE];
    _paymentMethod = PaymentMethod.values[snapshot[PAYMENT_METHOD]];
  }
}
