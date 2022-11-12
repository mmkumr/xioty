import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;
  
  const ChatPage({this.server});
  
  @override
  _ChatPage createState() => new _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  String temp = "";
  String humi = "";
  String pinNum = "";
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  String _messageBuffer = '';

  bool isConnecting = true;
  bool button13 = false;
  bool button12 = false;
  bool button11 = false;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

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
      print('Cannot connect, exception occured');
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: (
          isConnecting ? Text('Connecting to ' + widget.server.name + '...') :
          isConnected ? Text('Connected with ' + widget.server.name) :
          Text('Disconnected from ' + widget.server.name)
        )
      ),
      body: Center(
          child: isConnecting ? Text('Wait until connected...',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto"
            ),
          ) :
          isConnected ? Column(

              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('assets/51-512.png'),
                      width: 100,
                      height: 100,
                    ),
                    Text('$temp\u00b0C',
                      style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Roboto"
                      ),),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage('assets/1594775.png'),
                      width: 100,
                      height: 100,
                    ),
                    Text('$humi%',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto"
                    ),
                    ),

                  ],

                ),
                Divider(
                  color: Colors.black,
                  thickness: 3,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 30, 10),
                  child: Row(
                    children: <Widget>[
                      Text("Pin 13  ",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto"
                        ),
                      ),
                      ButtonTheme(
                        minWidth: 120,
                        height: 50,
                        child: RaisedButton(
                            color: button13 ? Colors.red : Colors.green,

                            child: button13 ? Text("Turn Off") :Text("Turn On"),


                            onPressed: () => button13 ? _sendMessage('13 off') : _sendMessage('13 on')
                        ),
                      )

                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
                  child: Row(
                    children: <Widget>[
                      Text("Pin 12  ",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto"
                        ),
                      ),
                  ButtonTheme(
                    minWidth: 120,
                    height: 50,
                    child: RaisedButton(
                        color: button12 ? Colors.red : Colors.green,

                          child: button12 ? Text("Turn Off") :Text("Turn On"),


                          onPressed: () => button12 ? _sendMessage('12 off') : _sendMessage('12 on')
                      ),
                  )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 30, 10),
                  child: Row(
                    children: <Widget>[
                      Text("Pin 11  ",
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto"
                        ),
                      ),
                  ButtonTheme(
                    minWidth: 120,
                    height: 50,
                    child: RaisedButton(
                          color: button11 ? Colors.red : Colors.green,

                          child: button11 ? Text("Turn Off") :Text("Turn On"),

                          onPressed: () => button11 ? _sendMessage('11 off') : _sendMessage('11 on')
                      ),
                  )
                    ],
                  ),
                ),

              ]
          ): Text('Got disconnected',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto"
            ),)

      )
    );
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
        if (received_data.substring(0, 5) == 'temp:'){
          temp = received_data.substring(5, received_data.length);
        }

        if (received_data.substring(0, 5) == 'humi:'){
          humi = received_data.substring(5, received_data.length);
        }

        if (received_data == "13 on"){
          button13 = true;
        }
        if (received_data == "13 off"){
          button13 = false;
        }
        if (received_data == "12 on"){
          button12 = true;
        }
        if (received_data == "12 off"){
          button12 = false;
        }
        if (received_data == "11 on"){
          button11 = true;
        }
        if (received_data == "11 off"){
          button11 = false;
        }
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
}
