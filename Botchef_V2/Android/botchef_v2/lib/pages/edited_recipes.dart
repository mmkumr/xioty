import 'package:botchef_v2/pages/recipe_info.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/appbar.dart';
import '../partials/menu.dart';

class EditedRecipesPage extends StatefulWidget {
  const EditedRecipesPage({super.key});

  @override
  State<EditedRecipesPage> createState() => _EditedRecipesPageState();
}

class _EditedRecipesPageState extends State<EditedRecipesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Edited Recipes",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: height(context) * 0.8,
                  child: GridView.builder(
                    itemCount: 11,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {},
                          child: GridTile(
                            footer: Container(
                              color: Colors.white,
                              child: const Text(
                                "Chicken Pakoda",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
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
              ],
            )
          ],
        ),
      ),
    );
  }
}
