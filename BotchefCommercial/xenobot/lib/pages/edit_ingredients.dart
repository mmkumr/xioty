import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:xenobot/pages/my_recipes.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';

import '../commons.dart';
import '../db/recipes.dart';
import '../models/recipe.dart';

class EditIngredientsPage extends StatefulWidget {
  final RecipeModel recipe;
  const EditIngredientsPage({super.key, required this.recipe});

  @override
  State<EditIngredientsPage> createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  int nos = 0;
  @override
  void initState() {
    super.initState();
    bases = widget.recipe.base;
    sweetners = widget.recipe.sweetners;
    flavours = widget.recipe.flavors;
    nos = bases.length + sweetners.length + flavours.length;
  }

  @override
  void didChangeDependencies() async {
    await getIngredientsPrice();
    super.didChangeDependencies();
  }

  List<TextEditingController> quantities = [];
  TextEditingController priceController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> cupSizes = ["150 ml"];
  List bases = [];
  List sweetners = [];
  List flavours = [];
  int ingredientsTotalQuantity = 0,
      remainingQuantity = 0,
      desiredQuantity = 130;
  bool readOnly = false;
  Map? ingredientsPrices;
  int price = 0;
  bool start = false;
  @override
  Widget build(BuildContext context) {
    ingredientsTotalQuantity = 0;
    price = 0;
    for (var quantity in quantities) {
      ingredientsTotalQuantity += int.parse(quantity.text);
    }
    remainingQuantity = desiredQuantity - ingredientsTotalQuantity;
    int i = 0;
    for (var base in ingredientsPrices!["bases"]) {
      price += int.parse(base[base.keys.toList()[0]].toString()) *
          int.parse(quantities[i].text);
      i++;
    }
    for (var flavour in ingredientsPrices!["flavours"]) {
      price += int.parse(flavour[flavour.keys.toList()[0]].toString()) *
          int.parse(quantities[i].text);
      i++;
    }
    for (var sweetners in ingredientsPrices!["sweetners"]) {
      price += int.parse(sweetners[sweetners.keys.toList()[0]].toString()) *
          int.parse(quantities[i].text);
      i++;
    }
    setState(() {
      priceController.text = price.toString();
    });
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                Text(
                  widget.recipe.name,
                  softWrap: true,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: ListTile(
                    trailing: Text(
                      "$ingredientsTotalQuantity ml",
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 20,
                        color: ingredientsTotalQuantity > 130
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Cup Size ${cupSizes[0]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            readOnly: true,
                            controller: priceController,
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                for (int index = 0;
                    index < ingredientsPrices!["bases"].length;
                    index++)
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
                              ingredientsPrices!["bases"][index]
                                  .keys
                                  .toList()[0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: NumberInputWithIncrementDecrement(
                              initialValue: bases[index],
                              controller: quantities[index],
                              min: 0,
                              max: start
                                  ? int.parse(quantities[index].text) +
                                      remainingQuantity
                                  : desiredQuantity,
                              onIncrement: (newValue) {
                                updateBaseText(newValue, index);
                              },
                              onDecrement: (newValue) {
                                updateBaseText(newValue, index);
                              },
                              onSubmitted: (newValue) {
                                updateBaseText(newValue, index);
                              },
                              onChanged: (newValue) {
                                updateBaseText(newValue, index);
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                for (int index = 0;
                    index < ingredientsPrices!["sweetners"].length;
                    index++)
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
                              ingredientsPrices!["sweetners"][index]
                                  .keys
                                  .toList()[0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: NumberInputWithIncrementDecrement(
                              initialValue: sweetners[index],
                              controller: quantities[index + bases.length],
                              min: 0,
                              max: start
                                  ? int.parse(quantities[index + bases.length]
                                          .text) +
                                      remainingQuantity
                                  : desiredQuantity,
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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                for (int index = 0;
                    index < ingredientsPrices!["flavours"].length;
                    index++)
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
                              ingredientsPrices!["flavours"][index]
                                  .keys
                                  .toList()[0],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: NumberInputWithIncrementDecrement(
                              initialValue: flavours[index],
                              controller: quantities[
                                  index + bases.length + sweetners.length],
                              min: 0,
                              max: start
                                  ? int.parse(quantities[index +
                                              bases.length +
                                              sweetners.length]
                                          .text) +
                                      remainingQuantity
                                  : desiredQuantity,
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
                      int i = 0;
                      List basesList = [],
                          flavoursList = [],
                          sweetnersList = [];
                      for (var base in ingredientsPrices!["bases"]) {
                        basesList.add(int.parse(quantities[i].text));
                        i++;
                      }
                      for (var flavour in ingredientsPrices!["flavours"]) {
                        flavoursList.add(int.parse(quantities[i].text));
                        i++;
                      }
                      for (var sweetner in ingredientsPrices!["sweetners"]) {
                        sweetnersList.add(int.parse(quantities[i].text));
                        i++;
                      }
                      RecipeServices recipeServices = RecipeServices();
                      await recipeServices.update(
                        rid: widget.recipe.rid,
                        name: widget.recipe.name,
                        description: widget.recipe.description,
                        base: basesList,
                        flavors: flavoursList,
                        sweetners: sweetnersList,
                        imageUrl: "",
                        price: price,
                      );
                      if (!context.mounted) return;
                      navigate(
                          type: PageType.replace,
                          context: context,
                          page: const MyRecipes());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 10, bottom: 10),
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
      ),
    );
  }

  // Function for updating the state after any event of the number_inc_dec widget in Base values section to update the ingredientsTotalQuantity variable.
  updateBaseText(num newValue, int index) {
    setState(() {
      quantities[index].text = newValue.toString();
    });
  }

  // Function for updating the state after any event of the number_inc_dec widget in Sweetners values section to update the ingredientsTotalQuantity variable.
  updateSweetnersText(num newValue, int index) {
    setState(() {
      quantities[index + bases.length].text = newValue.toString();
    });
  }

  // Function for updating the state after any event of the number_inc_dec widget in Sweetners values section to update the ingredientsTotalQuantity variable.
  updateFlavoursText(num newValue, int index) {
    setState(() {
      quantities[index + bases.length + sweetners.length].text =
          newValue.toString();
    });
  }

  getIngredientsPrice() async {
    await FirebaseFirestore.instance
        .collection("ingredientsPrice")
        .doc("0")
        .get()
        .then((value) {
      setState(() {
        ingredientsPrices = value.data();
        priceController.text = widget.recipe.price.toString();

        for (var base in bases) {
          quantities.add(TextEditingController(text: base.toString()));
        }
        debugPrint(
            (int.parse(quantities[0].text) + remainingQuantity).toString());
        for (var sweetner in sweetners) {
          quantities.add(TextEditingController(text: sweetner.toString()));
        }
        for (var flavour in flavours) {
          quantities.add(TextEditingController(text: flavour.toString()));
        }
        start = true;
      });
    });
  }
}
