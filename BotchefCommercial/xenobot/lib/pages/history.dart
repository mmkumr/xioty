import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/partials/menu.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index) {
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
              title: const Text(
                "Irani Tea",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("22/12/2022 24:30"),
              trailing: const Text(
                "₹34",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white70,
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          "Total Consumption: Rs.115",
          softWrap: true,
          style: TextStyle(color: Colors.red, fontSize: 20),
        ),
      ),
    );
  }
}
