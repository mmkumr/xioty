import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'layouts/commons.dart';

class Recipe extends StatefulWidget {
  const Recipe({super.key});

  @override
  State<Recipe> createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
  @override
  void initState() {
    super.initState();
  }

  GlobalKey<FormState> _form = GlobalKey<FormState>();
  List<String> label = ['m2', 'O3', 'M1', 'O1', 'M4', 'm2'];
  List<String> name = [
    'Pepper Hold',
    'Tilt',
    'Potato',
    'Delay',
    'Onions',
    'Pepper Drop'
  ];
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
      body: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          List temp = [label[oldIndex], name[oldIndex]];
          setState(() {
            label[oldIndex] = label[newIndex];
            name[oldIndex] = name[newIndex];
            label[newIndex] = temp[0];
            name[newIndex] = temp[1];
          });
        },
        itemCount: name.length,
        itemBuilder: (context, index) {
          Color tileColor = Color(0xff0095d9);
          if (label[index][0] == 'M') {
            tileColor = Color(0xff0095d9);
          } else if (label[index][0] == 'm') {
            tileColor = Color(0xffa54586);
          } else if (label[index][0] == 'O') {
            tileColor = Color(0xfff8abad);
          }
          return Padding(
            key: ValueKey(index),
            padding: const EdgeInsets.all(10.0),
            child: Neumorphic(
              style: NeumorphicStyle(
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                depth: 10,
                color: tileColor,
              ),
              child: ListTile(
                onTap: () {
                  if (name[index] == 'Delay') {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Delay"),
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
                                boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20),
                                ),
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Duration",
                                  labelText: "Duration",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          MaterialButton(
                            onPressed: () {},
                            child: Text('Save'),
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
                leading: Text(label[index]),
                title: Text(name[index]),
                trailing: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
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
                                          title: Text('Onion'),
                                          onTap: () {},
                                        ),
                                      ),
                                    ),
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
                                            title: Text('Tomato'),
                                            onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Potato'),
                                            onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Beans'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Carrot'),
                                            onTap: () {}),
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
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Oil'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Soya sauce'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Salt'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Coriandar Powder'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Kasmiri Mirch'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Cumin Powder'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Chilli Powder'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Chicken Masala'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Meat Masala'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //end of sublist
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ExpansionTile(
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(32.0),
                                          ),
                                        ),
                                        collapsedBackgroundColor: microColor,
                                        title: Text('Turmeric Powder'),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.green,
                                              ),
                                              child: ListTile(
                                                title: Text('Hold'),
                                                onTap: () {},
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Neumorphic(
                                              style: NeumorphicStyle(
                                                boxShape: NeumorphicBoxShape
                                                    .roundRect(
                                                        BorderRadius.circular(
                                                            12)),
                                                depth: 10,
                                                color: Colors.orange,
                                              ),
                                              child: ListTile(
                                                title: Text('Drop'),
                                                onTap: () {},
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
                                          title: Text('Stirr'),
                                          onTap: () {},
                                        ),
                                      ),
                                    ),
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
                                            title: Text('Squiz'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Tilt'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Lid Up'),
                                            onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Lid Down'),
                                            onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('P1'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('P2'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('P3'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('P4'), onTap: () {}),
                                      ),
                                    ),
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
                                            title: Text('Delay'), onTap: () {}),
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
                          child: Text('Cancel'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            FloatingActionButton.extended(
              backgroundColor: elementsC,
              icon: Icon(FontAwesomeIcons.play),
              label: Text('Run'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
