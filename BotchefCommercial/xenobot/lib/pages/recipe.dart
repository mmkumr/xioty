import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/db/recipes.dart';
import 'package:xenobot/models/recipe.dart';
import 'package:xenobot/pages/edit_ingredients.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';
import 'package:xenobot/providers/kiosk_provide.dart';
import 'package:xenobot/providers/user_provider.dart';

import '../commons.dart';

class RecipePage extends StatefulWidget {
  final RecipeModel? recipe;
  const RecipePage({super.key, this.recipe});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController recipeName = TextEditingController();
  TextEditingController description = TextEditingController();
  List bases = ["Milk", "Evaporated Milk", "Black Tea", "Green Tea"];
  List sweetners = ["Sugar", "Honey", "Jagery"];
  List flavours = ["Chocolate", "Masala", "Rose"];
  XFile? image;
  String? photoUrl;
  bool loading = false;
  Map? ingredientsPrices;

  @override
  void initState() {
    // List basesPrice = [
    //   {"Milk": 1},
    //   {"Evaporated Milk": 2},
    //   {"Black Tea": 3},
    //   {"Green Tea": 4},
    // ];
    // List sweetnersPrice = [
    //   {"Sugar": 5},
    //   {"Honey": 6},
    //   {"Jagery": 7},
    // ];
    // List flavoursPrice = [
    //   {"Chocolate": 8},
    //   {"Masala": 9},
    //   {"Rose": 10},
    // ];
    // FirebaseFirestore.instance.collection("ingredientsPrice").doc("0").update({
    //   "bases": basesPrice,
    //   "sweetners": sweetnersPrice,
    //   "flavours": flavoursPrice
    // });
    if (widget.recipe != null) {
      RecipeModel recipe = widget.recipe!;
      debugPrint(recipe.rid);
      setState(() {
        recipeName.text = recipe.name;
        description.text = recipe.description;
      });
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getIngredientsPrice();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: loading
          ? Center(
              child: LoadingAnimationWidget.newtonCradle(
                color: Colors.blue,
                size: 200,
              ),
            )
          : Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () async {
                              image = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 60);
                              setState(() {
                                image;
                              });
                            },
                            child: photoUrl != null && image == null
                                ? Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            photoUrl!),
                                      ),
                                    ),
                                  )
                                : image != null
                                    ? Container(
                                        height: 200,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: Image.file(File(image!.path))
                                                .image,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        size: 200,
                                      ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: recipeName,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              hintText: "Recipe Name",
                              labelText: "Recipe Name",
                              fillColor: const Color(0xfff6f2f2),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "This field is mandatory";
                              }
                              return null;
                            },
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
                            controller: description,
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
                              nextfunc();
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

  nextfunc() async {
    setState(() {
      loading = true;
    });
    final user = Provider.of<UserProvider>(context, listen: false);
    final kiosk = Provider.of<KioskProvider>(context, listen: false);
    List basesList = [];
    List sweetnersList = [];
    List flavoursList = [];
    ingredientsPrices!["bases"].map((base) {
      basesList.add(0);
    }).toList();
    ingredientsPrices!["sweetners"].map((base) {
      sweetnersList.add(0);
    }).toList();
    ingredientsPrices!["flavours"].map((base) {
      flavoursList.add(0);
    }).toList();
    if (formKey.currentState!.validate()) {
      // if (image == null) {
      //   await uploadPic();
      // }
      RecipeServices recipeServices = RecipeServices();
      String id;
      if (widget.recipe == null) {
        id = await recipeServices.create(
          uid: user.userModel.id,
          kid: kiosk.kioskModel.id,
          name: recipeName.text,
          description: description.text,
          base: basesList,
          sweetners: sweetnersList,
          flavours: flavoursList,
          imageUrl: "",
        );
      } else {
        id = widget.recipe!.rid;
      }
      if (id.isNotEmpty) {
        Fluttertoast.showToast(
            msg: "Recipe creation successfully.",
            backgroundColor: Colors.green);
        RecipeModel recipeModel = await recipeServices.getById(id);
        if (!mounted) return;
        navigate(
            type: PageType.replace,
            context: context,
            page: EditIngredientsPage(
              recipe: recipeModel,
            ));
      } else {
        Fluttertoast.showToast(
            msg: "Error! please try again.", backgroundColor: Colors.red);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Fill mandatory fields", backgroundColor: Colors.red);
    }
    setState(() {
      loading = false;
    });
  }

  uploadPic() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    //Create a reference to the location you want to upload to in firebase
    Reference reference = storage.ref().child("recipes/${image!.name}");

    //Upload the file to firebase
    await reference.putFile(File(image!.path));
    // Waits till the file is uploaded then stores the download url
    await reference.getDownloadURL().then((value) {
      setState(() {
        photoUrl = value;
      });
    });
  }

  getIngredientsPrice() {
    FirebaseFirestore.instance
        .collection("ingredientsPrice")
        .doc("0")
        .get()
        .then((value) {
      setState(() {
        ingredientsPrices = value.data();
      });
    });
  }
}
