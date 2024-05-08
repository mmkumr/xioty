import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/chef_liquid_micros.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';

class ChefSolidMicro extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  const ChefSolidMicro(
      {super.key, required this.variant, required this.recipe});

  @override
  State<ChefSolidMicro> createState() => _ChefSolidMicroState();
}

class _ChefSolidMicroState extends State<ChefSolidMicro> {
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<TextEditingController> solidMicros = [];
  List<TextEditingController> quantity = [];
  TextEditingController description = TextEditingController();
  GlobalKey<FormState> popUpForm = GlobalKey<FormState>();
  int nos = 8;
  ScrollController scrollController = ScrollController();
  bool loading = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });

    if (widget.variant.solidMicros!.isEmpty) {
      solidMicros = List.generate(nos, (index) => TextEditingController());
      quantity =
          List.generate(nos, (index) => TextEditingController(text: "0"));
    } else {
      for (var e in widget.variant.solidMicros!) {
        solidMicros.add(TextEditingController(text: e["name"]));
        quantity.add(TextEditingController(text: e["quantity"]));
      }
    }
    super.initState();
  }

  bool start = false;
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
              reverse: start,
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
                      "Solid Micros",
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
                                        onTap: () {
                                          if (!start) {
                                            setState(() {
                                              start = true;
                                            });
                                          }
                                        },
                                        controller: solidMicros[i],
                                        decoration: InputDecoration(
                                          hintText: "Solid Micro ${i + 1}",
                                          label: Text("Solid Micro ${i + 1}"),
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
                                      mimaDescriptionPopup();
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
                          List<Map> solidMicrosList = [];
                          for (int i = 0; i < solidMicros.length; i++) {
                            solidMicrosList.add(
                              {
                                "name": solidMicros[i].text,
                                "quantity": quantity[i].text,
                              },
                            );
                          }
                          await VariantServices().updateSolidMicros(
                              vid: widget.variant.vid!,
                              solidMicros: solidMicrosList);
                          setState(() {
                            loading = false;
                          });
                          if (!context.mounted) return;
                          navigate(
                              type: PageType.replace,
                              context: context,
                              page: ChefLiquidMicro(
                                variant: widget.variant,
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

  Future<dynamic> mimaDescriptionPopup() {
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
                    const Icon(
                      Icons.image_rounded,
                      size: 200,
                    ),
                    Form(
                      key: popUpForm,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: description,
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
        );
      },
    );
  }
}
