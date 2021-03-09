import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  DatabaseReference _firebase = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
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
      home: MyHomePage(title: 'IOT Induction cooker'),
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
  Map i1, i2;
  String power;
  int i = 4;

  @override
  Widget build(BuildContext context) {
    readData();
    var temp = [200, 400, 800, 1000, 1300, 1600, 1800, 2000];
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //1nd induction cooker data.
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Container(
                color: Color.fromARGB(255, 238, 238, 238),
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.90,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: IconButton(
                          onPressed: () {
                            if (i1["power"] == "off" && power == "on") {
                              writeData("on", "i1", "power");
                              writeData(4.toString(), "i1", "temp");
                            }
                            if (i1["power"] == "on") {
                              writeData("off", "i1", "power");
                            }
                          },
                          color: Colors.black,
                          icon: i1["power"] == "off" ? Icon(Icons.pause, size: 60,): Icon(Icons.play_arrow, size: 60,)

                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 238, 238, 238),
                          boxShadow: [
                            BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                            BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                          ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: (MediaQuery.of(context).size.height * 0.15) / 2,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: IconButton(
                                onPressed: () {
                                  if (int.parse(i1["temp"]) < 7 &&
                                      i1["power"] == "on") {
                                    writeData((int.parse(i1["temp"]) + 1).toString(),
                                        "i1", "temp");
                                  }
                                },
                                color: Colors.black,
                                icon: Icon(Icons.arrow_upward, size: 40,)

                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 238, 238, 238),
                                boxShadow: [
                                  BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                                  BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                                ]
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              height: (MediaQuery.of(context).size.height * 0.15) / 2,
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: IconButton(
                                  onPressed: () {
                                    if (int.parse(i1["temp"]) > 0 &&
                                        i1["power"] == "on") {
                                      writeData((int.parse(i1["temp"]) - 1).toString(),
                                          "i1", "temp");
                                    }
                                  },
                                  color: Colors.black,
                                  icon: Icon(Icons.arrow_downward, size: 40, color: Colors.black,)

                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 238, 238, 238),
                                  boxShadow: [
                                    BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                                    BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                                  ]
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: (MediaQuery.of(context).size.width * 0.30),
                      child: Text(
                        i1["power"] == "off"
                            ? "\n\n\nOFF"
                            : "\n" +
                        temp[int.parse(
                            i1["temp"])].toString() + " w" + "\n\n" +
                            i1["temperature"].toString() +
                            "°C" +
                            "\n\n" +
                            i1["current"].toString() +
                            " A",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.black,
                        ), textAlign: TextAlign.center,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 238, 238, 238),
                          boxShadow: [
                            BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                            BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //power button
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.10,
                width: MediaQuery.of(context).size.width * 0.80,
                child: IconButton(
                  icon: Text(
                    power.toUpperCase(),
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.03,
                        color: Colors.black
                    ),
                  ),
                  onPressed: () {
                    if (power == "off") {
                      writeData("on", "", "power");
                    }
                    if (power == "on") {
                      writeData("off", "", "power");
                      writeData("off", "i1", "power");
                      writeData("off", "i2", "power");
                    }
                  },
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 238, 238, 238),
                    boxShadow: [
                      BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                      BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                    ]
                ),
              ),
            ),

            //2nd induction cooker data.
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Container(
                color: Color.fromARGB(255, 238, 238, 238),
                height: MediaQuery.of(context).size.height * 0.20,
                width: MediaQuery.of(context).size.width * 0.90,
                child: Row(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: IconButton(
                          onPressed: () {
                            if (i2["power"] == "off" && power == "on") {
                              writeData("on", "i2", "power");
                              writeData(4.toString(), "i2", "temp");
                            }
                            if (i2["power"] == "on") {
                              writeData("off", "i2", "power");
                            }
                          },
                          color: Colors.black,
                          icon: i2["power"] == "off" ? Icon(Icons.pause, size: 60,): Icon(Icons.play_arrow, size: 60,)

                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color.fromARGB(255, 238, 238, 238),
                          boxShadow: [
                            BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                            BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                          ]
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: (MediaQuery.of(context).size.height * 0.15) / 2,
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: IconButton(
                                onPressed: () {
                                  if (int.parse(i2["temp"]) < 7 &&
                                      i2["power"] == "on") {
                                    writeData((int.parse(i2["temp"]) + 1).toString(),
                                        "i2", "temp");
                                  }
                                },
                                color: Colors.black,
                                icon: Icon(Icons.arrow_upward, size: 40,)

                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 238, 238, 238),
                                boxShadow: [
                                  BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                                  BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                                ]
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              height: (MediaQuery.of(context).size.height * 0.15) / 2,
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: IconButton(
                                  onPressed: () {
                                    if (int.parse(i2["temp"]) > 0 &&
                                        i2["power"] == "on") {
                                      writeData((int.parse(i2["temp"]) - 1).toString(),
                                          "i2", "temp");
                                    }
                                  },
                                  color: Colors.black,
                                  icon: Icon(Icons.arrow_downward, size: 40,)

                              ),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 238, 238, 238),
                                  boxShadow: [
                                    BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                                    BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                                  ]
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      width: (MediaQuery.of(context).size.width * 0.30),
                      child: Text(
                        i2["power"] == "off"
                            ? "\n\n\nOFF"
                            : "\n" +
                            temp[int.parse(
                                i2["temp"])].toString() + " w" + "\n\n" +
                            i2["temperature"].toString() +
                            "°C" +
                            "\n\n" +
                            i2["current"].toString() +
                            " A",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.02,
                          color: Colors.black,
                        ), textAlign: TextAlign.center,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 238, 238, 238),
                          boxShadow: [
                            BoxShadow(offset: Offset(10, 10),color: Color.fromARGB(80, 0, 0, 0),blurRadius: 10),
                            BoxShadow(offset: Offset(-10, -10),color: Color.fromARGB(150, 255, 255, 255),blurRadius: 10)
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void readData() {
    _firebase.once().then((DataSnapshot value) {
      setState(() {
        i1 = value.value["i1"];
        i2 = value.value["i2"];
        power = value.value["power"];
      });
    });
  }

  void writeData(String data, String child, String type) {
    print("Child: " + child + " " + "{" + type + " : " + data + "}");
    _firebase.child(child).update({type: data});
  }
}
