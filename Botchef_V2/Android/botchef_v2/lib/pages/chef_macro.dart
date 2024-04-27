import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/chef_solid_micros.dart';
import 'package:botchef_v2/pages/mima_description.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';

class ChefMacroPage extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  const ChefMacroPage({super.key, required this.variant, required this.recipe});

  @override
  State<ChefMacroPage> createState() => _ChefMacroPageState();
}

class _ChefMacroPageState extends State<ChefMacroPage> {
  List<TextEditingController> macros = [];
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<String> quantities = [
    "1 cup",
    "1/2 cup",
    "1/4 cup",
    "3/4 cup",
  ];
  List<String> quantity = [];
  bool loading = false;
  int nos = 4;
  @override
  void initState() {
    if (widget.variant.macros!.isEmpty) {
      macros = List.generate(nos, (index) => TextEditingController());
      quantity = List.generate(nos, (index) => quantities[0]);
    } else {
      for (var e in widget.variant.macros!) {
        macros.add(TextEditingController(text: e["name"]));
        quantity.add(e["quantity"]);
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
                      "Macros",
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
                                        controller: macros[i],
                                        decoration: InputDecoration(
                                          hintText: "Macro ${i + 1}",
                                          label: Text("Macro ${i + 1}"),
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
                                      child: DropdownButtonFormField(
                                        value: quantity[i],
                                        items: quantities.map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            quantity[i] = value!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          hintText: "Quantity",
                                          label: const Text("Quantity"),
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
                        onPressed: () async {
                          setState(() {
                            loading = true;
                          });
                          List<Map> macrosList = [];
                          for (int i = 0; i < macros.length; i++) {
                            macrosList.add(
                              {
                                "name": macros[i].text,
                                "quantity": quantity[i],
                              },
                            );
                          }
                          await VariantServices().updateMacros(
                              vid: widget.variant.vid!, macros: macrosList);
                          setState(() {
                            loading = false;
                          });
                          if (!context.mounted) return;
                          navigate(
                            type: Type.replace,
                            context: context,
                            page: ChefSolidMicro(
                              recipe: widget.recipe,
                              variant: widget.variant,
                            ),
                          );
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
