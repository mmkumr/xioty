// ignore_for_file: unused_element

/*
[12:43 pm, 16/09/2024] Eswar Dora(Xioty Solution): 150, 250, 350
[12:43 pm, 16/09/2024] Eswar Dora(Xioty Solution): ml
*/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:xenobot/models/recipe.dart';
import 'package:xenobot/pages/checkout.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';

import '../commons.dart';
import '../db/ingredients_prices.dart';
import '../models/ingredients_price.dart';

class RecipeInfoPage extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeInfoPage({super.key, required this.recipe});

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  int nos = 6;
  @override
  void initState() {
    super.initState();
    bases = widget.recipe.base;
    sweetners = widget.recipe.sweetners;
    flavours = widget.recipe.flavors;
    nos = bases.length + sweetners.length + flavours.length;
    cupSize = cupSizes[0];
  }

  @override
  void didChangeDependencies() async {
    await getIngredientsPrice();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  String cupSize = "";
  List<String> cupSizes = [
    "150 ml",
    "250 ml",
    "350 ml",
  ];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<TextEditingController> quantities = [];
  List bases = [];
  List sweetners = [];
  List flavours = [];
  IngredientsPriceModel? ingredientsPrices;

  int price = 0;
  int ingredientsTotalQuantity = 0,
      remainingQuantity = 0,
      desiredQuantity = 130;
  Razorpay razorpay = Razorpay();

  @override
  Widget build(BuildContext context) {
    desiredQuantity = int.parse(cupSize.replaceAll(" ml", "")) - 20;
    ingredientsTotalQuantity = 0;
    price = 0;
    for (var quantity in quantities) {
      ingredientsTotalQuantity += int.parse(quantity.text);
    }
    remainingQuantity = desiredQuantity - ingredientsTotalQuantity;
    int i = 0;
    for (var base in ingredientsPrices!.bases) {
      price += base.value * int.parse(quantities[i].text);
      i++;
    }
    for (var sweetner in ingredientsPrices!.sweetners) {
      price += sweetner.value * int.parse(quantities[i].text);
      i++;
    }
    for (var flavour in ingredientsPrices!.flavours) {
      price += flavour.value * int.parse(quantities[i].text);
      i++;
    }

    setState(() {
      price;
    });
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: Center(
        child: SingleChildScrollView(
          child: Flexible(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 100,
                      backgroundImage: CachedNetworkImageProvider(
                          "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
                    ),
                  ),
                  Text(
                    widget.recipe.name,
                    softWrap: true,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Cup Size"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: width(context) * 0.3,
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
                                  desiredQuantity =
                                      int.parse(cupSize.replaceAll(" ml", "")) -
                                          20;
                                  int i = 0;
                                  for (var base in bases) {
                                    quantities[i].text =
                                        ((desiredQuantity / 130) * base)
                                            .round()
                                            .toString();
                                    i++;
                                  }
                                  for (var sweetner in sweetners) {
                                    quantities[i].text =
                                        ((desiredQuantity / 130) * sweetner)
                                            .round()
                                            .toString();
                                    i++;
                                  }
                                  for (var flavour in flavours) {
                                    debugPrint(quantities[i].text);
                                    quantities[i].text =
                                        ((desiredQuantity / 130) * flavour)
                                            .round()
                                            .toString();
                                    i++;
                                  }
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: "Cup Size",
                              ),
                            ),
                          ),
                        ),
                      ],
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
                            page: const CheckoutPage());
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10, bottom: 10),
                        child: Text(
                          "Buy Regular",
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
                  const Text(
                    "Customize",
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 5,
                          ),
                        ),
                      ],
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
                                ingredientsPrices!.sweetners[index].key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: NumberInputWithIncrementDecrement(
                                initialValue: sweetners[index],
                                controller: quantities[index + bases.length],
                                min: 0,
                                max: int.parse(
                                        quantities[index + bases.length].text) +
                                    remainingQuantity,
                                onIncrement: (newValue) {
                                  updateSweetnersText(newValue, index);
                                },
                                onDecrement: (newValue) {
                                  updateSweetnersText(newValue, index);
                                },
                                onSubmitted: (newValue) {
                                  updateSweetnersText(newValue, index);
                                },
                                onChanged: (newValue) {
                                  updateSweetnersText(newValue, index);
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
                                ingredientsPrices!.flavours[index].key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: NumberInputWithIncrementDecrement(
                                initialValue: flavours[index],
                                controller: quantities[
                                    index + bases.length + sweetners.length],
                                min: 0,
                                max: int.parse(quantities[index +
                                            bases.length +
                                            sweetners.length]
                                        .text) +
                                    remainingQuantity,
                                onIncrement: (newValue) {
                                  updateFlavoursText(newValue, index);
                                },
                                onDecrement: (newValue) {
                                  updateFlavoursText(newValue, index);
                                },
                                onSubmitted: (newValue) {
                                  updateFlavoursText(newValue, index);
                                },
                                onChanged: (newValue) {
                                  updateFlavoursText(newValue, index);
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
                        await savePreference();
                        if (context.mounted) {
                          navigate(
                              type: PageType.replace,
                              context: context,
                              page: const CheckoutPage());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 10, bottom: 10),
                        child: Text(
                          "Order Now",
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
      bottomNavigationBar: Container(
        color: primaryC,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Total Price: ₹$price",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  savePreference() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Would you like to save your preference"),
        content: TextFormField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: "Name",
            hintText: "Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return "Invalid input";
            }
            return null;
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Save")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Don't Save"))
        ],
      ),
    );
  }

  // Function for updating the state after any event of the number_inc_dec widget in Sweetners values section to update the ingredientsTotalQuantity variable.
  updateSweetnersText(num newValue, int index) {
    setState(() {
      quantities[index].text = newValue.toString();
    });
  }

  // Function for updating the state after any event of the number_inc_dec widget in Sweetners values section to update the ingredientsTotalQuantity variable.
  updateFlavoursText(num newValue, int index) {
    setState(() {
      quantities[index + sweetners.length].text = newValue.toString();
    });
  }

  getIngredientsPrice() async {
    await IngredientsPricesServices().get().then((value) {
      setState(() {
        ingredientsPrices = value;
        price = widget.recipe.price;

        for (var base in bases) {
          quantities.add(TextEditingController(text: base.toString()));
        }
        for (var sweetner in sweetners) {
          quantities.add(TextEditingController(text: sweetner.toString()));
        }
        for (var flavour in flavours) {
          quantities.add(TextEditingController(text: flavour.toString()));
        }
      });
    });
  }
}
