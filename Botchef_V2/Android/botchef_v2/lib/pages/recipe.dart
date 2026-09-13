import 'dart:io';

import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/pages/your_recipes.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../partials/menu.dart';

class RecipePage extends StatefulWidget {
  final RecipeModel? data;
  const RecipePage({super.key, this.data});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  TextEditingController description = TextEditingController();
  TextEditingController recipeName = TextEditingController();
  TextEditingController chefName = TextEditingController();
  TextEditingController calories = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  RecipeServices recipeServices = RecipeServices();
  XFile? image;
  String? photoUrl;
  bool loading = false;
  List<String> categories = [
    "Rice",
    "One Pot Meal",
    "Curry",
    "Stir fry",
  ];
  String? category;
  @override
  void initState() {
    if (widget.data != null) {
      RecipeModel recipe = widget.data!;
      debugPrint(recipe.rid);
      description.text = recipe.description ?? '';
      recipeName.text = recipe.recipeName ?? '';
      chefName.text = recipe.chefName ?? '';
      calories.text = recipe.calories ?? '';
      photoUrl = recipe.photoUrl;
      // Guard against stored category values that no longer exist in
      // `categories` (e.g. legacy data), which would otherwise crash
      // DropdownButtonFormField at build time.
      category = categories.contains(recipe.type) ? recipe.type : categories[0];
    } else {
      category = categories[0];
    }
    super.initState();
  }

  @override
  void dispose() {
    description.dispose();
    recipeName.dispose();
    chefName.dispose();
    calories.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.newtonCradle(
                color: Colors.blue,
                size: 200,
              ),
            )
          : SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final pickedImage = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1600,
                          maxHeight: 1600,
                          imageQuality: 70,
                        );
                        if (!mounted) return;
                        setState(() {
                          image = pickedImage;
                        });
                      },
                      child: photoUrl != null && image == null
                          ? Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(photoUrl!),
                                ),
                              ),
                            )
                          : image != null
                              ? Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          Image.file(File(image!.path)).image,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 200,
                                ),
                    ),
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: recipeName,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Field can't be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Recipe Name",
                                label: const Text("Recipe Name"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: DropdownButtonFormField(
                              value: category,
                              items: categories.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  category = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Type",
                                label: const Text("Type"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: chefName,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Field can't be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Chef Name",
                                label: const Text("Chef Name"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              maxLines: (height(context) * 0.015)
                                  .round()
                                  .clamp(1, 10),
                              controller: description,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Field can't be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Description",
                                label: const Text("Description"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              controller: calories,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Field can't be empty";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Calories",
                                label: const Text("Calories"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: MaterialButton(
                        elevation: 10,
                        minWidth: 250,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: elementsC,
                        onPressed: () async {
                          if (form.currentState!
                              .validate() /* && (image != null || photoUrl != null) */) {
                            setState(() {
                              loading = true;
                            });
                            try {
                              if (image != null) {
                                await uploadPic();
                                //Comment after fixing the google account verification
                                // setState(() {
                                //   photoUrl = "";
                                // });
                              }
                              if (widget.data == null) {
                                await recipeServices.create(
                                  photoUrl: photoUrl!,
                                  uid: user.user.uid,
                                  recipeName: recipeName.text,
                                  chefName: chefName.text,
                                  description: description.text,
                                  calories: calories.text,
                                  type: category!,
                                );
                                Fluttertoast.showToast(
                                    msg: "successfully created new recipe");
                              } else {
                                await recipeServices.update(
                                  id: widget.data!.rid!,
                                  photoUrl: photoUrl!,
                                  recipeName: recipeName.text,
                                  chefName: chefName.text,
                                  description: description.text,
                                  calories: calories.text,
                                  type: category!,
                                );
                                Fluttertoast.showToast(
                                    msg: "successfully updated new recipe");
                              }
                              if (!mounted) return;
                              setState(() {
                                loading = false;
                              });
                              if (!context.mounted) return;
                              navigate(
                                type: PageType.replace,
                                context: context,
                                page: const YourRecipesPage(),
                              );
                            } catch (e) {
                              debugPrint("Failed to save recipe: $e.toString");
                              if (!mounted) return;
                              setState(() {
                                loading = false;
                              });
                              Fluttertoast.showToast(
                                  msg:
                                      "failed to save recipe, please try again");
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            "Save",
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
    );
  }

  uploadPic() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref().child("recipes/${image!.name}");

    try {
      await reference
          .putFile(
            File(image!.path),
            SettableMetadata(
                contentType: 'image/jpeg'), // <-- this avoids the null NPE
          )
          .timeout(const Duration(seconds: 20));

      final value =
          await reference.getDownloadURL().timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        photoUrl = value;
      });
    } catch (e) {
      debugPrint('ERROR uploading recipe photo: ${e.toString()}');
      rethrow;
    }
  }
}
