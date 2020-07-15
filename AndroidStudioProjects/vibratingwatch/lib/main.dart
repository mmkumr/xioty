import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:vibratingwatch/MainPage.dart';

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
      home: MainPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final BluetoothDevice server;

  const HomePage({this.server});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  String _messageBuffer = '';

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        }
        else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }


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

  Future _selectDateTime(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(DateTime.now().year),
        lastDate: new DateTime(DateTime.now().year + 1));

    if (datePicked != null) {
      if (datePicked.day == DateTime.now().day &&
          datePicked.month == DateTime.now().month &&
          datePicked.year == DateTime.now().year) {
        timePicked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute));
        if (timePicked != null && timePicked != _time) {
          setState(() {
            _time = timePicked;
          });
        }
      } else{
        timePicked = await showTimePicker(
            context: context,
            initialTime: _time);
        if (timePicked != null && timePicked != _time) {
          setState(() {
            _time = timePicked;
          });
        }
      }
      setState(() {
        _date = datePicked;
        dateTime = "adateTime" + ":" + _date.day.toString() + ":" + _date.month.toString() + ":"
            + _date.year.toString() + ":" + _time.hourOfPeriod.toString() + ":" + _time.minute.toString();
        _sendMessage(dateTime);
        dateTimeShow = "\nDate: " + _date.day.toString() + "/" + _date.month.toString() + "/"
            + _date.year.toString() + "\nTime: " + _time.hourOfPeriod.toString() + ":" + _time.minute.toString();
      });
    }
  }

  Future _selectAlarm(BuildContext context) async {
    final DateTime alarmDatePicked = await showDatePicker(
        context: context,
        initialDate: _alarmDate,
        firstDate: new DateTime(DateTime.now().year),
        lastDate: new DateTime(DateTime.now().year + 1));

    if (alarmDatePicked != null) {
      if (alarmDatePicked.day == DateTime.now().day &&
          alarmDatePicked.month == DateTime.now().month &&
          alarmDatePicked.year == DateTime.now().year) {
          alarmPicked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: TimeOfDay.now().hour, minute: TimeOfDay.now().minute));
        if (alarmPicked != null && alarmPicked != _time) {
          setState(() {
            _alarmTime = alarmPicked;
          });
        }
      } else{
        alarmPicked = await showTimePicker(
            context: context,
            initialTime: _alarmTime);
        if (alarmPicked != null && alarmPicked != _alarmTime) {
          setState(() {
            _alarmTime = alarmPicked;
          });
        }
      }
      setState(() {
        _alarmDate = alarmDatePicked;
        alarmDateTime = "aalarm" + ":" + _alarmDate.day.toString() + ":" + _alarmDate.month.toString() + ":"
            + _alarmDate.year.toString() + ":" + _alarmTime.hourOfPeriod.toString() + ":" + _alarmTime.minute.toString();
        _sendMessage(alarmDateTime);
        alarmDateTimeShow = "\nDate: " + _alarmDate.day.toString() + "/" + _alarmDate.month.toString() + "/"
            + _alarmDate.year.toString() + "\nTime: " + _alarmTime.hourOfPeriod.toString() + ":" + _alarmTime.minute.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Vibtch", textAlign: TextAlign.center,)),
      ),
      body: SingleChildScrollView(
        child: Center(
          heightFactor: 1.5,
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
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.width/2,
                        child: dateTime == null? new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.watch),
                            Text("Set Time and date")
                          ],
                        ) :
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Date and Time", style: TextStyle(fontWeight: FontWeight.bold),),
                            new Text(dateTimeShow),
                          ],
                        ),
                      ),
                      onTap: (){
                        _selectDateTime(context);
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipOval(
                  child: Material(
                    color: Colors.deepOrange,
                    child: InkWell(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width/2,
                        height: MediaQuery.of(context).size.width/2,
                        child: alarmDateTime == null? new Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.alarm),
                            Text("Set Alarm")
                          ],
                        ) :
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Alarm", style: TextStyle(fontWeight: FontWeight.bold),),
                            new Text(alarmDateTimeShow),
                          ],
                        ),
                      ),
                      onTap: (){
                        _selectAlarm(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0)  {
      print(utf8.encode(text + "\r\n"));
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
//          messages.add(_Message(clientID, text));
        });

      }
      catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
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
      }
      else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        }
        else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) { // \r\n
      setState(() {
        String received_data = _messageBuffer + dataString.substring(0, index);
        received_data = received_data.trim();
//        print(received_data);
//        print(received_data.substring(0, 4));
//        print(received_data.length);
        _messageBuffer = dataString.substring(index);
      });
    }
    else {
      _messageBuffer = (
          backspacesCounter > 0
              ? _messageBuffer.substring(0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer
              + dataString
      );
    }
  }

}
