import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/chef_solid_micros.dart';
import 'package:botchef_v2/pages/mima_description.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:flutter/material.dart';

import '../partials/menu.dart';

class ChefMacroPage extends StatefulWidget {
  const ChefMacroPage({super.key});

  @override
  State<ChefMacroPage> createState() => _ChefMacroPageState();
}

class _ChefMacroPageState extends State<ChefMacroPage> {
  List<TextEditingController> macros =
      List.generate(4, (index) => TextEditingController());
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<String> quantities = [
    "1 cup",
    "1/4 cup",
    "1/2 cup",
    "3/4 cup",
  ];
  List<String>? quantity;
  @override
  void initState() {
    quantity = List.generate(4, (index) => quantities[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: appbar,
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
              const Text(
                "Macros",
                style: TextStyle(fontSize: 40),
              ),
              Form(
                key: form,
                child: Column(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: width(context) * 0.5,
                                child: TextFormField(
                                  controller: macros[i],
                                  decoration: InputDecoration(
                                    hintText: "Macro ${i + 1}",
                                    label: Text("Macro ${i + 1}"),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    fillColor: primaryC,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: width(context) * 0.3,
                                child: DropdownButtonFormField(
                                  value: quantity![i],
                                  items: quantities.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      quantity![0] = value!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Quantity",
                                    label: const Text("Quantity"),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    fillColor: primaryC,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                navigate(
                                    type: Type.push,
                                    context: context,
                                    page: const MiMaDescription());
                              },
                              child: const Icon(Icons.info_rounded),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 30),
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
                      page: const ChefSolidMicro(),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
