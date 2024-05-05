import 'package:botchef_v2/db/favorite.dart';
import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/pages/recipe_info.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commons.dart';
import '../partials/appbar.dart';
import '../partials/menu.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<RecipeModel> favorites = [];
  @override
  void didChangeDependencies() {
    getFavorites();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Favourites",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  height: height(context) * 0.8,
                  child: GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            navigate(
                                type: PageType.push,
                                context: context,
                                page: RecipeInfoPage(recipe: favorites[index]));
                          },
                          child: GridTile(
                            footer: Container(
                              color: Colors.white,
                              child: Text(
                                favorites[index].recipeName!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: favorites[index].photoUrl!,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  getFavorites() async {
    final user = Provider.of<UserProvider>(context);
    FavoriteServices favoriteServices = FavoriteServices();
    List favtemp = await favoriteServices.getById(uid: user.user.uid);
    for (var fav in favtemp) {
      try {
        RecipeModel favorite = await RecipeServices().getById(fav);
        favorites.add(favorite);
      } catch (e) {
        favoriteServices.delete(uid: user.user.uid, rid: fav);
      }
    }
    setState(() {});
  }
}
