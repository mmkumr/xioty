import 'dart:io';

import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/models/user.dart';
import 'package:botchef_v2/pages/machine_connect.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

class MQTTPage extends StatefulWidget {
  const MQTTPage({super.key});
  @override
  State<MQTTPage> createState() => _MQTTPageState();
}

class _MQTTPageState extends State<MQTTPage> {
  @override
  void initState() {
    mqttinit();
    final user = Provider.of<UserProvider>(context, listen: false);
    sendingTopic += user.userModel.machineId!;
    if (sendingTopic.isEmpty) {
      Future(() {
        navigate(
            type: PageType.replace,
            context: context,
            page: const MachineConnectPage());
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  final MqttServerClient client = MqttServerClient.withPort(
      '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud', '', 8883);
  String sendingTopic = "/xara/cmds/";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MQTT Flutter App'),
        actions: [
          IconButton(
            onPressed: () {
              sendData("Shutdown", sendingTopic, false);
            },
            icon: const Icon(Icons.power_off, color: Colors.red),
          ),
        ],
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (histIndex < cmdHist.length - 1) histIndex++;
                          debugPrint(histIndex.toString());
                          if (cmdHist.isNotEmpty) {
                            input.text = cmdHist[histIndex];
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 50,
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
                            sendData(input.text, sendingTopic, false);
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
                          if (cmdHist.isNotEmpty) {
                            input.text = cmdHist[histIndex];
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 50,
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
    ByteData cacert = await rootBundle.load('assets/certs/ca.pem');
    SecurityContext cert = SecurityContext()
      ..setTrustedCertificatesBytes(cacert.buffer.asUint8List());
    client.secure = true;
    client.securityContext = cert;

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

      if (receivedMessage == 'Done') {
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
        sendData('', 'response', true);
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
        });
        sendData('', 'response', true);
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
        sendData('', 'response', true);
      }
      if (receivedMessage == 'Received') {
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
        sendData('', 'response', true);
      }
    });
  }

  sendData(String cmd, String topic, bool retain) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(cmd);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
        retain: retain);
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
