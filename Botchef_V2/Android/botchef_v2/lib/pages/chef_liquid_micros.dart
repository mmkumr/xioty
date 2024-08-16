import 'dart:io';

import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/process.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';

class ChefLiquidMicro extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  const ChefLiquidMicro(
      {super.key, required this.variant, required this.recipe});

  @override
  State<ChefLiquidMicro> createState() => _ChefLiquidMicroState();
}

class _ChefLiquidMicroState extends State<ChefLiquidMicro> {
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<TextEditingController> liquidMicros = [];
  List<TextEditingController> quantity = [];
  List<TextEditingController> description = [];
  GlobalKey<FormState> popUpForm = GlobalKey<FormState>();
  List<XFile?> image = [];
  List<String> photoUrl = [];
  int nos = 4;
  bool loading = false;
  @override
  void initState() {
    if (widget.variant.liquidMicros!.isEmpty) {
      liquidMicros = List.generate(nos, (index) => TextEditingController());
      quantity =
          List.generate(nos, (index) => TextEditingController(text: "0"));
      photoUrl = List.generate(nos, (index) => "");
      description = List.generate(nos, (index) => TextEditingController());
      liquidMicros[0] = TextEditingController(text: "Refined Oil");
      liquidMicros[1] = TextEditingController(text: "Tomato Sauce");
      liquidMicros[2] = TextEditingController(text: "Chilli Sauce");
    } else {
      for (var e in widget.variant.liquidMicros!) {
        liquidMicros.add(TextEditingController(text: e["name"]));
        quantity.add(TextEditingController(text: e["quantity"]));
        photoUrl.add(e["photoUrl"]);
        description.add(TextEditingController(text: e["description"]));
      }
    }
    image = List.generate(nos, (index) => XFile(""));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: GridTile(
                        footer: Container(
                          color: Colors.white,
                          child: Text(
                            widget.recipe.recipeName!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: widget.recipe.photoUrl!,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const Text(
                      "Liquid Micros",
                      style: TextStyle(fontSize: 40),
                    ),
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          for (int i = 0; i < nos; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      width: width(context) * 0.5,
                                      child: TextFormField(
                                        controller: liquidMicros[i],
                                        decoration: InputDecoration(
                                          hintText: "Liquid Micro ${i + 1}",
                                          label: Text("Liquid Micro ${i + 1}"),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          fillColor: primaryC,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: SizedBox(
                                      width: width(context) * 0.3,
                                      child: TextFormField(
                                        controller: quantity[i],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          hintText: "tsp",
                                          label: const Text("tsp"),
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          fillColor: primaryC,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      mimaDescriptionPopup(i);
                                    },
                                    child: const Icon(Icons.info_rounded),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 30),
                      child: MaterialButton(
                        elevation: 10,
                        minWidth: 250,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: elementsC,
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          List<Map> liquidMicrosList = [];
                          for (int i = 0; i < liquidMicros.length; i++) {
                            liquidMicrosList.add(
                              {
                                "name": liquidMicros[i].text,
                                "quantity": quantity[i].text,
                                "description": description[i].text,
                                "photoUrl": photoUrl[i]
                              },
                            );
                          }
                          await VariantServices().updateLiquidMicros(
                              vid: widget.variant.vid!,
                              liquidMicros: liquidMicrosList);
                          VariantModel variant = await VariantServices()
                              .getById(widget.variant.vid!);
                          setState(() {
                            loading = false;
                          });
                          if (!context.mounted) return;
                          navigate(
                              type: PageType.replace,
                              context: context,
                              page: ProcessPage(
                                variant: variant,
                                recipe: widget.recipe,
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
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
    );
  }

  Future<dynamic> mimaDescriptionPopup(int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Description"),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: 500,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        image[index] = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        setState(() {
                          image;
                        });
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        mimaDescriptionPopup(index);
                      },
                      child: photoUrl[index].isNotEmpty &&
                              image[index]!.name.isEmpty
                          ? Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      photoUrl[index]),
                                ),
                              ),
                            )
                          : image[index]!.name.isNotEmpty
                              ? Container(
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          Image.file(File(image[index]!.path))
                                              .image,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.image_rounded,
                                  size: 200,
                                ),
                    ),
                    Form(
                      key: popUpForm,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: description[index],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Field can't be empty";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Details",
                            label: const Text("Details"),
                            fillColor: primaryC,
                          ),
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
              onPressed: () async {
                Navigator.pop(context);
                if (image[index]!.name.isNotEmpty) {
                  setState(() {
                    loading = true;
                  });
                  photoUrl[index] = await uploadPic(index);
                  setState(() {
                    loading = false;
                  });
                }
              },
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }

  Future<String> uploadPic(index) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    //Create a reference to the location you want to upload to in firebase
    Reference reference = storage.ref().child("Macros/${image[index]!.name}");

    //Upload the file to firebase
    await reference.putFile(File(image[index]!.path));
    // Waits till the file is uploaded then stores the download url
    return await reference.getDownloadURL();
  }
}
