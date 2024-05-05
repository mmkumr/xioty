import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/cooking.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/description_popup.dart';
import '../partials/menu.dart';

class UserMicroPage extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  const UserMicroPage({super.key, required this.variant, required this.recipe});

  @override
  State<UserMicroPage> createState() => _UserMicroPageState();
}

class _UserMicroPageState extends State<UserMicroPage> {
  @override
  void initState() {
    quantity = List.generate(
        4,
        (index) => TextEditingController(
            text: widget.variant.liquidMicros![index]["quantity"]));
    quantity = quantity! +
        List.generate(
            8,
            (index) => TextEditingController(
                text: widget.variant.solidMicros![index]["quantity"]));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  ScrollController scrollController = ScrollController();
  bool start = false;
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<TextEditingController>? quantity;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(Icons.save, size: 40),
            ),
          ),
        ],
        elevation: 0,
      ),
      drawer: menu(context),
      body: SingleChildScrollView(
        reverse: start,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const Text(
                "Liquid Micros",
                style: TextStyle(fontSize: 30),
              ),
              ListView.builder(
                itemCount: widget.variant.liquidMicros!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Map liquidMicro = widget.variant.liquidMicros![index];
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Container(
                        width: width(context) * 0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryC,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(60),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: Text(
                              liquidMicro['name'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      title: TextFormField(
                        onTap: () {
                          if (!start) {
                            setState(() {
                              start = true;
                            });
                          }
                        },
                        controller: quantity![index],
                        decoration: InputDecoration(
                          hintText: "tsp",
                          label: const Text("tsp"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () {
                          mimaDescriptionPopup(context);
                        },
                        child: const Icon(Icons.info),
                      ),
                    ),
                  );
                },
              ),
              const Text(
                "Solid Micros",
                style: TextStyle(fontSize: 30),
              ),
              ListView.builder(
                itemCount: widget.variant.solidMicros!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Container(
                        width: width(context) * 0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryC,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(60),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: Text(
                              widget.variant.solidMicros![index]["name"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      title: TextFormField(
                        onTap: () {
                          if (!start) {
                            setState(() {
                              start = true;
                            });
                          }
                        },
                        controller: quantity![index + 4],
                        decoration: InputDecoration(
                          hintText: "tsp",
                          label: const Text("tsp"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () {
                          mimaDescriptionPopup(context);
                        },
                        child: const Icon(Icons.info),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: MaterialButton(
                  minWidth: 300,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () {
                    navigate(
                        type: PageType.replace,
                        context: context,
                        page: CookingPage(variant: widget.variant));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Let's Cook",
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
}
