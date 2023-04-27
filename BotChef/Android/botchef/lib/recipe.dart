import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'db/micros.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'db/recipes.dart';
import 'layouts/commons.dart';
import 'recipe_list.dart';

class operation {
  String? label;
  String? name;
  String? param = '1';
  operation({required String? label, required String? name, String? param}) {
    this.label = label;
    this.name = name;
    this.param = param == null ? '1' : param;
  }
}

class Recipe extends StatefulWidget {
  final Map<String, dynamic> recipe;
  Recipe({super.key, required this.recipe});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  @override
  void initState() {
    super.initState();
    getmicros();
    debugPrint(widget.recipe['operations'].toString());
    widget.recipe['operations'].every((e) {
      setState(() {
        _params = List.generate(widget.recipe['operations'].length,
            (i) => TextEditingController(text: e['param']));
        operations.add(
            operation(label: e['label'], name: e['name'], param: e['param']));
      });
      return true;
    });
  }

  List? microsList;
  List<TextEditingController>? _params = [];
  bool loading = false;
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  List<operation> operations = [];
  Color macroColor = Color(0xff0095d9);
  Color microColor = Color(0xffa54586);
  Color otherColor = Color(0xfff8abad);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: Text('Processes'),
        backgroundColor: Color(0xff9a94c8),
      ),
      body: loading
          ? CircularProgressIndicator()
          : operations.length == 0
              ? Center(child: Text("No Processes"))
              : Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: ReorderableListView.builder(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final operation item = operations.removeAt(oldIndex);
                        operations.insert(newIndex, item);
                      });
                    },
                    itemCount: operations.length,
                    itemBuilder: (context, index) {
                      Color tileColor = Color(0xff0095d9);
                      if (operations[index].label![0] == 'M') {
                        tileColor = Color(0xff0095d9);
                      } else if (operations[index].label![0] == 'm') {
                        tileColor = Color(0xffa54586);
                      } else if (operations[index].label![0] == 'O') {
                        tileColor = Color(0xfff8abad);
                      }
                      return Padding(
                        key: ValueKey(index),
                        padding: const EdgeInsets.all(10.0),
                        child: Neumorphic(
                          style: NeumorphicStyle(
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(12)),
                            depth: 10,
                            color: tileColor,
                          ),
                          child: ListTile(
                            onTap: () {
                              if (operations[index].name!.contains('Delay') ||
                                  operations[index].name!.contains('Tilt') ||
                                  operations[index].name!.contains('Sqeeze')) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Parameters"),
                                    content: Form(
                                      key: _form,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Neumorphic(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          style: NeumorphicStyle(
                                            color: Colors.white,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                              BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            controller: _params![index],
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: "Number",
                                              labelText: "Parameter",
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      MaterialButton(
                                        onPressed: () {
                                          operations[index].param =
                                              _params![index].text;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Done'),
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      )
                                    ],
                                  ),
                                );
                              }
                              debugPrint(index.toString());
                            },
                            leading: Text(operations[index].label!),
                            title: Text(operations[index].name!),
                            trailing: InkWell(
                              onTap: () {
                                setState(() {
                                  operations.removeAt(index);
                                });
                              },
                              child: Icon(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FloatingActionButton.extended(
                backgroundColor: elementsC,
                icon: Icon(FontAwesomeIcons.plus),
                label: Text('Add operation'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(32.0),
                        ),
                      ),
                      backgroundColor: bgC,
                      title: Text("Select operation"),
                      content: SizedBox(
                        height: size('h', context),
                        width: size('w', context),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              //Starting of macro operation list.
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ExpansionTile(
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(32.0),
                                    ),
                                  ),
                                  collapsedBackgroundColor: macroColor,
                                  title: Text(
                                    'Macros',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: [
                                    for (int i = 0;
                                        i < widget.recipe['macros'].keys.length;
                                        i++)
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Neumorphic(
                                          style: NeumorphicStyle(
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(12)),
                                            depth: 10,
                                            color: macroColor,
                                          ),
                                          child: ListTile(
                                            title: Text(widget.recipe['macros'][
                                                widget.recipe['macros'].keys
                                                    .toList()[i]]),
                                            onTap: () {
                                              String label = 'M' +
                                                  (int.parse(widget
                                                              .recipe['macros']
                                                              .keys
                                                              .toList()[i]
                                                              .substring(1)) +
                                                          1)
                                                      .toString();
                                              setState(() {
                                                operations.add(
                                                  operation(
                                                    name: widget
                                                            .recipe['macros'][
                                                        widget.recipe['macros']
                                                            .keys
                                                            .toList()[i]],
                                                    label: label,
                                                  ),
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              //Ending of macro operation list.
                              //Starting of micro operation list.
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ExpansionTile(
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(32.0),
                                    ),
                                  ),
                                  collapsedBackgroundColor: microColor,
                                  title: Text(
                                    'Micros',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: [
                                    for (int i = 0; i < 9; i++)
                                      if (widget.recipe['micros']
                                          .containsKey('m$i'))
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ExpansionTile(
                                            collapsedShape:
                                                RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(32.0),
                                              ),
                                            ),
                                            collapsedBackgroundColor:
                                                microColor,
                                            title: Text(
                                                widget.recipe['micros']['m$i']),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(12)),
                                                    depth: 10,
                                                    color: Colors.green,
                                                  ),
                                                  child: ListTile(
                                                    title: Text('Hold'),
                                                    onTap: () {
                                                      setState(() {
                                                        operations.add(operation(
                                                            name: widget.recipe[
                                                                        'micros']
                                                                    ['m$i'] +
                                                                " " +
                                                                "Hold",
                                                            label:
                                                                'm${i + 1}'));
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(12)),
                                                    depth: 10,
                                                    color: Colors.orange,
                                                  ),
                                                  child: ListTile(
                                                    title: Text('Drop'),
                                                    onTap: () {
                                                      setState(() {
                                                        operations.add(operation(
                                                            name: widget.recipe[
                                                                        'micros']
                                                                    ['m$i'] +
                                                                " " +
                                                                "Drop",
                                                            label:
                                                                'm${i + 1}'));
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    //end of sublist
                                  ],
                                ),
                              ),
                              //Ending of micro operation list.
                              //Starting of Other operation list.
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ExpansionTile(
                                  collapsedShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(32.0),
                                    ),
                                  ),
                                  collapsedBackgroundColor: otherColor,
                                  title: Text(
                                    'Others',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: [
                                    for (int i = 0;
                                        i < widget.recipe['others']!.length;
                                        i++)
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Neumorphic(
                                          style: NeumorphicStyle(
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(12)),
                                            depth: 10,
                                            color: otherColor,
                                          ),
                                          child: ListTile(
                                            title: Text(
                                                widget.recipe['others'][i]),
                                            onTap: () {
                                              setState(() {
                                                _params!.add(
                                                    TextEditingController(
                                                        text: '1'));
                                                operations.add(operation(
                                                    name: widget
                                                        .recipe['others'][i],
                                                    label: 'O${i + 1}'));
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              //Ending of Other operation list.
                            ],
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            FloatingActionButton.extended(
              backgroundColor: elementsC,
              icon: Icon(FontAwesomeIcons.floppyDisk),
              label: Text('Run'),
              onPressed: () async {
                if (operations.isNotEmpty) {
                  setState(() {
                    loading = true;
                  });
                  Map<String, dynamic> data = widget.recipe;
                  data['operations'] = operations.map((e) {
                    return {
                      'label': e.label,
                      'name': e.name,
                      'param': e.param,
                    };
                  }).toList();
                  List<String> files = [];
                  for (operation e in operations) {
                    if (e.label![0] == 'm') {
                      if (e.name!.contains('Hold')) {
                        files = files + await getFileLines('m/up/${e.label}');
                      } else if (e.name!.contains('Drop')) {
                        files = files + await getFileLines('m/down/${e.label}');
                      }
                    } else if (e.name!.contains('Delay')) {
                      files = files + ['G4 S${e.param}'];
                    } else if (e.name!.contains('Tilt') ||
                        e.name!.contains('Sqeeze')) {
                      for (int i = 0; i < int.parse(e.param!); i++) {
                        files = files +
                            await getFileLines('${e.label![0]}/${e.label}');
                      }
                    } else {
                      files = files +
                          await getFileLines('${e.label![0]}/${e.label}');
                    }
                  }
                  RecipesServices recipesServices = RecipesServices();
                  recipesServices.updateRecipe(data, widget.recipe['id']);
                  recipesServices.runRecipe(files);
                  Navigator.of(context).pop();
                }
                setState(() {
                  loading = true;
                });
                navigate('r', context, RecipeList());
              },
            ),
          ],
        ),
      ),
    );
  }

  //for get lines in file as list
  Future<List<String>> getFileLines(String name) async {
    final data = await rootBundle.load('assets/operations/$name');
    final directory = (await getTemporaryDirectory()).path;
    final fileName = name.substring((name.lastIndexOf('/') + 1));
    final file = await writeToFile(data, '$directory/$fileName');
    return await file.readAsLines();
  }

  //Saving files to a temporary location.
  Future<File> writeToFile(ByteData data, String path) {
    return File(path).writeAsBytes(data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    ));
  }

  getmicros() async {
    MicrosServices microsServices = MicrosServices();
    await microsServices.getMicros().then((value) {
      setState(() {
        microsList = value;
      });
    });
  }
}
