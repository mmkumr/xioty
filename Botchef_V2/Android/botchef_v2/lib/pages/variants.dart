import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/recipe.dart';
import 'package:botchef_v2/pages/variant.dart';
import 'package:botchef_v2/pages/your_recipes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../commons.dart';
import '../partials/menu.dart';

class VariantsPage extends StatefulWidget {
  final RecipeModel recipe;
  const VariantsPage({super.key, required this.recipe});

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {
  RecipeServices recipeServices = RecipeServices();
  List<VariantModel>? variants;
  @override
  void didChangeDependencies() {
    getVariants();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              navigate(
                  type: PageType.replace,
                  context: context,
                  page: RecipePage(data: widget.recipe));
            },
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(FontAwesomeIcons.pen),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              recipeServices.delete(
                  id: widget.recipe.rid!, photoUrl: widget.recipe.photoUrl!);
              navigate(
                  type: PageType.replace,
                  context: context,
                  page: const YourRecipesPage());
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
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 200,
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 250,
                height: 120,
                decoration: BoxDecoration(
                  color: primaryC,
                  borderRadius: const BorderRadius.all(Radius.circular(60)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Text(
                      "No. of times cooked: ${widget.recipe.noOfTimes} \n\nEarnings: ₹${widget.recipe.earnings}", // Price/recipe will be set by admin.
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: MaterialButton(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () async {
                    if (!context.mounted) return;
                    navigate(
                      type: PageType.replace,
                      context: context,
                      page: VariantPage(recipe: widget.recipe),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "New Variant",
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
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 30.0, bottom: 20),
                child: Text(
                  "Variants",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                itemCount: variants!.length,
                itemBuilder: (context, index) {
                  VariantModel variant = variants![index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () {
                        navigate(
                          type: PageType.push,
                          context: context,
                          page: VariantPage(
                            recipe: widget.recipe,
                            variant: variant,
                          ),
                        );
                      },
                      leading: CachedNetworkImage(
                        imageUrl: widget.recipe.photoUrl!,
                        fit: BoxFit.fill,
                      ),
                      subtitle: Wrap(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryC,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(60)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "Spricy: ${variant.spicy}",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryC,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(60)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "Portion size: ${variant.portionSize}",
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getVariants() async {
    VariantServices variantServices = VariantServices();
    variants = await variantServices.getVariants(widget.recipe.rid!);
    setState(() {
      variants;
    });
  }
}
