import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final MqttServerClient client = MqttServerClient('192.168.29.219', '');
  MyApp({super.key}) {
    // MQTT setup
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.autoReconnect = true;
    client.pongCallback = pong;
    client.onSubscribed = onSubscribed;
    client.onConnected = onConnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('android')
        .withWillTopic('willtopic')
        .withWillMessage('Will Message')
        .startClean();
    client.keepAlivePeriod = 60;
    client.connectionMessage = connMessage;

    client.connect('xara', 'xara');
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void pong() {
    debugPrint('Ping response client callback invoked');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscription confirmed for topic $topic');
  }

  void onConnected() {
    debugPrint('Client connection was successful');
  }

  // MQTT setup end
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    commands = {
      'G0': arm,
      'H': arm,
      'ind': induction,
      'M': ingredients,
      'S': gripper,
      'stir': stir
    };
    super.initState();
  }

  Map commands = {};
  String receivedMessage = '';
  bool sending = false;
  bool start = false;
  File? file;
  List<String> data = [];
  int index = 0;
  TextEditingController input = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MQTT Flutter App'),
        ),
        body: Center(
          child: sending
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Sending command(s). Please wait!'),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          sending = true;
                        });
                        await FilePicker.platform.clearTemporaryFiles();
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['txt'],
                        );
                        if (result != null) {
                          file = File(result.files.single.path!);
                          data = await file!.readAsLines();
                          setState(() {
                            data.removeWhere((element) {
                              if (!commands
                                  .containsKey(element.split(' ')[0])) {
                                return true;
                              }
                              return false;
                            });
                          });
                          debugPrint(data.toString());
                          if (data.isNotEmpty) {
                            commands[data[0].split(' ')[0]](data[0]);
                          }
                          if (widget.client.connectionStatus!.state ==
                                  MqttConnectionState.connected &&
                              !start) {
                            subscribe();
                            setState(() {
                              start = true;
                            });
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to add file!'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Select command file"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: input,
                        onEditingComplete: () {
                          if (widget.client.connectionStatus!.state ==
                                  MqttConnectionState.connected &&
                              !start) {
                            subscribe();
                            setState(() {
                              start = true;
                            });
                          }
                          try {
                            commands[input.text.split(' ')[0]](input.text);
                            setState(() {
                              data.add(input.text);
                              sending = true;
                            });
                          } catch (e) {
                            debugPrint(e.toString());
                            Fluttertoast.showToast(
                              msg: 'Invalid command',
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                          debugPrint(input.text);
                          input.clear();
                        },
                        decoration: const InputDecoration(
                          labelText: "Command", //babel text
                          hintText: "Enter command", //hint text
                          prefixIcon: Icon(
                            Icons.keyboard_arrow_right,
                            size: 40,
                          ), //prefix iocn
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

//Function for commands
  arm(String cmd) {
    sendData(cmd, 'xara/arm');
  }

  induction(String cmd) {
    sendData(cmd, 'xara/induction');
  }

  ingredients(String cmd) {
    sendData(cmd, 'xara/ingredients');
  }

  gripper(String cmd) {
    sendData(cmd, 'xara/gripper');
  }

  stir(String cmd) {
    sendData(cmd, 'xara/stir');
  }

//end of Function for commands
  subscribe() {
    widget.client.subscribe('response', MqttQos.atMostOnce);
    widget.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        receivedMessage = pt;
      });

      debugPrint('Topic is <${c[0].topic}>, Received payload $pt');

      if (receivedMessage == 'o') {
        index++;
        if (index < data.length) {
          commands[data[index].split(' ')[0]](data[index]);
        } else {
          setState(() {
            index = 0;
            sending = false;
            data.clear();
            receivedMessage = '';
          });
        }
      }
    });
  }

  sendData(String cmd, String topic) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(cmd);
    widget.client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }
}
