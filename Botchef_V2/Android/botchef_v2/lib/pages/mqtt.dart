import 'dart:io';

import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/pages/machine_connect.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MQTTPage extends StatefulWidget {
  const MQTTPage({super.key});
  @override
  State<MQTTPage> createState() => _MQTTPageState();
}

class _MQTTPageState extends State<MQTTPage> {
  @override
  void didChangeDependencies() {
    prefs.containsKey("cmdHist").then((value) async {
      if (value) {
        cmdHist = await prefs.getStringList("cmdHist") ?? [];
      } else {
        cmdHist = [];
        prefs.setStringList("cmdHist", []);
      }
    });
    super.didChangeDependencies();
  }

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
  List<String> cmdHist = [];
  String receivedMessage = '';
  bool sending = false;
  bool start = false;
  File? file;
  String data = "";
  int index = 0;
  TextEditingController input = TextEditingController();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
  TextEditingController name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child:
            //     sending
            // ? const Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       CircularProgressIndicator(),
            //       Text('Sending command(s). Please wait!'),
            //     ],
            //   )
            // :
            Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      sendData(input.text, sendingTopic, false);
                      sending = true;
                      cmdHist.add(input.text);
                    });
                    prefs.setStringList('cmdHist', cmdHist);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      cmdHist.clear();
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12.0), // Adjust this for more/less roundness
                  ),
                  color: Colors.blue,
                  child: const Text("Clear"),
                ),
                MaterialButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12.0), // Adjust this for more/less roundness
                  ),
                  color: Colors.blue,
                  child: const Text("Save"),
                ),
              ],
            ),
            SizedBox(
              height: height(context) * 0.6,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: cmdHist.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      tileColor: Colors.black12,
                      title: Text(
                        cmdHist[(cmdHist.length - 1) - index],
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
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
  save() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Save Commands"),
        content: TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: "Command Name",
            hintText: "Enter command name",
          ),
          onEditingComplete: () {
            // Save the command name and commands to Firestore
            final user = Provider.of<UserProvider>(context, listen: false);
            SavedCommandsServices().add(
              uid: user.user.uid,
              commandName: name.text,
              commands: cmdHist,
            );
          },
        ),
      ),
    );
  }
}
