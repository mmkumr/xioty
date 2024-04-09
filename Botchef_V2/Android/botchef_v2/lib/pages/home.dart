import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'recipe_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchbox = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<String> categories = [
    "Rice",
    "One Pot Meal",
    "Curry",
    "Stir fry",
  ];
  int catindex = 0;
  @override
  Widget build(BuildContext context) {
    String category = categories[catindex];
    return Scaffold(
      backgroundColor: bgC,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Find food for your mood",
                  style: TextStyle(
                    fontSize: width(context) * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      if (catindex > 0) {
                        setState(() {
                          catindex--;
                        });
                      } else {
                        setState(() {
                          catindex = categories.length - 1;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.arrow_left,
                      size: 100,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: width(context) * 0.5,
                    decoration: BoxDecoration(
                      color: primaryC,
                      border: Border.all(),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        category,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (catindex < categories.length - 1) {
                        setState(() {
                          catindex++;
                        });
                      } else {
                        setState(() {
                          catindex = 0;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.arrow_right,
                      size: 100,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 10, bottom: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryC,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextField(
                      controller: searchbox,
                      onChanged: (value) {},
                      decoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        hintText: "Search by Macro, Chef name, Recipe name",
                        hintMaxLines: 2,
                        icon: Icon(FontAwesomeIcons.magnifyingGlass),
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: index == 0
                          ? const EdgeInsets.only(
                              bottom: 10, left: 10, right: 10)
                          : const EdgeInsets.all(10.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: width(context) * 0.5,
                        decoration: BoxDecoration(
                          color: primaryC,
                          border: Border.all(),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(40)),
                        ),
                        child: ListTile(
                          onTap: () {
                            navigate(
                                type: Type.push,
                                context: context,
                                page: const RecipeInfoPage());
                          },
                          titleAlignment: ListTileTitleAlignment.center,
                          contentPadding: const EdgeInsets.all(0),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: Image.network(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                              fit: BoxFit.fill,
                            ).image,
                          ),
                          title: const Text(
                            "Chicken Pakoda",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          subtitle: const Text(
                            "Cooking Time: 1.5 Hours",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
