import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/variant.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../partials/menu.dart';

class Operation {
  String? label;
  String? name;
  String? param;
  Operation({required this.label, required this.name, String? param})
      : param = param ?? '0';
}

class ProcessPage extends StatefulWidget {
  final VariantModel variant;
  final RecipeModel recipe;
  const ProcessPage({super.key, required this.variant, required this.recipe});

  @override
  State<ProcessPage> createState() => _ProcessPageState();
}

class _ProcessPageState extends State<ProcessPage> {
  List<Operation> operations = [];
  GlobalKey<FormState> form = GlobalKey<FormState>();
  TextEditingController delay = TextEditingController();
  List<String> heatLevels = ["100", "130", "160", "180", "200", "220", "240"];
  String? heatLevel = "160";
  List<String> waterLevels = ["1cup", "1/4cup", "1/2cup", "3/4cup"];
  String? waterLevel = "1cup";
  int selected = 0;
  List<String> changeableParam = ["Induction", "Water", "Wait"];
  List<String> others = [
    "Lid up",
    "Lid down",
    "Induction",
    "Water",
    "Stir",
    "Wait",
    "Preset",
    "Arm home",
    "Disable arm",
    "indOff",
  ];
  bool loading = false;
  @override
  void initState() {
    if (widget.variant.operations!.isNotEmpty) {
      for (var e in widget.variant.operations!) {
        operations.add(Operation(
          label: e["label"],
          name: e["name"],
          param: e["param"],
        ));
      }
      selected = operations.length - 1;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Colors.blue,
              size: 200,
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: bgC,
            appBar: AppBar(
              backgroundColor: bgC,
              centerTitle: true,
              title: const Text("Process"),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: InkWell(
                    onTap: () {
                      if (operations.isNotEmpty) {
                        setState(() {
                          operations.removeAt(selected);
                          selected =
                              operations.isEmpty ? 0 : operations.length - 1;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
              elevation: 0,
            ),
            drawer: menu(context),
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
                            color: selected == index ? Colors.white : primaryC,
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: GestureDetector(
                            onDoubleTap: !changeableParam
                                    .contains(operations[index].name!)
                                ? () {}
                                : () {
                                    setParam(index);
                                  },
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  selected = index;
                                });
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
                              leading: Text(operations[index].label!),
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
                    onPressed: () {
                      addOperationsPopup(context);
                    },
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
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      List<Map> updateOperations = operations.map((e) {
                        return {
                          "name": e.name,
                          "label": e.label,
                          "param": e.param
                        };
                      }).toList();
                      await VariantServices().updateOperations(
                        recipe: widget.recipe,
                        variant: widget.variant,
                        operations: updateOperations,
                      );
                      if (!context.mounted) return;
                      setState(() {
                        loading = false;
                      });
                      navigate(
                          type: PageType.replace,
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
          );
  }

  setParam(int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget content;
        if (operations[index].label!.contains("o") &&
            operations[index].name == "Induction") {
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
        } else if (operations[index].label!.contains("o") &&
            operations[index].name == "Water") {
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
        } else if (operations[index].label!.contains("o") &&
            operations[index].name == "Wait") {
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

  Future<dynamic> addOperationsPopup(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Operations"),
          content: SizedBox(
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      collapsedBackgroundColor: primaryC,
                      title: const Text(
                        "Macros",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        for (int i = 0; i < widget.variant.macros!.length; i++)
                          widget.variant.macros![i]["name"].isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width(context) * 0.5,
                                    decoration: BoxDecoration(
                                      color: primaryC,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        int index = selected + 1;
                                        if (operations.isEmpty) {
                                          index = 0;
                                        }
                                        operations.insert(
                                            index,
                                            Operation(
                                                label: "M$i",
                                                name: widget.variant.macros![i]
                                                    ["name"],
                                                param: widget.variant.macros![i]
                                                    ["quantity"]));
                                        selected = operations.isEmpty
                                            ? 0
                                            : operations.length - 1;
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                      title: Text(
                                          widget.variant.macros![i]["name"]),
                                      trailing: Text(widget.variant.macros![i]
                                          ["quantity"]),
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      collapsedBackgroundColor: primaryC,
                      title: const Text(
                        "Solid Micros",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        for (int i = 0;
                            i < widget.variant.solidMicros!.length;
                            i++)
                          widget.variant.solidMicros![i]["name"].isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width(context) * 0.5,
                                    decoration: BoxDecoration(
                                      color: primaryC,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        int index = selected + 1;
                                        if (operations.isEmpty) {
                                          index = 0;
                                        }
                                        operations.insert(
                                            index,
                                            Operation(
                                                label: "sm$i",
                                                name: widget.variant
                                                    .solidMicros![i]["name"],
                                                param: widget
                                                        .variant.solidMicros![i]
                                                    ["quantity"]));
                                        selected = operations.isEmpty
                                            ? 0
                                            : operations.length - 1;
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                      title: Text(widget.variant.solidMicros![i]
                                          ["name"]),
                                      trailing: Text(
                                          "${widget.variant.solidMicros![i]['quantity']} tsp"),
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      collapsedBackgroundColor: primaryC,
                      title: const Text(
                        "Liquid Micros",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        for (int i = 0;
                            i < widget.variant.liquidMicros!.length;
                            i++)
                          widget.variant.liquidMicros![i]["name"].isEmpty
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: width(context) * 0.5,
                                    decoration: BoxDecoration(
                                      color: primaryC,
                                      border: Border.all(),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                    ),
                                    child: ListTile(
                                      onTap: () {
                                        int index = selected + 1;
                                        if (operations.isEmpty) {
                                          index = 0;
                                        }
                                        operations.insert(
                                            index,
                                            Operation(
                                                label: "lm$i",
                                                name: widget.variant
                                                    .liquidMicros![i]["name"],
                                                param:
                                                    "${widget.variant.liquidMicros![i]["quantity"]} tsp"));
                                        selected = operations.isEmpty
                                            ? 0
                                            : operations.length - 1;
                                        setState(() {});
                                        Navigator.of(context).pop();
                                      },
                                      title: Text(widget
                                          .variant.liquidMicros![i]["name"]),
                                      trailing: Text(
                                          "${widget.variant.liquidMicros![i]['quantity']} tsp"),
                                    ),
                                  ),
                                ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      collapsedBackgroundColor: primaryC,
                      title: const Text(
                        "Others",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        for (int i = 0; i < others.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: Alignment.center,
                              width: width(context) * 0.5,
                              decoration: BoxDecoration(
                                color: primaryC,
                                border: Border.all(),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(40)),
                              ),
                              child: ListTile(
                                onTap: () {
                                  String param = "0";
                                  if (others[i] == "Induction") {
                                    param = "160";
                                  } else if (others[i] == "Water") {
                                    param = "1cup";
                                  } else if (others[i] == "Wait") {
                                    param = "1";
                                  }
                                  int index = selected + 1;
                                  if (operations.isEmpty) {
                                    index = 0;
                                  }
                                  operations.insert(
                                      index,
                                      Operation(
                                          label: "o$i",
                                          name: others[i],
                                          param: param));
                                  selected = operations.isEmpty
                                      ? 0
                                      : operations.length - 1;
                                  setState(() {});
                                  Navigator.of(context).pop();
                                },
                                title: Text(others[i]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
