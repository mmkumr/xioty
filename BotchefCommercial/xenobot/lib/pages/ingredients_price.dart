import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../commons.dart';
import '../db/ingredients_prices.dart';
import '../models/ingredients_price.dart';

class IngredientsPricePage extends StatefulWidget {
  const IngredientsPricePage({super.key});

  @override
  State<IngredientsPricePage> createState() => _IngredientsPricePageState();
}

class _IngredientsPricePageState extends State<IngredientsPricePage> {
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getIngredientsPrice();
  }

  List<TextEditingController> bases = [];
  List<TextEditingController> flavours = [];
  List<TextEditingController> sweetners = [];

  IngredientsPriceModel? ingredientsPrices;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredients Prices"),
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Base",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0;
                  index < ingredientsPrices!.bases.length;
                  index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  ingredientsPrices!.bases[index].key,
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: bases[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xfff6f2f2),
                              label: const Text(
                                "₹/ml",
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
                    "Sweetners",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0;
                  index < ingredientsPrices!.sweetners.length;
                  index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  ingredientsPrices!.sweetners[index].key,
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: sweetners[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xfff6f2f2),
                              label: const Text(
                                "₹/ml",
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
                    "Flavours",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              for (int index = 0;
                  index < ingredientsPrices!.flavours.length;
                  index++)
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: primaryC,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Text(
                                  ingredientsPrices!.flavours[index].key,
                                  softWrap: true,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: flavours[index],
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xfff6f2f2),
                              label: const Text(
                                "₹/ml",
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
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MaterialButton(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: elementsC,
                  onPressed: () async {
                    List<Map<String, int>> basePrices = List.generate(
                        ingredientsPrices!.bases.length, (int index) {
                      return {
                        ingredientsPrices!.bases[index].key:
                            int.parse(bases[index].text)
                      };
                    });
                    List<Map<String, int>> sweetnerPrices = List.generate(
                        ingredientsPrices!.sweetners.length, (int index) {
                      return {
                        ingredientsPrices!.sweetners[index].key:
                            int.parse(sweetners[index].text)
                      };
                    });
                    List<Map<String, int>> flavourPrices = List.generate(
                        ingredientsPrices!.flavours.length, (int index) {
                      return {
                        ingredientsPrices!.flavours[index].key:
                            int.parse(flavours[index].text)
                      };
                    });
                    await IngredientPriceServices()
                        .update(basePrices, sweetnerPrices, flavourPrices);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 10, bottom: 10),
                    child: Text(
                      "Save",
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

  getIngredientsPrice() async {
    await IngredientPriceServices().get().then((value) {
      setState(() {
        ingredientsPrices = value;
        bases = List.generate(ingredientsPrices!.bases.length, (int index) {
          return TextEditingController(
              text: ingredientsPrices!.bases[index].value.toString());
        });
        sweetners =
            List.generate(ingredientsPrices!.sweetners.length, (int index) {
          return TextEditingController(
              text: ingredientsPrices!.sweetners[index].value.toString());
        });
        flavours =
            List.generate(ingredientsPrices!.flavours.length, (int index) {
          return TextEditingController(
              text: ingredientsPrices!.flavours[index].value.toString());
        });
      });
    });
  }
}
