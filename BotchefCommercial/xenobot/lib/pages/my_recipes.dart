import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/db/recipes.dart';
import 'package:xenobot/models/recipe.dart';
import 'package:xenobot/pages/recipe.dart';
import 'package:xenobot/pages/recipe_customize.dart';
import 'package:xenobot/partials/appbar.dart';

import '../commons.dart';
import '../partials/menu.dart';
import '../providers/user_provider.dart';

class MyRecipes extends StatefulWidget {
  const MyRecipes({super.key});

  @override
  State<MyRecipes> createState() => _MyRecipesState();
}

class _MyRecipesState extends State<MyRecipes> {
  List<RecipeModel> myRecipes = [];
  @override
  void didChangeDependencies() {
    getMyRecipes();
    super.didChangeDependencies();
  }

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
                    page: const RecipePage());
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
                    itemCount: myRecipes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: ListTile(
                          onTap: () {
                            navigate(
                                type: PageType.push,
                                context: context,
                                page: RecipePage(
                                  recipe: myRecipes[index],
                                ));
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
                          title: Text(
                            myRecipes[index].name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

  getMyRecipes() async {
    final user = Provider.of<UserProvider>(context);
    myRecipes = await RecipeServices().getMyRecipes(uid: user.userModel.id);
    setState(() {});
  }
}
