import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/menu.dart';
import 'recipe_customize.dart';

class CustomerMyRecipe extends StatefulWidget {
  const CustomerMyRecipe({super.key});

  @override
  State<CustomerMyRecipe> createState() => _CustomerMyRecipeState();
}

class _CustomerMyRecipeState extends State<CustomerMyRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("Customized Recipes"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
            child: ListTile(
              onTap: () {
                navigate(
                    type: PageType.push,
                    context: context,
                    page: const CustomizeRecipePage());
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
              title: const Text(
                "Irani Tea",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
