import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../commons.dart';
import '../partials/menu.dart';

class RecipeInfoPage extends StatefulWidget {
  const RecipeInfoPage({super.key});

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(
                Icons.favorite_outline,
                color: Colors.red,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      drawer: menu(context),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: 250,
                child: GridTile(
                  footer: Container(
                    color: Colors.white,
                    child: const Text(
                      "Chicken Pakoda",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                      fit: BoxFit.fill,
                    ).image,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.alarm_rounded,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "2 hours",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 5.0),
                            child: Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "4.8",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 5.0),
                            child: Icon(
                              FontAwesomeIcons.fireFlameCurved,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "345 Kcal",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  textAlign: TextAlign.justify,
                ),
              ),
              Wrap(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryC,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Mild",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryC,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Medium",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryC,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "Extreme",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, right: 20),
                    child: Text(
                      "Portion Size",
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 3),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(60),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "2",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(60)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "4",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
