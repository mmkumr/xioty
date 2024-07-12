import 'package:botchef_v2/db/edited_recipes.dart';
import 'package:botchef_v2/models/edited_recipes.dart';
import 'package:botchef_v2/pages/user_macro.dart';
import 'package:botchef_v2/pages/user_micro.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commons.dart';
import '../partials/appbar.dart';
import '../partials/menu.dart';

class EditedRecipesPage extends StatefulWidget {
  const EditedRecipesPage({super.key});

  @override
  State<EditedRecipesPage> createState() => _EditedRecipesPageState();
}

class _EditedRecipesPageState extends State<EditedRecipesPage> {
  List<EditedRecipeModel> editedRecipes = [];
  bool loading = false;
  @override
  void didChangeDependencies() {
    getEditedRecipes();
    super.didChangeDependencies();
  }

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
                    itemCount: editedRecipes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      EditedRecipeModel editedRecipe = editedRecipes[index];
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            navigate(
                              type: PageType.push,
                              context: context,
                              page: UserMacroPage(
                                variant: editedRecipe.vModel!,
                                recipe: editedRecipe.rModel!,
                                solidMicros: editedRecipe.solidMicro,
                                liquidMicros: editedRecipe.liquidMicro,
                              ),
                            );
                          },
                          child: GridTile(
                            footer: Container(
                              color: Colors.white,
                              child: Text(
                                editedRecipe.rModel!.recipeName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: editedRecipe.rModel!.photoUrl!,
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

  getEditedRecipes() async {
    setState(() {
      loading = true;
    });
    final user = Provider.of<UserProvider>(context);
    editedRecipes = await EditedRecipeServices().myEditedRecipes(user.user.uid);
    setState(() {
      loading = false;
    });
  }
}
