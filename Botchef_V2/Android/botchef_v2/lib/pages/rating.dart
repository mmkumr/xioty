import 'package:botchef_v2/db/favorite.dart';
import 'package:botchef_v2/db/history.dart';
import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../commons.dart';
import 'favorites.dart';

class RatingPage extends StatefulWidget {
  final VariantModel variant;
  const RatingPage({super.key, required this.variant});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  TextEditingController feedback = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  double rating = 0.0;

  VariantModel? variant;
  @override
  void initState() {
    Fluttertoast.showToast(msg: "Enjoy Your Delicious Food");
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await addHistory();
    await getVariant();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "It's Done! \nTotal time taken: ${variant!.cookingTime} Seconds \nEnjoy Your Delicious Food",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  "How would you like to rate the recipe",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RatingBar.builder(
                  initialRating: 3,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return const Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return const Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return const Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return const Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      default:
                        return const Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                    }
                  },
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
              ),
              Form(
                key: form,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: feedback,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Field can't be empty";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Any feedback?",
                      label: const Text("Feedback"),
                      fillColor: primaryC,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: MaterialButton(
                  minWidth: 300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: primaryC,
                  onPressed: () async {
                    final user = Provider.of<UserProvider>(context);
                    await FavoriteServices()
                        .update(uid: user.user.uid, rid: widget.variant.rid!);
                    Fluttertoast.showToast(msg: "Added recipe to favorites!");
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Add to Favorites",
                      style: TextStyle(
                        fontSize: 30,
                        color: primaryC.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: MaterialButton(
                  minWidth: 300,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () {
                    navigate(
                        type: PageType.push,
                        context: context,
                        page: const HomePage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Finish",
                      style: TextStyle(
                        fontSize: 30,
                        color: elementsC.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  addHistory() async {
    final user = Provider.of<UserProvider>(context);
    RecipeModel recipe = await RecipeServices().getById(widget.variant.rid!);
    HistoryServices().add(
        uid: user.user.uid,
        photoUrl: recipe.photoUrl,
        recipeName: recipe.recipeName,
        chefName: recipe.chefName);
  }

  getVariant() async {
    variant = await VariantServices().getById(widget.variant.vid!);
    setState(() {});
  }
}
