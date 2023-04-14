import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'db/micros.dart';
import 'db/recipes.dart';
import 'layouts/commons.dart';
import 'recipe.dart';

class PreDetails extends StatefulWidget {
  final String id;
  PreDetails({super.key, required this.id});

  @override
  State<PreDetails> createState() => _PreDetailsState();
}

class _PreDetailsState extends State<PreDetails> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  List<TextEditingController> _M =
      List.generate(5, (i) => TextEditingController(), growable: false);
  List<TextEditingController> _m =
      List.generate(13, (i) => TextEditingController(), growable: false);
  TextEditingController _name = TextEditingController();
  List microsList = [];
  List othersList = [];
  List selectedMicros = [];
  Map<String, dynamic> data = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: Text('Required ingredients'),
        backgroundColor: Color(0xff9a94c8),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 60.0),
        child: SizedBox(
          height: size('h', context),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Neumorphic(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    style: NeumorphicStyle(
                      color: Colors.white,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(20),
                      ),
                    ),
                    child: Form(
                      key: _key,
                      child: TextFormField(
                        controller: _name,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Recipe Name",
                          labelText: "Recipe Name",
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter the name";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                ListTile(
                    title: Center(child: Text('Macros')), tileColor: elementsC),
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Neumorphic(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      style: NeumorphicStyle(
                        color: Colors.white,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: TextFormField(
                        controller: _M[i],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "M${(i + 1).toString()}",
                          labelText: "M${(i + 1).toString()}",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ListTile(
                    title: Center(child: Text('Micros')), tileColor: elementsC),
                for (int i = 0; i < 10; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Neumorphic(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      style: NeumorphicStyle(
                        color: Colors.white,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? val) {
                          if (val == true) {
                            setState(() {
                              selectedMicros.add(i);
                            });
                          } else {
                            setState(() {
                              selectedMicros.remove(i);
                            });
                          }
                        },
                        value: selectedMicros.indexOf(i) >= 0,
                        subtitle: Text(
                          "m${(i + 1).toString()}",
                        ),
                        title: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${microsList[i]}",
                              ),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: _m[i],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  readOnly: !(selectedMicros.indexOf(i) >= 0),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: "tsp",
                                    labelText: "tsp",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ListTile(
                    title: Center(child: Text('Others')), tileColor: elementsC),
                for (int i = 10; i < 13; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Neumorphic(
                      margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      style: NeumorphicStyle(
                        color: Colors.white,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20),
                        ),
                      ),
                      child: TextFormField(
                        controller: _m[i],
                        readOnly: i == 10
                            ? false
                            : i == 11
                                ? _m[10].text.isEmpty
                                : i == 12
                                    ? _m[11].text.isEmpty
                                    : false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "m${(i + 1).toString()}",
                          labelText: "m${(i + 1).toString()}",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: elementsC,
        icon: Icon(FontAwesomeIcons.arrowRight),
        label: Text('Next'),
        onPressed: () {
          if (_key.currentState!.validate()) {
            Map<String, String> macros = {};
            Map<String, String> micros = {};
            for (int index = 0;
                //Storing none empty macros and quantities of micros.
                index < _M.length;
                index++) {
              if (_M[index].text.isNotEmpty) {
                macros['M${index}'] = _M[index].text;
              }
            }
            for (int index = 0; index < _m.length; index++) {
              if (_m[index].text.isNotEmpty) {
                micros['m$index'] = _m[index].text;
              }
            }
            //For passing data to next page.
            Map<String, dynamic> recipe = {
              'name': _name.text,
              'macros': macros,
              'micros': micros,
              'others': data['others'],
              'operations': data['operations'],
            };
            navigate(
                'r',
                context,
                Recipe(
                  recipe: recipe,
                ));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  getData() async {
    /*Todo: selectedMicros
            initializing name, _M and _m text controllers
            initializing selectionboxes
     */
    RecipesServices recipesServices = RecipesServices();
    MicrosServices microsServices = MicrosServices();
    await recipesServices.getRecipe(widget.id).then((value) {
      setState(() {
        data = value;
      });
    });
    setState(() {
      _name.text = data['name'];
      data['macros'].forEach((k, v) {
        _M[int.parse(k.replaceAll('M', ''))].text = v;
      });
      data['micros'].forEach((k, v) {
        _m[int.parse(k.replaceAll('m', ''))].text = v;
        selectedMicros.add(int.parse(k.replaceAll('m', '')));
      });
    });
    await microsServices.getMicros().then((value) {
      setState(() {
        microsList = value;
      });
    });
  }
}
