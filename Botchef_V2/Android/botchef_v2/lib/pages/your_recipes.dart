import 'package:botchef_v2/pages/variants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../commons.dart';
import '../partials/menu.dart';

class YourRecipesPage extends StatefulWidget {
  const YourRecipesPage({super.key});

  @override
  State<YourRecipesPage> createState() => _YourRecipesPageState();
}

class _YourRecipesPageState extends State<YourRecipesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "New Recipe",
                      style: TextStyle(
                        fontSize: 20,
                        color: elementsC.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Column(
                    children: [
                      Icon(FontAwesomeIcons.cloudArrowUp,
                          color: Colors.grey, size: 40),
                      Text(
                        "Publish",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                // Row for left aligning the subtitle
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Your Recipes",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height(context) * 0.3,
                  child: GridView.builder(
                    itemCount: 5,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            navigate(
                                type: Type.push,
                                context: context,
                                page: const VariantsPage());
                          },
                          child: GridTile(
                            footer: Container(
                              color: Colors.white,
                              child: const Text("Chicken Pakoda"),
                            ),
                            child: Image.network(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Row for left aligning the subtitle
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, top: 30, bottom: 20),
                      child: Text(
                        "Published Recipes",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height(context) * 0.3,
                  child: GridView.builder(
                    itemCount: 5,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GridTile(
                          footer: Container(
                            color: Colors.white,
                            child: const Text("Chicken Pakoda"),
                          ),
                          child: Image.network(
                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
