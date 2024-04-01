import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum Pause { wait, processing, run }

class MQTTPage extends StatefulWidget {
  MQTTPage({super.key}) {}
  @override
  State<MQTTPage> createState() => _MQTTPageState();
}

class _MQTTPageState extends State<MQTTPage> {
  @override
  void initState() {
    mqttinit();
    super.initState();
  }

  final MqttServerClient client = MqttServerClient.withPort(
      '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud', '', 8883);

  List cmdHist = [];
  int histIndex = -1;
  String receivedMessage = '';
  bool sending = false;
  bool start = false;
  File? file;
  String data = "";
  List<String> tempData = [];
  int index = 0;
  TextEditingController input = TextEditingController();

  Pause pause = Pause.run;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Flutter App'),
        actions: [
          IconButton(
            onPressed: () {
              sendData("shutdown", "xara/cmd");
            },
            icon: Icon(Icons.power_off, color: Colors.red),
          ),
        ],
      ),
      body: Center(
        child: sending
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (pause == Pause.run)
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          pause = Pause.wait;
                        });
                        sendData("pause", "xara/cmd");
                      },
                      child: const Text("Pause"),
                    ),
                  if (pause == Pause.wait)
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        await FilePicker.platform.clearTemporaryFiles();
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['txt'],
                        );
                        if (result != null) {
                          file = File(result.files.single.path!);
                          data = await file!.readAsString();
                          data = data.replaceAll('\n', "@");
                          debugPrint(data);
                          if (data.isNotEmpty || data.length < 4) {
                            sendData(data, "xara/cmd");
                            setState(() {
                              sending = true;
                            });
                          }
                        } else {
                          if (context.mounted) {
                            Fluttertoast.showToast(
                              msg: 'Failed to add file!',
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }
                        setState(() {
                          pause = Pause.run;
                        });
                      },
                      child: const Text("Resume"),
                    ),
                  const CircularProgressIndicator(),
                  const Text('Sending command(s). Please wait!'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      if (client.connectionStatus!.state ==
                              MqttConnectionState.connected &&
                          !start) {
                        subscribe();
                        setState(() {
                          start = true;
                        });
                      }
                      await FilePicker.platform.clearTemporaryFiles();
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['txt'],
                      );
                      if (result != null) {
                        file = File(result.files.single.path!);
                        data = await file!.readAsString();
                        data = data.replaceAll('\n', "@");
                        debugPrint(data);
                        if (data.isNotEmpty || data.length < 4) {
                          sendData(data, "xara/cmd");
                          setState(() {
                            sending = true;
                          });
                        }
                      } else {
                        if (context.mounted) {
                          Fluttertoast.showToast(
                            msg: 'Failed to add file!',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        }
                      }
                    },
                    child: const Text("Select command file"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (histIndex < cmdHist.length - 1) histIndex++;
                          debugPrint(histIndex.toString());
                          if (cmdHist.isNotEmpty)
                            input.text = cmdHist[histIndex];
                        });
                      },
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 50,
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: input,
                      onEditingComplete: () async {
                        if (client.connectionStatus!.state ==
                                MqttConnectionState.connected &&
                            !start) {
                          subscribe();
                          setState(() {
                            start = true;
                          });
                        }
                        try {
                          setState(() {
                            cmdHist.insert(0, input.text);
                          });
                          setState(() {
                            sendData(input.text, "xara/cmd");
                            sending = true;
                          });
                        } on ConnectionException catch (e) {
                          debugPrint(e.toString());
                          Fluttertoast.showToast(
                            msg: 'MQTT server not connected',
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (histIndex > 0) histIndex--;
                          debugPrint(histIndex.toString());
                          if (cmdHist.isNotEmpty)
                            input.text = cmdHist[histIndex];
                        });
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 50,
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  mqttinit() async {
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.autoReconnect = true;
    client.pongCallback = pong;
    client.onSubscribed = onSubscribed;
    client.onConnected = onConnected;
    client.onAutoReconnect = onReconnect;
    ByteData cacert = await rootBundle.load('certs/ca.pem');
    SecurityContext context = SecurityContext()
      ..setTrustedCertificatesBytes(cacert.buffer.asUint8List());
    client.secure = true;
    client.securityContext = context;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('android')
        .withWillTopic('willtopic')
        .withWillMessage('Will Message')
        .startClean();
    client.keepAlivePeriod = 300;
    client.connectionMessage = connMessage;
    client.connect('xioty', 'P@ssw0rd');
  }

  subscribe() async {
    client.subscribe('response', MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        receivedMessage = pt;
      });

      debugPrint('Topic is <${c[0].topic}>, Received payload $pt');

      if (receivedMessage == 'ok') {
        Fluttertoast.showToast(
          msg: 'Rpi successfully executed all commands',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );
        setState(() {
          sending = false;
          data = '';
          receivedMessage = '';
        });
      }

      if (receivedMessage == 'pause') {
        Fluttertoast.showToast(
          msg: 'Rpi has been paused',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );
        setState(() {
          receivedMessage = '';
          pause = Pause.wait;
        });
      }

      if (receivedMessage == 'Shutdown') {
        Fluttertoast.showToast(
          msg: 'Rpi is shutting down',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );
        setState(() {
          sending = false;
          data = '';
          receivedMessage = '';
        });
      }
      if (receivedMessage == 'received') {
        Fluttertoast.showToast(
          msg: 'Commands received by the Rpi',
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          timeInSecForIosWeb: 5,
        );
        setState(() {
          data = '';
          receivedMessage = '';
        });
      }
    });
  }

  sendData(String cmd, String topic) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(cmd);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

// Mqtt callback functions.
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

  void onReconnect() {
    client.port = 8883;
  }
// end of mqtt callback functions.
}
