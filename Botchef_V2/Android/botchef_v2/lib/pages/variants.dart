import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/pages/recipe.dart';
import 'package:botchef_v2/pages/variant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../commons.dart';
import '../partials/menu.dart';

class VariantsPage extends StatefulWidget {
  final RecipeModel data;
  const VariantsPage({super.key, required this.data});

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {
  RecipeServices recipeServices = RecipeServices();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {
              navigate(
                  type: Type.replace,
                  context: context,
                  page: RecipePage(data: widget.data));
            },
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(FontAwesomeIcons.pen),
            ),
          ),
          InkWell(
            onTap: () {
              recipeServices.delete(
                  id: widget.data.rid!, photoUrl: widget.data.photoUrl!);
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
                    widget.data.recipeName!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.data.photoUrl!,
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
                      "No. of times cooked: ${widget.data.noOfTimes} \n\nEarnings: ₹${widget.data.earnings}", // Price/recipe will be set by admin.
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
                  onPressed: () {
                    navigate(
                      type: Type.push,
                      context: context,
                      page: VariantPage(rid: widget.data.rid!),
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
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      onTap: () {
                        navigate(
                          type: Type.push,
                          context: context,
                          page: VariantPage(rid: widget.data.rid!),
                        );
                      },
                      leading: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
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
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  "Extreme",
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
                                  "${index + 1}",
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
}
