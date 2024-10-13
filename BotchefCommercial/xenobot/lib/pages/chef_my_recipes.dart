import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xenobot/pages/new_recipe.dart';
import 'package:xenobot/pages/recipe_customize.dart';
import 'package:xenobot/partials/appbar.dart';

import '../commons.dart';
import '../partials/menu.dart';

class ChefMyRecipe extends StatefulWidget {
  const ChefMyRecipe({super.key});

  @override
  State<ChefMyRecipe> createState() => _ChefMyRecipeState();
}

class _ChefMyRecipeState extends State<ChefMyRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: MaterialButton(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: elementsC,
              onPressed: () {
                navigate(
                    type: PageType.push,
                    context: context,
                    page: const NewRecipePage());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Build New",
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Customized Recipes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: ListTile(
                          onTap: () {
                            navigate(
                                type: PageType.push,
                                context: context,
                                page: const CustomizeRecipePage());
                          },
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
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Your Recipes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: ListTile(
                          onTap: () {
                            navigate(
                                type: PageType.push,
                                context: context,
                                page: const NewRecipePage());
                          },
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
                                  "https://sinfullyspicy.com/wp-content/uploads/2024/04/1200-by-1200-images.jpg"),
                            ),
                          ),
                          title: const Text(
                            "Milk Tea",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
