import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:flutter/material.dart';

import '../partials/menu.dart';

class Operation {
  String? label;
  String? name;
  String? param;
  Operation({this.label, this.name, String? param}) : param = param ?? '0';
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
    Operation(name: "Wait", label: "Other", param: "30sec"),
    Operation(name: "Water", label: "Other", param: "1/2cup"),
  ];
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
                      onTap: () {},
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
                        onTap: () {
                          setState(() {});
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
}
