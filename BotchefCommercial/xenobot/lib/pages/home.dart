import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/pages/recipe_info.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';
import 'package:xenobot/providers/kiosk_provide.dart';

import '../db/recipes.dart';
import '../models/recipe.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<RecipeModel> kioskRecipes = [];
  @override
  void didChangeDependencies() {
    getMyRecipes();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: kioskRecipes.isEmpty
          ? const Center(
              child: Text("No recipes found!"),
            )
          : ListView.builder(
              itemCount: kioskRecipes.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                  child: ListTile(
                    onTap: () {
                      navigate(
                          type: PageType.push,
                          context: context,
                          page: const RecipeInfoPage());
                    },
                    tileColor: Colors.black12,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(32),
                      ),
                    ),
                    leading: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundImage: CachedNetworkImageProvider(
                            "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
                      ),
                    ),
                    title: Text(
                      kioskRecipes[index].name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        children: [
                          const WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Icon(
                                Icons.star_outline,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: "${kioskRecipes[index].rating}\n",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "${kioskRecipes[index].noOfRatings} ratings",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Text(
                      "₹${kioskRecipes[index].price}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }

  getMyRecipes() async {
    final kiosk = Provider.of<KioskProvider>(context);
    kioskRecipes =
        await RecipeServices().getKioskRecipes(kid: kiosk.kioskModel.id);
    setState(() {});
  }
}
