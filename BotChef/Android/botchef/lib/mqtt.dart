import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

ByteData? cacert;

class CACert {
  static getCert() async {
    cacert = await rootBundle.load('certs/ca.pem');
  }
}

enum Pause { wait, processing, run }

class MQTTPage extends StatefulWidget {
  final MqttServerClient client = MqttServerClient.withPort(
      '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud', '', 8883);

  MQTTPage({super.key}) {
    // MQTT setup
    client.logging(on: true);
    client.onDisconnected = onDisconnected;
    client.autoReconnect = true;
    client.pongCallback = pong;
    client.onSubscribed = onSubscribed;
    client.onConnected = onConnected;
    client.onAutoReconnect = onReconnect;

    /// Security context
    CACert.getCert();
    SecurityContext context = SecurityContext()
      ..setTrustedCertificatesBytes(cacert!.buffer.asUint8List());
    client.secure = true;
    client.securityContext = context;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('android')
        .withWillTopic('willtopic')
        .withWillMessage('Will Message')
        .startClean();
    client.keepAlivePeriod = 1800;
    client.connectionMessage = connMessage;

    client.connect('xioty', 'P@ssw0rd');
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

  void onReconnect() {
    client.port = 1883;
  }

  // MQTT setup end
  @override
  State<MQTTPage> createState() => _MQTTPageState();
}

class _MQTTPageState extends State<MQTTPage> {
  @override
  void initState() {
    commands = {
      'G': arm,
      'M': arm,
      'T': arm,
      'ind': induction,
      'i': ingredients,
      'S': gripper,
      'stir': stir,
      'Tool': arm,
      'delay': delay,
    };
    super.initState();
  }

  Map commands = {};
  List cmdHist = [];
  int histIndex = -1;
  String receivedMessage = '';
  bool sending = false;
  bool start = false;
  File? file;
  List<String> data = [];
  List<String> tempData = [];
  int index = 0;
  TextEditingController input = TextEditingController();

  Pause pause = Pause.run;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Flutter App'),
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
                      },
                      child: const Text("Pause"),
                    ),
                  if (pause == Pause.processing)
                    MaterialButton(
                      color: Colors.blue,
                      onPressed: () async {
                        setState(() {
                          tempData = data;
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
                              if (element.split(' ')[0][0] == 'G' ||
                                  element.split(' ')[0][0] == 'M' ||
                                  element.split(' ')[0][0] == 'T') {
                                return false;
                              }
                              if (!commands
                                  .containsKey(element.split(' ')[0])) {
                                return true;
                              }
                              return false;
                            });
                          });
                          if (data.isNotEmpty) {
                            setState(() {
                              sending = true;
                            });
                            setState(() {
                              int i = 0;
                              try {
                                data.firstWhere((element) {
                                  if (element != tempData[i]) {
                                    if (i < index) {
                                      setState(() {
                                        index = i;
                                      });
                                    }
                                    return true;
                                  }
                                  i++;
                                  return false;
                                });
                              } catch (e) {
                                Fluttertoast.showToast(msg: 'No changes!');
                                setState(() {
                                  pause = Pause.run;
                                });
                              }
                            });
                            if (data[index].split(' ')[0][0] == 'G' ||
                                data[index].split(' ')[0][0] == 'M' ||
                                data[index].split(' ')[0][0] == 'T' ||
                                data[index].split(' ')[0][0] == 'M') {
                              commands[data[index].split(' ')[0][0]](
                                  data[index]);
                            } else {
                              commands[data[index].split(' ')[0]](data[index]);
                            }
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
                      if (widget.client.connectionStatus!.state ==
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
                        data = await file!.readAsLines();
                        setState(() {
                          data.removeWhere((element) {
                            if (element.split(' ')[0][0] == 'G' ||
                                element.split(' ')[0][0] == 'M' ||
                                element.split(' ')[0][0] == 'T') {
                              return false;
                            }
                            if (!commands.containsKey(element.split(' ')[0])) {
                              return true;
                            }
                            return false;
                          });
                        });
                        debugPrint(data.toString());
                        if (data.isNotEmpty || data.length < 4) {
                          setState(() {
                            sending = true;
                          });
                          for (int i = 0; i < 4; i++) {
                            if (data[i].split(' ')[0][0] == 'G' ||
                                data[i].split(' ')[0][0] == 'M' ||
                                data[i].split(' ')[0][0] == 'T') {
                              commands[data[i].split(' ')[0][0]](data[i]);
                            } else {
                              commands[data[i].split(' ')[0]](data[i]);
                            }
                          }
                          index = 4;
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
                        if (widget.client.connectionStatus!.state ==
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
                          if (input.text.split(' ')[0][0] == 'G' ||
                              input.text.split(' ')[0][0] == 'M' ||
                              input.text.split(' ')[0][0] == 'T') {
                            commands[input.text.split(' ')[0][0]](input.text);
                          } else {
                            commands[input.text.split(' ')[0]](input.text);
                          }
                          setState(() {
                            data.add(input.text);
                            sending = true;
                          });
                        } on NoSuchMethodError catch (e) {
                          debugPrint(e.toString());
                          Fluttertoast.showToast(
                            msg: 'Invalid command',
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
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

//Function for commands
  arm(String cmd) async {
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

  delay(String cmd) async {
    await Future.delayed(
      Duration(
        seconds: int.parse(
          cmd.split(' ')[1],
        ),
      ),
    );
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

//end of Function for commands
  subscribe() async {
    widget.client.subscribe('response', MqttQos.atLeastOnce);
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
        if (pause == Pause.wait) {
          setState(() {
            pause = Pause.processing;
          });
        } else if (index < data.length) {
          if (data[index].split(' ')[0][0] == 'G' ||
              data[index].split(' ')[0][0] == 'M' ||
              data[index].split(' ')[0][0] == 'T' ||
              data[index].split(' ')[0][0] == 'M') {
            commands[data[index].split(' ')[0][0]](data[index]);
          } else {
            commands[data[index].split(' ')[0]](data[index]);
          }
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
