import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

void main() {
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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;

  String _messageBuffer = '';

  bool isConnecting = true;

  bool isDisconnecting = false;

  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();
  String dateTime;
  String dateTimeShow;
  TimeOfDay timePicked;

  DateTime _alarmDate = new DateTime.now();
  TimeOfDay _alarmTime = new TimeOfDay.now();
  String alarmDateTime;
  String alarmDateTimeShow;
  TimeOfDay alarmPicked;
  bool alarm = true;

  @override
  Widget build(BuildContext context) {
    print(_messageBuffer);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Setup",
            textAlign: TextAlign.center,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: SingleChildScrollView(
            child: Center(
                heightFactor: 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: Material(
                          color: Colors.deepOrange,
                          child: InkWell(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              height: MediaQuery.of(context).size.width / 2,
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Image.asset("images/clock.png"),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: dateTime == null
                            ? Container()
                            : Container(
                                color: Colors.white,
                                child: Text("${dateTimeShow}"),
                              )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: ClipOval(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2 + 70,
                              height:
                                  MediaQuery.of(context).size.width / 2 + 70,
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "images/alarm-clock.png",
                                    height:
                                        MediaQuery.of(context).size.width / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                  ),
                                ],
                              ),
                            ),
                            onTap: alarm == false ? () {} : () {},
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          child: alarmDateTimeShow == null
                              ? Container()
                              : Container(
                                  child: Text(alarmDateTimeShow),
                                ),
                          color: alarm == false ? Colors.red : Colors.green,
                          onPressed: () {
                            if (alarm == true) {
                              setState(() {
                                alarm = false;
                                alarmDateTime = "a" +
                                    ":" +
                                    "0" +
                                    ":" +
                                    "0" +
                                    ":" +
                                    "0" +
                                    ":" +
                                    "-1" +
                                    ":" +
                                    "-1";
                                _sendMessage(alarmDateTime);
                              });
                            } else if (alarm == false) {
                              setState(() {
                                alarm = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ));
  }

  void _sendMessage(String text) async {}

  changeAlarm() {
    if (alarm == true) {
      setState(() {
        alarm = false;
        alarmDateTime =
            "a" + ":" + "0" + ":" + "0" + ":" + "0" + ":" + "-1" + ":" + "-1";
        _sendMessage(alarmDateTime);
      });
    } else if (alarm == false) {
      print("ok");
      setState(() {
        alarm = true;
      });
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      // \r\n
      setState(() {
        String received_data = _messageBuffer + dataString.substring(0, index);
        received_data = received_data.trim();
//        print(received_data);
//        print(received_data.substring(0, 4));
//        print(received_data.length);
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
