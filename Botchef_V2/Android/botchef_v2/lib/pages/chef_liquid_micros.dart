import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/process.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';
import 'mima_description.dart';

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
  int nos = 4;
  bool loading = false;
  @override
  void initState() {
    if (widget.variant.liquidMicros!.isEmpty) {
      liquidMicros = List.generate(nos, (index) => TextEditingController());
      quantity =
          List.generate(nos, (index) => TextEditingController(text: "0"));
    } else {
      for (var e in widget.variant.liquidMicros!) {
        liquidMicros.add(TextEditingController(text: e["name"]));
        quantity.add(TextEditingController(text: e["quantity"]));
      }
    }
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
                                      navigate(
                                          type: Type.push,
                                          context: context,
                                          page: const MiMaDescription());
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
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          List<Map> liquidMicrosList = [];
                          for (int i = 0; i < liquidMicros.length; i++) {
                            liquidMicrosList.add(
                              {
                                "name": liquidMicros[i].text,
                                "quantity": quantity[i].text,
                              },
                            );
                          }
                          VariantServices().updateLiquidMicros(
                              vid: widget.variant.vid!,
                              liquidMicros: liquidMicrosList);
                          setState(() {
                            loading = false;
                          });
                          navigate(
                              type: Type.replace,
                              context: context,
                              page: ProcessPage(
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
}
