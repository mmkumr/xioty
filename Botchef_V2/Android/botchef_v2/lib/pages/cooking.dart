import 'dart:async';
import 'dart:io';

import 'package:botchef_v2/models/variant.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:botchef_v2/pages/rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../commons.dart';

class CookingPage extends StatefulWidget {
  final VariantModel variant;
  const CookingPage({super.key, required this.variant});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  int? timeDifference;
  int time = 0;
  bool start = false, pause = false;
  List instructions = [];
  String receivedMessage = '';
  bool sending = false;
  final MqttServerClient client = MqttServerClient.withPort(
      '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud', '', 8883);
  @override
  void initState() {
    if (widget.variant.cookingTime!.isNotEmpty) {
      timeDifference = int.parse(widget.variant.cookingTime!);
      time = timeDifference!;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await mqttinit();
    await createRecipe();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!start && client.connectionState == MqttConnectionState.disconnected) {
      if (receivedMessage == "Done") {
        Fluttertoast.showToast(msg: "Previous Recipe have been cooked");
        receivedMessage = "";
        sendData('', 'response', true);
      }
      Future.delayed(const Duration(seconds: 5), () {
        if (receivedMessage == "Received") {
          startCountdown();
          Fluttertoast.showToast(msg: "Started Cooking");
          receivedMessage = "";
          sendData('', 'response', true);
        } else {
          Future.delayed(Duration.zero, () {
            Fluttertoast.showToast(
              msg: "Please turn on you machine",
              backgroundColor: Colors.red,
            );
            sendData('', 'response', true);
            navigate(
                type: Type.replace, context: context, page: const HomePage());
          });
        }
      });
      start = true;
    } else if (receivedMessage == "Done" && start) {
      receivedMessage = "";
      sendData('', 'response', true);
      Future.delayed(Duration.zero, () {
        navigate(
            type: Type.replace,
            context: context,
            page: RatingPage(
              variant: widget.variant,
            ));
      });
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Please Wait\nYour food will be ready in:",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            widget.variant.cookingTime!.isEmpty
                ? const Text(
                    "Calculating time",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: CircularProgressIndicator(
                          strokeWidth: 20,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.black),
                          backgroundColor: Colors.grey,
                          value: (time / timeDifference!) * 1,
                        ),
                      ),
                      Text(
                          '${(Duration(seconds: time))}'
                              .split('.')[0]
                              .padLeft(8, '0')
                              .toString(),
                          style: const TextStyle(fontSize: 30)),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: MaterialButton(
                minWidth: 300,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  if (pause) {
                    setState(() {
                      pause = false;
                    });
                    sendData("Resume", "xara/cmds", false);
                  } else {
                    setState(() {
                      pause = true;
                    });
                    sendData("Pause", "xara/cmds", false);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    pause ? "Resume" : "Pause",
                    style: TextStyle(
                      fontSize: 30,
                      color: elementsC.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  startCountdown() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer timer) {
      if (time < 1) {
        setState(() {
          timer.cancel();
          Fluttertoast.showToast(msg: "Waiting for response from the machine!");
        });
      }
      if (pause) {
        timer.cancel();
      } else {
        setState(() {
          --time;
        });
      }
    });
  }

  createRecipe() {
    String prevType = "";
    instructions.add(widget.variant.vid);
    instructions.add("o6");
    for (Map operation in widget.variant.operations!) {
      bool induction = false;
      int indLevel = 2;
      List<String> waterLevels = ["1cup", "1/4cup", "1/2cup", "3/4cup"];
      List<String> heatLevels = [
        "100",
        "130",
        "160",
        "180",
        "200",
        "220",
        "240"
      ];
      if (operation["label"].contains("sm")) {
        String num = operation["label"][2];
        if (prevType == "M" || prevType == "lm") {
          instructions.add("itHome");
        }
        instructions.add("smu$num");
        for (int i = 0;
            i < int.parse(operation["param"].toString().replaceAll(" tsp", ""));
            i++) {
          instructions.add("tilt");
        }
        instructions.add("smd");
        prevType = "sm";
      } else if (operation["label"].contains("lm")) {
        String num = operation["label"][2];
        if (prevType == "sm") {
          instructions.add("itHome");
        }
        instructions.add("lmu$num");
        for (int i = 0;
            i < int.parse(operation["param"].replaceAll(" tsp", ""));
            i++) {
          instructions.add("squeeze");
        }
        instructions.add("lmd");
        prevType = "lm";
      } else if (operation["label"][0] == "M") {
        if (prevType == "sm") {
          instructions.add("itHome");
        }
        instructions.add(operation["label"]);
        prevType = "M";
      } else if (operation["label"].contains("o") &&
          operation["name"] == "Induction") {
        if (!induction) {
          instructions.add("indOn");
          induction = true;
        }
        int diff = indLevel - heatLevels.indexOf(operation["param"]);
        if (diff > 0) {
          for (var i = 0; i < diff.abs(); i++) {
            instructions.add("indDown");
          }
        } else if (diff < 0) {
          for (var i = 0; i < diff.abs(); i++) {
            instructions.add("indUp");
          }
        }
        indLevel = heatLevels.indexOf(operation["param"]);
      } else if (operation["label"].contains("o") &&
          operation["name"] == "Water") {
        int index = waterLevels.indexOf(operation["param"]);
        instructions.add("w$index");
      } else if (operation["label"].contains("o") &&
          operation["name"] == "Wait") {
        instructions.add("G4 S${operation["param"]}");
      } else if (operation["label"].contains("o") &&
          operation["name"] == "Shutdown") {
        instructions.add("Shutdown");
      } else if (operation["label"].contains("o")) {
        instructions.add(operation["label"]);
      }
    }
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
        .withClientIdentifier('1')
        .withWillTopic('willtopic')
        .withWillMessage('Will Message')
        .startClean();
    client.keepAlivePeriod = 60;
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
    subscribe();
    sendData(instructions.join("\n"), "xara/cmds", false);
  }

  void onReconnect() {
    client.port = 8883;
  }
// end of mqtt callback functions.
}
