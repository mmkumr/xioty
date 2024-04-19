import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/chef_macro.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:flutter/material.dart';

import '../partials/menu.dart';

class VariantPage extends StatefulWidget {
  final String rid;
  const VariantPage({super.key, required this.rid});

  @override
  State<VariantPage> createState() => _VariantPageState();
}

class _VariantPageState extends State<VariantPage> {
  TextEditingController description = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  @override
  void initState() {
    description.text =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    category = categories[0];
    spicy = spicyTypes[0];
    portionSize = portionSizes[0];
    super.initState();
  }

  List<String> categories = [
    "Rice",
    "One Pot Meal",
    "Curry",
    "Stir fry",
  ];
  String? category;
  List<String> spicyTypes = [
    "Mild",
    "Mediium",
    "Extreme",
  ];
  String? spicy;
  List<String> portionSizes = [
    "2",
    "4",
  ];
  String? portionSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: GridTile(
                  footer: Container(
                    color: Colors.white,
                    child: const Text(
                      "Chicken Pakoda",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  child: Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Form(
                key: form,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        maxLines: (height(context) * 0.015).round(),
                        controller: description,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be empty";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Description",
                          label: const Text("Description"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DropdownButtonFormField(
                        value: category,
                        items: categories.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            category = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Type",
                          label: const Text("Type"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DropdownButtonFormField(
                        value: spicy,
                        items: spicyTypes.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            spicy = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Spicy",
                          label: const Text("Spicy"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DropdownButtonFormField(
                        value: portionSize,
                        items: portionSizes.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            portionSize = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Portion Size",
                          label: const Text("Portion Size"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: MaterialButton(
                  elevation: 10,
                  minWidth: 250,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () {
                    navigate(
                      type: Type.push,
                      context: context,
                      page: const ChefMacroPage(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Next",
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
            ],
          ),
        ),
      ),
    );
  }
}
