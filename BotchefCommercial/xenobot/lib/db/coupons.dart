import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/models/coupon.dart';

class CouponServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "coupons";

  create({
    required String name,
    required int value,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "name": name,
        "value": value,
      });
      Fluttertoast.showToast(
          msg: "Coupon creation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Coupon creation Failed!", backgroundColor: Colors.red);
    }
  }

  update({
    required String id,
    required String name,
    required int value,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "name": name,
        "value": value,
      });
      Fluttertoast.showToast(
          msg: "Coupon updation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Coupon updation Failed!", backgroundColor: Colors.red);
    }
  }

  delete({
    required String id,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      Fluttertoast.showToast(
          msg: "Coupon deletion successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Coupon deletion Failed!", backgroundColor: Colors.red);
    }
  }

  Future<CouponModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return CouponModel.fromSnapshot(doc);
      });
  Future<List<CouponModel>> getAll() =>
      _firestore.collection(collection).get().then((value) {
        List<CouponModel> coupons = [];
        for (var coupon in value.docs) {
          debugPrint(coupon.data().toString());
          coupons.add(CouponModel.fromSnapshot(coupon));
        }
        return coupons;
      });
}
