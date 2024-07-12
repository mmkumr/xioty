import 'package:botchef_v2_admin/commons.dart';
import 'package:botchef_v2_admin/pages/pulished_recipes.dart';
import 'package:botchef_v2_admin/pages/unpulished_recipes.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xara Admin"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryC,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: ListTile(
                  onTap: () {
                    navigate(
                        type: PageType.push,
                        context: context,
                        page: const UnpublishedRecipes());
                  },
                  title: const Text("Unpublished recipes"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryC,
                  border: Border.all(),
                  borderRadius: const BorderRadius.all(Radius.circular(40)),
                ),
                child: ListTile(
                  onTap: () {
                    navigate(
                        type: PageType.push,
                        context: context,
                        page: const PublishedRecipes());
                  },
                  title: const Text("Published recipes"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
