/*
[12:43 pm, 16/09/2024] Eswar Dora(Xioty Solution): 150, 250, 350
[12:43 pm, 16/09/2024] Eswar Dora(Xioty Solution): ml
*/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xenobot/pages/order_preparing.dart';
import 'package:xenobot/partials/appbar.dart';
import 'package:xenobot/partials/menu.dart';

import '../commons.dart';

class RecipeInfoPage extends StatefulWidget {
  const RecipeInfoPage({super.key});

  @override
  State<RecipeInfoPage> createState() => _RecipeInfoPageState();
}

class _RecipeInfoPageState extends State<RecipeInfoPage> {
  int nos = 6;
  @override
  void initState() {
    super.initState();
    quantity = List.generate(nos, (index) => TextEditingController(text: "0"));
    cupSize = cupSizes[0];
  }

  String cupSize = "";
  List<String> cupSizes = [
    "150 ml",
    "250 ml",
    "350 ml",
  ];
  List<TextEditingController> quantity = [];
  List sweetners = ["Sugar", "Honey", "Jagery"];
  List flavours = ["Chocolate", "Masala", "Rose"];
  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    "Irani Tea",
                    softWrap: true,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                            page: const OrderPreparingPage());
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
                                sweetners[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: quantity[index],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black,
                                  label: const Text(
                                    "ml",
                                    style: TextStyle(
                                        color: Colors.white,
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
                                controller: quantity[index + 3],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black,
                                  label: const Text(
                                    "ml",
                                    style: TextStyle(
                                        color: Colors.white,
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
                      onPressed: () async {
                        await savePreference();
                        if (context.mounted) {
                          navigate(
                              type: PageType.replace,
                              context: context,
                              page: const OrderPreparingPage());
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
}
