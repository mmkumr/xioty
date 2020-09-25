import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _firebase = FirebaseDatabase.instance.reference();
  String motor = "0";
  double motorCurrent = 0.0;
  String status;
  @override
  Widget build(BuildContext context) {
    readData();
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Text(
                "Automoto",
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Container(
                  height: 10,
                  width: 10,
                  decoration: new BoxDecoration(
                    color: status == "ok"? Colors.red : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child: SingleChildScrollView(
            child: Center(
                heightFactor: 1.2,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Material(
                          color: motor == "1"? Colors.green : Colors.red,
                          child: InkWell(
                            child: SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.9,
                              height: 100,
                              child: new Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.lightbulb_outline,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if(motor == "0") {
                                writeData("1");
                              } else {
                                resetData();
                                writeData("0");
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          child: Container(
                            color: Colors.black,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 50,
                              child: new Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      motor == "0" || motorCurrent == 0.001? Text("Motor Current: 0.0A", style: TextStyle(color: Colors.red),):
                                      Text("Motor Current: " + motorCurrent.toString() + "A",
                                        style: TextStyle(
                                          color: Colors.green
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ],
                )

            ),
          ),
        )
    );
  }
  void readData() async {
    _firebase.child("wirelessmotor").
    once().then((DataSnapshot value){
      setState(() {
        motor = value.value["button"];
        motorCurrent = value.value["current"];
        status = value.value["status"];
      });
    });
    if(status == "ok"){
      Timer(Duration(seconds: 1), () {
        _firebase.child("wirelessmotor").update({
          "status": "not ok"
        });
      });

    }
  }
  
  void writeData(String data){
    _firebase.child("wirelessmotor").update({
      "button": data
    });
  }

  void resetData(){
    _firebase.update({
    "motorCurrent": 0.001,
    "pipePressure": 0.001
    });
  }
}