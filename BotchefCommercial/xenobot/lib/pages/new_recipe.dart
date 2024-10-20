import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xenobot/pages/edit_ingredients.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';

import '../commons.dart';

class NewRecipePage extends StatefulWidget {
  const NewRecipePage({super.key});

  @override
  State<NewRecipePage> createState() => _NewRecipePageState();
}

class _NewRecipePageState extends State<NewRecipePage> {
  TextEditingController recipeName = TextEditingController();
  TextEditingController chefName = TextEditingController();
  TextEditingController description = TextEditingController();
  @override
  void initState() {
    chefName.text = "Gordon Ramsay";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: Flexible(
        child: SingleChildScrollView(
          child: Form(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 80,
                        backgroundImage: CachedNetworkImageProvider(
                            "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintText: "Recipe Name",
                        labelText: "Recipe Name",
                        fillColor: const Color(0xfff6f2f2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8,
                      left: 20,
                      right: 20,
                    ),
                    child: TextFormField(
                      minLines: 10,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        filled: true,
                        hintText: "Description",
                        labelText: "Description",
                        fillColor: const Color(0xfff6f2f2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: MaterialButton(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: elementsC,
                      onPressed: () {
                        navigate(
                            type: PageType.replace,
                            context: context,
                            page: const EditIngredientsPage());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10, bottom: 10),
                        child: Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 20,
                            color: elementsC.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
