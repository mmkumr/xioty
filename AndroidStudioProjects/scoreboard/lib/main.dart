// @dart=2.9
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scoreboard/scoreboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _firebase = FirebaseDatabase.instance.reference();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  Map data;
  TextEditingController name1 = TextEditingController();
  TextEditingController name2 = TextEditingController();
  @override
  void initState() {
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Enter players name")),
      ),
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: name1,
                      decoration: InputDecoration(
                        fillColor: Color(0xff6DFFF0),
                        hintText: "Team1 name",
                        labelText: "Team1 name",
                        icon: Icon(Icons.person),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xff6DFFF0),
                        )),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "The name field cannot be empty";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: name2,
                      decoration: InputDecoration(
                        fillColor: Color(0xff6DFFF0),
                        hintText: "Team2 name",
                        labelText: "Team2 name",
                        icon: Icon(Icons.person),
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "The name field cannot be empty";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: MaterialButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              loading = true;
                            });
                            writeData(name1.text, "data", "player1");
                            writeData(name2.text, "data", "player2");
                            setState(() {
                              loading = false;
                            });
                            name1.clear();
                            name2.clear();
                            Navigator.pop(context);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ScoreBoard(),
                              ),
                            );
                          }
                        },
                        color: Colors.blue,
                        height: 50,
                        minWidth: 150,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
    );
  }

  void readData() {
    _firebase.once().then((DataSnapshot value) {
      setState(() {
        data = value.value["data"];
        name1.text = data["player1"];
        name2.text = data["player2"];
      });
    });
  }

  void writeData(String data, String child, String type) {
    print("Child: " + child + " " + "{" + type + " : " + data + "}");
    _firebase.child(child).update({type: data});
  }
}
