import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../commons.dart';
import '../partials/menu.dart';

class RecipeInfoPage extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeInfoPage({super.key, required this.recipe});

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  ScrollController scrollController = ScrollController();
  List<VariantModel> variants = [];
  Map variantButtons = {};
  String selectedSpicy = "";
  String selectedPortionSize = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(
                Icons.favorite_outline,
                color: Colors.red,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      drawer: menu(context),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: 250,
                child: GridTile(
                  footer: Container(
                    color: Colors.white,
                    child: Text(
                      widget.recipe.recipeName!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      widget.recipe.photoUrl!,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(right: 5.0),
                            child: Icon(
                              Icons.alarm_rounded,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const TextSpan(
                          text: "2 hours",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 5.0),
                            child: Icon(
                              Icons.star_outline,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const TextSpan(
                          text: "4.8",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 5.0),
                            child: Icon(
                              FontAwesomeIcons.fireFlameCurved,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: widget.recipe.calories,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
                child: Text(
                  widget.recipe.description!,
                  maxLines: 15,
                  textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Wrap(
                children: [
                  for (int i = 0; i < variantButtons.keys.length; i++)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedSpicy = variantButtons.keys.toList()[i];
                            selectedPortionSize =
                                variantButtons[selectedSpicy][0];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                selectedSpicy == variantButtons.keys.toList()[i]
                                    ? primaryC
                                    : Colors.white,
                            border: Border.all(width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              variantButtons.keys.toList()[i],
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Wrap(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0, right: 20),
                    child: Text(
                      "Portion Size",
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                  ),
                  for (int i = 0; i < variantButtons[selectedSpicy].length; i++)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedPortionSize =
                                variantButtons[selectedSpicy][i];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedPortionSize ==
                                    variantButtons[selectedSpicy][i]
                                ? Colors.grey
                                : Colors.white,
                            border: Border.all(width: 3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(60),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              variantButtons[selectedSpicy][i],
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                    VariantModel variant = variants
                        .where((element) =>
                            element.spicy == selectedSpicy &&
                            element.portionSize == selectedPortionSize)
                        .toList()[0];
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

  @override
  void didChangeDependencies() {
    getVariants();
    super.didChangeDependencies();
  }

  getVariants() async {
    VariantServices variantServices = VariantServices();
    variants = await variantServices.getVariants(widget.recipe.rid!);
    for (VariantModel variant in variants) {
      variantButtons[variant.spicy] = [];
    }
    for (VariantModel variant in variants) {
      variantButtons[variant.spicy].add(variant.portionSize);
    }
    setState(() {
      selectedSpicy = variantButtons.keys.toList()[0];
      selectedPortionSize = variantButtons[selectedSpicy][0];
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
    super.initState();
  }
}
