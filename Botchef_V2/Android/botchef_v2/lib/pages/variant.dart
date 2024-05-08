import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/chef_macro.dart';
import 'package:botchef_v2/pages/variants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';

class VariantPage extends StatefulWidget {
  final RecipeModel recipe;
  final VariantModel? variant;
  const VariantPage({super.key, required this.recipe, this.variant});

  @override
  State<VariantPage> createState() => _VariantPageState();
}

class _VariantPageState extends State<VariantPage> {
  TextEditingController description = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  @override
  void initState() {
    if (widget.variant != null) {
      description.text = widget.variant!.description!;
      spicy = widget.variant!.spicy;
      portionSize = widget.variant!.portionSize!;
    } else {
      spicy = spicyTypes[0];
      portionSize = portionSizes[0];
    }
    super.initState();
  }

  List<String> spicyTypes = [
    "Mild",
    "Medium",
    "Extreme",
  ];
  String? spicy;
  List<String> portionSizes = [
    "2",
    "4",
  ];
  String? portionSize;
  bool loading = false;
  VariantServices variantServices = VariantServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {
              variantServices.delete(widget.variant!.vid!);
              Navigator.pop(context);
              navigate(
                  type: PageType.replace,
                  context: context,
                  page: VariantsPage(
                    recipe: widget.recipe,
                  ));
            },
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(
                FontAwesomeIcons.trash,
                color: Colors.red,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
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
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextFormField(
                              maxLines: (height(context) * 0.015).round(),
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
                            child: DropdownButtonFormField(
                              value: spicy,
                              items: spicyTypes.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  spicy = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Spice level",
                                label: const Text("Spice level"),
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
                              value: portionSize,
                              items: portionSizes.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  portionSize = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Portion Size",
                                label: const Text("Portion Size"),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor: primaryC,
                              ),
                            ),
                          )
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
                          if (form.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            VariantServices variantServices = VariantServices();
                            if (widget.variant == null) {
                              variantServices.create(
                                  rid: widget.recipe.rid!,
                                  description: description.text,
                                  spicy: spicy!,
                                  portionSize: portionSize!);
                            } else {
                              variantServices.update(
                                  vid: widget.variant!.vid!,
                                  description: description.text,
                                  spicy: spicy!,
                                  portionSize: portionSize!);
                            }
                            setState(() {
                              loading = false;
                            });
                            if (widget.variant != null) {
                              navigate(
                                type: PageType.replace,
                                context: context,
                                page: ChefMacroPage(
                                  variant: widget.variant!,
                                  recipe: widget.recipe,
                                ),
                              );
                            } else {
                              var recipe = await RecipeServices()
                                  .getById(widget.recipe.rid!);
                              if (!context.mounted) return;
                              navigate(
                                type: PageType.replace,
                                context: context,
                                page: VariantsPage(recipe: recipe),
                              );
                            }
                          }
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
