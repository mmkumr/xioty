import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../partials/menu.dart';

class Operation {
  String? label;
  String? name;
  String? param;
  Operation({required this.label, required this.name, String? param})
      : param = param ?? '0';
}

class ProcessPage extends StatefulWidget {
  const ProcessPage({super.key});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  List<Operation> operations = [
    Operation(name: "Induction", label: "Other", param: "180"),
    Operation(name: "Lid_Up", label: "Micro"),
    Operation(name: "Oil", label: "Liquid Micro", param: "3tsp"),
    Operation(name: "Onion", label: "Macro", param: "1cup"),
    Operation(name: "Stir", label: "Other"),
    Operation(name: "Wait", label: "Other", param: "30"),
    Operation(name: "Water", label: "Other", param: "1/2cup"),
  ];
  GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController delay = TextEditingController();
  List<String> heatLevels = ["100", "130", "160", "180", "200", "220", "240"];
  String? heatLevel = "180";
  List<String> waterLevels = ["1cup", "1/4cup", "1/2cup", "3/4cup"];
  String? waterLevel = "1";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: AppBar(
        backgroundColor: bgC,
        centerTitle: true,
        title: const Text("Process"),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: height(context) * 0.7,
            child: ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  Operation item = operations.removeAt(oldIndex);
                  operations.insert(newIndex, item);
                });
              },
              itemCount: operations.length,
              itemBuilder: (context, index) {
                return Padding(
                  key: ValueKey(index),
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryC,
                      border: Border.all(),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: ListTile(
                      onTap: () {
                        setParam(index);
                      },
                      title: Text(
                        operations[index].name!,
                        textAlign: TextAlign.center,
                      ),
                      trailing: Text(
                        operations[index].param! == "0"
                            ? ""
                            : operations[index].param!,
                        style: const TextStyle(fontSize: 15),
                      ),
                      leading: InkWell(
                        onTap: operations[index].param! == "0"
                            ? () {}
                            : () {
                                setState(() {
                                  operations.removeAt(index);
                                });
                              },
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: MaterialButton(
              elevation: 10,
              minWidth: 250,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: elementsC,
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Add",
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
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: MaterialButton(
              elevation: 10,
              minWidth: 250,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: elementsC,
              onPressed: () {
                navigate(
                    type: Type.replace,
                    context: context,
                    page: const HomePage());
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }

  setParam(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget content;
        if (operations[index].name == "Induction") {
          content = Form(
            key: form,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownButtonFormField(
                value: operations[index].param,
                items: heatLevels.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    operations[index].param = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Heating level",
                  label: const Text("Heating level"),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: primaryC,
                ),
              ),
            ),
          );
        } else if (operations[index].name == "Water") {
          content = Form(
            key: form,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: DropdownButtonFormField(
                value: operations[index].param,
                items: waterLevels.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    operations[index].param = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Water Quantity",
                  label: const Text("Water Quantity"),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: primaryC,
                ),
              ),
            ),
          );
        } else if (operations[index].name == "Wait") {
          delay.text = operations[index].param!;
          content = Form(
            key: form,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: delay,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onEditingComplete: () {
                  operations[index].param = delay.text;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Field can't be empty";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: "Delay in secs",
                  label: const Text("Delay in secs"),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: primaryC,
                ),
              ),
            ),
          );
        } else {
          content = Container();
        }
        return AlertDialog(
          title: const Text("Update parameter"),
          content: content,
          actions: const [],
        );
      },
    );
    setState(() {});
  }
}
