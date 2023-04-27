import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'db/recipes.dart';
import 'details.dart';
import 'layouts/commons.dart';
import 'predetails.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({super.key});

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  @override
  void initState() {
    super.initState();
    getAllRecipe();
  }

  List<DocumentSnapshot> recipes = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: Text('Recipe'),
        backgroundColor: Color(0xff9a94c8),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              style: NeumorphicStyle(
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 10,
                color: fgC,
              ),
              child: ListTile(
                  onTap: () {
                    navigate('p', context, PreDetails(id: recipes[index].id));
                  },
                  title: Text(recipes[index]['name']),
                  trailing: InkWell(
                    onTap: () async {
                      RecipesServices recipesServices = RecipesServices();
                      await recipesServices.removeRecipe(recipes[index].id);
                      getAllRecipe();
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: NeumorphicButton(
        style: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(32)),
          depth: 10,
          color: elementsC,
        ),
        child: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.spoon),
              Text(
                'Add new recipe',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        onPressed: () {
          navigate('p', context, Details());
        },
      ),
    );
  }

  getAllRecipe() async {
    RecipesServices recipesServices = RecipesServices();
    await recipesServices.getAllRecipes().then((value) {
      setState(() {
        recipes = value;
      });
    });
  }
}
