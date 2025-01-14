import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/providers/user_provider.dart';

import '../models/user.dart';

enum UserType { normal, chef, admin }

enum PaymentMethod { wallet, online }

class UserServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "users";

  createUser(
      {required String id,
      required String name,
      required String email,
      required String profileUrl}) async {
    try {
      await _firestore.collection(collection).doc(id).set({
        "uid": id,
        "name": name,
        "email": email,
        "profileUrl": profileUrl,
        "wallet": 0,
        "type": 0,
        'created_on': DateTime.now(),
        "paymentMethod": 0,
      });
      Fluttertoast.showToast(
          msg: "User creation successfully.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "User creation Failed!", backgroundColor: Colors.red);
    }
  }

  updateType({
    required String id,
    required UserType type,
    required BuildContext context,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "type": type.index,
      });
      Fluttertoast.showToast(
          msg: "User type updated successfully.",
          backgroundColor: Colors.green);
      if (!context.mounted) return;
      var user = Provider.of<UserProvider>(context);
      user.updateUserData();
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "User type updating Failed!", backgroundColor: Colors.red);
    }
  }

  updatePaymentMethod({
    required String id,
    required PaymentMethod paymentMethod,
    required BuildContext context,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "paymentMethod": paymentMethod.index,
      });
      Fluttertoast.showToast(
          msg: "Payment method updated successfully.",
          backgroundColor: Colors.green);
      if (!context.mounted) return;
      var user = Provider.of<UserProvider>(context);
      user.updateUserData();
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Payment method updating Failed!", backgroundColor: Colors.red);
    }
  }

  updateWallet({
    required String id,
    required double price,
    required BuildContext context,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "wallet": FieldValue.increment(-price),
      });
      if (!context.mounted) return;
      var user = Provider.of<UserProvider>(context);
      user.updateUserData();
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Please try after sometime!", backgroundColor: Colors.red);
    }
  }

  Future<UserModel> getUserById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return UserModel.fromSnapshot(doc);
      });
}
