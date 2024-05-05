import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/pages/variants.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../commons.dart';
import '../partials/appbar.dart';
import '../partials/menu.dart';
import 'recipe.dart';

class YourRecipesPage extends StatefulWidget {
  const YourRecipesPage({super.key});

  @override
  State<YourRecipesPage> createState() => _YourRecipesPageState();
}

class _YourRecipesPageState extends State<YourRecipesPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getRecipes();
  }

  List<RecipeModel>? recipes;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: Center(
        child: SizedBox(
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
                    onPressed: () {
                      navigate(
                          type: PageType.replace,
                          context: context,
                          page: const RecipePage());
                    },
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
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            "Your Recipes",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GridView.builder(
                        itemCount: recipes!.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          RecipeModel recipe = recipes![index];
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: InkWell(
                              onTap: () {
                                navigate(
                                    type: PageType.push,
                                    context: context,
                                    page: VariantsPage(recipe: recipe));
                              },
                              child: GridTile(
                                footer: Container(
                                  color: Colors.white,
                                  child: Text(
                                    recipe.recipeName!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: recipe.photoUrl!,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 15.0, top: 30, bottom: 20),
                          child: Text(
                            "Published Recipes",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 0,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (context, index) {
                          RecipeModel recipe = recipes![index];
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: InkWell(
                              onTap: () {
                                navigate(
                                    type: PageType.push,
                                    context: context,
                                    page: VariantsPage(
                                      recipe: recipe,
                                    ));
                              },
                              child: GridTile(
                                footer: Container(
                                  color: Colors.white,
                                  child: const Text(
                                    "Chicken Pakoda",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getRecipes() async {
    final user = Provider.of<UserProvider>(context);
    RecipeServices recipeServices = RecipeServices();
    recipes = await recipeServices.myRecipes(user.user.uid);
    setState(() {
      recipes;
    });
  }
}
