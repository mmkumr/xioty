import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xenobot/pages/chef_my_recipes.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';

import '../commons.dart';

class ConfirmIngredientsPage extends StatefulWidget {
  const ConfirmIngredientsPage({super.key});

  @override
  State<ConfirmIngredientsPage> createState() => _ConfirmIngredientsPageState();
}

class _ConfirmIngredientsPageState extends State<ConfirmIngredientsPage> {
  int nos = 11;
  @override
  void initState() {
    super.initState();
    quantities =
        List.generate(nos, (index) => TextEditingController(text: "0"));
  }

  List<TextEditingController> quantities = [];
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> cupSizes = ["150 ml", "250 ml", "350 ml"];
  List<String> bases = ["Milk", "Evaporated Milk", "Black Tea", "Green Tea"];
  List sweetners = ["Sugar", "Honey", "Jagery"];
  List flavours = ["Chocolate", "Masala", "Rose"];
  int ingredientsTotalQuantity = 0;
  String cupSize = "150 ml";
  @override
  Widget build(BuildContext context) {
    ingredientsTotalQuantity = 0;
    for (var quantity in quantities) {
      ingredientsTotalQuantity += int.parse(quantity.text);
    }
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: Flexible(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Verify Ingredients quantity & Price",
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 80,
                        backgroundImage: CachedNetworkImageProvider(
                            "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
                      ),
                    ),
                  ),
                  const Text(
                    "Irani Tea",
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: ListTile(
                      leading: const Text(
                        "Cup Size",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              value: cupSize,
                              items: cupSizes.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  cupSize = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Cup Size",
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              controller: quantities[0],
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xfff6f2f2),
                                label: const Text(
                                  "Price",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter valid Price";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Base",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  for (int index = 0; index < bases.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: ListTile(
                        trailing: const Text(
                          "ml",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                bases[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                controller: quantities[index + 1],
                                style: const TextStyle(color: Colors.black),
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    setState(() {});
                                  }
                                },
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xfff6f2f2),
                                  label: const Text(
                                    "ml",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter valid quantity";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Sweetners",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  for (int index = 0; index < sweetners.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: ListTile(
                        trailing: const Text(
                          "ml",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sweetners[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    setState(() {});
                                  }
                                },
                                controller:
                                    quantities[index + 1 + bases.length],
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xfff6f2f2),
                                  label: const Text(
                                    "ml",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter valid quantity";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Flavours",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                  for (int index = 0; index < flavours.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: ListTile(
                        trailing: const Text(
                          "ml",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                flavours[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                onChanged: (val) {
                                  if (val.isNotEmpty) {
                                    setState(() {});
                                  }
                                },
                                controller: quantities[index +
                                    1 +
                                    bases.length +
                                    sweetners.length],
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xfff6f2f2),
                                  label: const Text(
                                    "ml",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter valid quantity";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: MaterialButton(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: elementsC,
                      onPressed: () {
                        navigate(
                            type: PageType.replace,
                            context: context,
                            page: const ChefMyRecipe());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10, bottom: 10),
                        child: Text(
                          "Confirm",
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
        ),
      ),
    );
  }
}
