import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:botchef_v2/partials/description_popup.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/menu.dart';
import 'user_micro.dart';

class UserMacroPage extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  final List? solidMicros;
  final List? liquidMicros;
  const UserMacroPage({
    super.key,
    required this.recipe,
    required this.variant,
    this.solidMicros,
    this.liquidMicros,
  });

  @override
  State<UserMacroPage> createState() => _UserMacroPageState();
}

class _UserMacroPageState extends State<UserMacroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: Column(
        children: [
          const Text(
            "Macros",
            style: TextStyle(fontSize: 30),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: widget.variant.macros!.length,
              itemBuilder: (context, index) {
                Map macro = widget.variant.macros![index];
                return macro.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          leading: Text((index + 1).toString()),
                          title: Container(
                            decoration: BoxDecoration(
                              color: primaryC,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(60),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${macro["name"]} ${macro["quantity"]}",
                                style: const TextStyle(fontSize: 15),
                                softWrap: true,
                                textAlign: TextAlign.left,
                              ),
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
                if (widget.solidMicros == null) {
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: UserMicroPage(
                        recipe: widget.recipe,
                        variant: widget.variant,
                      ));
                } else {
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: UserMicroPage(
                        recipe: widget.recipe,
                        variant: widget.variant,
                        solidMicros: widget.solidMicros,
                        liquidMicros: widget.liquidMicros,
                      ));
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Next",
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
    );
  }
}
