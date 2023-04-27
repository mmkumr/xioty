import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'db/micros.dart';
import 'db/others.dart';
import 'layouts/commons.dart';
import 'new_recipe.dart';

class Details extends StatefulWidget {
  Details({super.key});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  @override
  void initState() {
    super.initState();
    getmicros();
    getOthers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  List<TextEditingController> _M =
      List.generate(5, (i) => TextEditingController(), growable: false);
  List<TextEditingController> _m = [];
  TextEditingController _name = TextEditingController();
  List microsList = [];
  List othersList = [];
  List selectedMicros = [];
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
                for (int i = 0; i < 4; i++)
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
                    title: Center(child: Text('Micros')),
                    tileColor: elementsC,
                    onTap: () {}),
                for (int i = 0; i < microsList.length; i++)
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
                      child: ListTile(
                        title: TextFormField(
                          controller: _m[i],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "m${(i + 1).toString()}",
                            labelText: "m${(i + 1).toString()}",
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
              'others': othersList,
            };
            navigate(
                'r',
                context,
                NewRecipe(
                  recipe: recipe,
                ));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  getmicros() async {
    MicrosServices microsServices = MicrosServices();
    await microsServices.getMicros().then((value) {
      setState(() {
        microsList = value;
        _m = List.generate(value.length, (i) => TextEditingController(),
            growable: true);
      });
    });
  }

  getOthers() async {
    OtherssServices othersServices = OtherssServices();
    await othersServices.getMicros().then((value) {
      setState(() {
        othersList = value;
      });
    });
  }
}
