import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/menu.dart';

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
              fit: BoxFit.fill,
            ),
            title: const Text(
              "Chicken Dum Biryani",
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text("Chef name: Ranveer Brar"),
            trailing: Text(
              "${DateTime.now().toString().substring(0, 10)}\n${DateTime.now().toString().substring(11, 16)}",
              softWrap: true,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
