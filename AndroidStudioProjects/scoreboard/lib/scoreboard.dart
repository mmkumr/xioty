import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScoreBoard extends StatefulWidget {
  ScoreBoard({Key? key}) : super(key: key);

  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  DatabaseReference _firebase = FirebaseDatabase.instance.reference();
  late Map data;
  String name1 = "";
  String name2 = "";
  @override
  Widget build(BuildContext context) {
    readData();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Score Board")),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    onTap: () {},
                    leading: Text(
                      "Team 1:",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      data["player1"],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    onTap: () {},
                    leading: Text(
                      "Team 2:",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Text(
                      data["player2"],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Period",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (int.parse(data['period']) > 1) {
                                writeData(
                                  (int.parse(data['period']) - 1).toString(),
                                  "data",
                                  "period",
                                );
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          data['period'],
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (int.parse(data['period']) < 10) {
                                writeData(
                                  (int.parse(data['period']) + 1).toString(),
                                  "data",
                                  "period",
                                );
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Team 1 Score",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (int.parse(data['score1']) > 0) {
                                writeData(
                                  (int.parse(data['score1']) - 1).toString(),
                                  "data",
                                  "score1",
                                );
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          data['score1'],
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              writeData(
                                (int.parse(data['score1']) + 1).toString(),
                                "data",
                                "score1",
                              );
                            },
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Team 2 Score",
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 80,
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              if (int.parse(data['score2']) > 0) {
                                writeData(
                                  (int.parse(data['score2']) - 1).toString(),
                                  "data",
                                  "score2",
                                );
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.minus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          data['score2'],
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              writeData(
                                (int.parse(data['score2']) + 1).toString(),
                                "data",
                                "score2",
                              );
                            },
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void readData() {
    _firebase.once().then((DataSnapshot value) {
      setState(() {
        data = value.value["data"];
        name1 = data["player1"];
        name2 = data["player2"];
      });
    });
  }

  void writeData(String data, String child, String type) {
    print("Child: " + child + " " + "{" + type + " : " + data + "}");
    _firebase.child(child).update({type: data});
  }
}
