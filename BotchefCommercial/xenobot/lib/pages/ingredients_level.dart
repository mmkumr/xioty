import 'package:flutter/material.dart';
import 'package:xenobot/db/kiosks.dart';
import 'package:xenobot/models/kiosk.dart';

import '../commons.dart';
import '../db/ingredients_prices.dart';
import '../models/ingredients_price.dart';

class IngredientsLevelPage extends StatefulWidget {
  final KioskModel kiosk;
  const IngredientsLevelPage({super.key, required this.kiosk});

  @override
  State<IngredientsLevelPage> createState() => _IngredientsLevelPageState();
}

class _IngredientsLevelPageState extends State<IngredientsLevelPage> {
  @override
  void didChangeDependencies() async {
    await getIngredientsPrice();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    setState(() {
      bases = widget.kiosk.bases;
      flavours = widget.kiosk.flavours;
      sweetners = widget.kiosk.sweetners;
    });
    super.initState();
  }

  List bases = [];
  List flavours = [];
  List sweetners = [];
  int refillCount = 456;

  IngredientsPriceModel? ingredientsPrices;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingredients Level"),
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Kiosk ID: ${widget.kiosk.id}",
                softWrap: true,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: ListTile(
                  trailing: IconButton(
                      onPressed: () {
                        for (var i = 0;
                            i < ingredientsPrices!.bases.length;
                            i++) {
                          bases[i] = refillCount;
                        }
                        for (var i = 0;
                            i < ingredientsPrices!.sweetners.length;
                            i++) {
                          sweetners[i] = refillCount;
                        }
                        for (var i = 0;
                            i < ingredientsPrices!.flavours.length;
                            i++) {
                          flavours[i] = refillCount;
                        }
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh)),
                  title: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            color: primaryC,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 8.0,
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: Text(
                                "Refill all",
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
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
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            bases[index] = refillCount;
                          });
                        },
                        icon: const Icon(Icons.refresh)),
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
                                  bases[index].toString(),
                                  softWrap: true,
                                ),
                              ),
                            ),
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
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            sweetners[index] = refillCount;
                          });
                        },
                        icon: const Icon(Icons.refresh)),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                        ),
                        Expanded(
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
                                sweetners[index].toString(),
                                softWrap: true,
                              ),
                            ),
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
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            flavours[index] = refillCount;
                          });
                        },
                        icon: const Icon(Icons.refresh)),
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
                                  flavours[index].toString(),
                                  softWrap: true,
                                ),
                              ),
                            ),
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
                    await KioskServices().updateIngredients(
                        id: widget.kiosk.id,
                        bases: bases,
                        flavours: flavours,
                        sweetners: sweetners);
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
      });
    });
  }
}
