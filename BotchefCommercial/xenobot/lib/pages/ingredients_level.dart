import 'package:flutter/material.dart';

import '../commons.dart';

class IngredientsLevelPage extends StatefulWidget {
  const IngredientsLevelPage({super.key});

  @override
  State<IngredientsLevelPage> createState() => _IngredientsLevelPageState();
}

class _IngredientsLevelPageState extends State<IngredientsLevelPage> {
  List<String> bases = ["Milk", "Evaporated Milk", "Black Tea", "Green Tea"];
  List sweetners = ["Sugar", "Honey", "Jagery"];
  List flavours = ["Chocolate", "Masala", "Rose"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredients Level"),
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Kiosk ID: 123",
                softWrap: true,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: ListTile(
                  trailing: IconButton(
                      onPressed: () {}, icon: const Icon(Icons.refresh)),
                  title: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: primaryC,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: Text(
                                "Refill all",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Base",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0; index < bases.length; index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    trailing: IconButton(
                        onPressed: () {}, icon: const Icon(Icons.refresh)),
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  bases[index],
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  "456",
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Sweetners",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0; index < sweetners.length; index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    trailing: IconButton(
                        onPressed: () {}, icon: const Icon(Icons.refresh)),
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    sweetners[index],
                                    softWrap: true,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: primaryC,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: Text(
                                "456",
                                softWrap: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Flavours",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0; index < flavours.length; index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    trailing: IconButton(
                        onPressed: () {}, icon: const Icon(Icons.refresh)),
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  flavours[index],
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  "456",
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
