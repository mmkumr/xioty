import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/models/order.dart';
import 'package:xenobot/partials/menu.dart';
import 'package:xenobot/providers/kiosk_provide.dart';
import 'package:xenobot/providers/user_provider.dart';

class HistoryPage extends StatefulWidget {
  final bool admin;
  final String? kioskId;
  const HistoryPage({super.key, required this.admin, this.kioskId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final kiosk = Provider.of<KioskProvider>(context);
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: FirestorePagination(
        query: widget.admin
            ? FirebaseFirestore.instance
                .collection("orders")
                .where("kid", isEqualTo: widget.kioskId)
            : FirebaseFirestore.instance
                .collection("orders")
                .where("kid", isEqualTo: kiosk.kioskModel.id)
                .where("uid", isEqualTo: user.userModel.id),
        itemBuilder: (context, documentSnapshot, index) {
          OrderModel order = OrderModel.fromSnapshot(documentSnapshot);
          return Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
            child: ListTile(
              tileColor: Colors.black12,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(32),
                ),
              ),
              leading: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundImage: CachedNetworkImageProvider(
                      "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
                ),
              ),
              title: Text(
                order.itemName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text((order.date.toDate()).toString()),
              trailing: Text(
                order.total.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
