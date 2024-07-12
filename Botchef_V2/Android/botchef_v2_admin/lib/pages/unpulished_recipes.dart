import 'package:botchef_v2_admin/commons.dart';
import 'package:botchef_v2_admin/db/recipes.dart';
import 'package:botchef_v2_admin/models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnpublishedRecipes extends StatefulWidget {
  const UnpublishedRecipes({super.key});

  @override
  State<UnpublishedRecipes> createState() => _UnpublishedRecipesState();
}

class _UnpublishedRecipesState extends State<UnpublishedRecipes> {
  List<RecipeModel> recipes = [];
  GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController price = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unpublished Recipes"),
      ),
      body: FirestorePagination(
          query: FirebaseFirestore.instance
              .collection("recipes")
              .where("published", isEqualTo: false),
          itemBuilder: (context, documentSnapshot, index) {
            RecipeModel recipe = RecipeModel.fromSnapshot(documentSnapshot);
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryC,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: ListTile(
                  onTap: () async {
                    price.text = "0";
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Form(
                              key: form,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Description",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      recipe.description!,
                                      maxLines: 15,
                                      textAlign: TextAlign.justify,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        controller: price,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Field can't be empty";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Price in Rupees",
                                          label: const Text("Price in Rupees"),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          fillColor: primaryC,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (form.currentState!.validate()) {
                                  RecipeServices recipeServices =
                                      RecipeServices();
                                  recipeServices.updatePublished(
                                      id: recipe.rid!, published: true);
                                  recipeServices.updatePrice(
                                      id: recipe.rid!,
                                      price: int.parse(price.text));
                                  Navigator.pop(context);
                                  price.clear();
                                  form.currentState!.reset();
                                  setState(() {});
                                }
                              },
                              child: const Text("Publish"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  titleAlignment: ListTileTitleAlignment.center,
                  contentPadding: const EdgeInsets.all(0),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        CachedNetworkImageProvider(recipe.photoUrl!),
                  ),
                  title: Text(
                    recipe.recipeName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Calories: ${recipe.calories}"),
                  ),
                  subtitle: Text(
                    "Chef Name: ${recipe.chefName}",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
    );
  }
}
