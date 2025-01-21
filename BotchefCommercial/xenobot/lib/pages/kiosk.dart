import 'package:flutter/material.dart';
import 'package:xenobot/db/kiosks.dart';
import 'package:xenobot/models/kiosk.dart';
import 'package:xenobot/pages/kiosks.dart';

import '../commons.dart';
import '../db/ingredients_prices.dart';
import '../models/ingredients_price.dart';

class NewKioskPage extends StatefulWidget {
  final KioskModel? kiosk;
  final String id;
  const NewKioskPage({
    super.key,
    this.kiosk,
    required this.id,
  });

  @override
  State<NewKioskPage> createState() => _NewKioskPageState();
}

class _NewKioskPageState extends State<NewKioskPage> {
  @override
  void didChangeDependencies() async {
    await getIngredientsPrice();
    super.didChangeDependencies();
  }

  IngredientsPriceModel? ingredientsPrices;
  TextEditingController kioskId = TextEditingController();
  TextEditingController ownerName = TextEditingController();
  TextEditingController address = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  @override
  void initState() {
    if (widget.kiosk != null) {
      kioskId.text = widget.id.toString();
      ownerName.text = widget.kiosk!.name;
      address.text = widget.kiosk!.address;
    }
    kioskId.text = widget.id.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("Kiosk Details"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: Center(
        child: Form(
          key: form,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: ownerName,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xfff6f2f2),
                    label: const Text(
                      "Owner Name",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: address,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xfff6f2f2),
                    label: const Text(
                      "Kiosk Address",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "This field is required";
                    }
                    return null;
                  },
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
                    if (form.currentState!.validate()) {
                      List basesList = [],
                          flavoursList = [],
                          sweetnersList = [];
                      for (var base in ingredientsPrices!.bases) {
                        basesList.add(0);
                      }
                      for (var flavour in ingredientsPrices!.flavours) {
                        flavoursList.add(0);
                      }
                      for (var sweetner in ingredientsPrices!.sweetners) {
                        sweetnersList.add(0);
                      }
                      if (widget.kiosk != null) {
                        await KioskServices().update(
                          id: widget.id,
                          address: address.text,
                          name: ownerName.text,
                        );
                      } else {
                        await KioskServices().create(
                          id: kioskId.text,
                          name: ownerName.text,
                          address: address.text,
                          bases: basesList,
                          flavours: flavoursList,
                          sweetners: sweetnersList,
                        );
                      }
                      navigate(
                          type: PageType.replace,
                          context: context,
                          page: const KiosksPage());
                    }
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
