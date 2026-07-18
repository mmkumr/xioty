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
              child: variants == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: variants!.length,
                      itemBuilder: (context, index) {
                        VariantModel variant = variants![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          // FIX 1: Wrap in a Card to enforce strict horizontal boundaries
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () async {
                                variant = await VariantServices()
                                    .getById(variant.vid!);
                                if (!context.mounted) return;
                                navigate(
                                  type: PageType.push,
                                  context: context,
                                  page: VariantPage(
                                    recipe: widget.recipe,
                                    variant: variant,
                                  ),
                                );
                              },
                              // FIX 2: Restrict the cross-axis sizing configuration
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.recipe.photoUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                "Variant #${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primaryC,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(60)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 6.0),
                                        child: Text(
                                          "Spicy: ${variant.spicy}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primaryC,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(60)),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 6.0),
                                        child: Text(
                                          "Portion size: ${variant.portionSize}",
                                          style: const TextStyle(fontSize: 12),
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
