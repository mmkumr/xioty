import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/db/users.dart';
import 'package:xenobot/models/order.dart';

enum OrderStatus { success, failed }

class OrderServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String collection = "orders";

  create({
    required String uid,
    required PaymentMethod paymentMethod,
    required String status,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required String itemName,
    required String itemImage,
    required BuildContext context,
  }) async {
    try {
      await _firestore.collection(collection).add({
        "uid": uid,
        "paymentMethod": paymentMethod.index,
        "status": status,
        "subtotal": subtotal,
        "discount": discount,
        "tax": tax,
        "total": total,
        "itemName": itemName,
        "itemImage": itemImage,
        "date": DateTime.now(),
      });
      if (paymentMethod == PaymentMethod.wallet) {
        UserServices().updateWallet(id: uid, price: total, context: context);
      }
      Fluttertoast.showToast(
          msg: "Happy Ordering.", backgroundColor: Colors.green);
    } catch (e) {
      debugPrint('ERROR: ${e.toString()}');

      Fluttertoast.showToast(
          msg: "Please try after some time!", backgroundColor: Colors.red);
    }
  }

  Future<OrderModel> getById(String id) =>
      _firestore.collection(collection).doc(id).get().then((doc) {
        return OrderModel.fromSnapshot(doc);
      });

  Future<List<OrderModel>> getAll() =>
      _firestore.collection(collection).get().then((value) {
        List<OrderModel> orders = [];
        for (var order in value.docs) {
          orders.add(OrderModel.fromSnapshot(order));
        }
        return orders;
      });
}
