// @dart=2.9
// ignore: import_of_legacy_library_into_null_safe
import 'package:easymed/widget/mydrawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:algolia/algolia.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'Email File Link'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Algolia _algoliaApp = Algolia.init(
    applicationId: '0W9920TY0I', //ApplicationID,
    apiKey: '6b4d2b6c7cad717cef2a6f2d8979e3b1', //admin api key in flutter code
  );
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _label = TextEditingController();
  TextEditingController _quantity = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("easymed"),
      ),
      drawer: MyDrawer(),
      body: Center(
        child: loading == true
            ? CircularProgressIndicator()
            : Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Medicine name",
                            hintText: "Medicine name",
                            icon: Icon(Icons.medical_services),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _label,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Label",
                            hintText: "Label",
                            icon: Icon(Icons.map),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _quantity,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Quantity",
                            hintText: "Quantity",
                            icon: Icon(Icons.map),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              _algoliaApp.instance
                                  .index("easymed")
                                  .addObject(<String, dynamic>{
                                "name": _name.text,
                                "label": _label.text,
                                "quantity": int.parse(_quantity.text),
                              }).then((value) {
                                setState(() => loading = false);
                                _name.clear();
                                _label.clear();
                                _quantity.clear();
                              });
                            }
                          },
                          color: Colors.orangeAccent,
                          height: 50,
                          minWidth: 150,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Add Medicine",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
        /* Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: MaterialButton(
                      onPressed: () {},
                      color: Colors.orangeAccent,
                      height: 50,
                      minWidth: 150,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Add Medicine",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ), */
      ),
    );
  }
}
