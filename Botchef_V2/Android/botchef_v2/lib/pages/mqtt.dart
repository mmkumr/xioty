import 'dart:convert';
import 'dart:io';

import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/pages/machine_connect.dart';
import 'package:botchef_v2/partials/menu.dart';
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
  // Palette matching the "Robot Controller" design.
  static const Color _navy = Color(0xFF1B2A4E);
  static const Color _blue = Color(0xFF2F6FED);
  static const Color _bg = Color(0xFFF3F6FB);
  static const Color _cardBg = Colors.white;
  static const Color _muted = Color(0xFF8A93A6);

  @override
  void didChangeDependencies() {
    prefs.containsKey("cmdHist").then((value) async {
      if (value) {
        cmdHist = await prefs.getStringList("cmdHist") ?? [];
        cmdTimes = await prefs.getStringList("cmdTimes") ?? [];
        if (cmdTimes.length != cmdHist.length) {
          cmdTimes = List.generate(cmdHist.length, (_) => '--:--:--');
        }
        setState(() {});
      } else {
        cmdHist = [];
        cmdTimes = [];
        prefs.setStringList("cmdHist", []);
        prefs.setStringList("cmdTimes", []);
        setState(() {});
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
    client.unsubscribe("response");
    input.dispose();
    name.dispose();
    super.dispose();
  }

  final MqttServerClient client = MqttServerClient.withPort(
      '6b3b54fa5f4a464fa80e2e0410aec35e.s2.eu.hivemq.cloud', '', 8883);
  String sendingTopic = "/xara/cmds/";
  List<String> cmdHist = [];
  List<String> cmdTimes = [];
  List<String> sentHist = [];
  String receivedMessage = '';
  bool sending = false;
  bool start = false;
  File? file;
  String data = "";
  int index = 0;
  TextEditingController input = TextEditingController();
  SharedPreferencesAsync prefs = SharedPreferencesAsync();
  TextEditingController name = TextEditingController();

  // Current machine position, updated from Rpi status payloads. See
  // _updateStatusFromPayload() below - adjust it to match your Rpi's
// actual status message format.
  double posX = 0;
  double posY = 0;
  double posZ = 0;
  double posA = 0;
  double posB = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            Icon(Icons.precision_manufacturing, color: _navy, size: 30),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Robot Controller',
                  style: TextStyle(
                      color: _navy, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Send G-code Commands',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.power_off, color: _navy),
            tooltip: 'Settings',
            onSelected: (value) {
              if (value == 'shutdown') {
                sendData("Shutdown", sendingTopic, false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'shutdown',
                child: Row(
                  children: [
                    Icon(Icons.power_off, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Shutdown Rpi'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: menu(context),
      body:
          //   sending
          // ? const Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         CircularProgressIndicator(),
          //         SizedBox(height: 12),
          //         Text('Sending command(s). Please wait!'),
          //       ],
          //     ),
          //   )
          // :
          SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              _statusCard(),
              const SizedBox(height: 16),
              _commandCard(),
              const SizedBox(height: 16),
              Expanded(child: _historyCard()),
              const SizedBox(height: 12),
              _bottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI building blocks ----------------

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _blue, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
              color: _navy, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _statusCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.sensors, 'Current Position'),
          const SizedBox(height: 14),
          Row(
            children: [
              _statBox('X', posX),
              const SizedBox(width: 8),
              _statBox('Y', posY),
              const SizedBox(width: 8),
              _statBox('Z', posZ),
              const SizedBox(width: 8),
              _statBox('A', posA),
              const SizedBox(width: 8),
              _statBox('B', posB),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, double value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: _blue, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                  color: _navy, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commandCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.keyboard, 'Enter Command'),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  onEditingComplete: _handleSend,
                  decoration: InputDecoration(
                    hintText: 'Enter G-code command...',
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  _arrowButton(Icons.keyboard_arrow_up, _historyUp),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    onPressed: _handleSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Send'),
                  ),
                  const SizedBox(height: 6),
                  _arrowButton(Icons.keyboard_arrow_down, _historyDown),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _handleRecord,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              icon: const Icon(Icons.fiber_manual_record, size: 16),
              label: const Text('Record'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _blue,
        side: BorderSide(color: _blue.withOpacity(0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size.zero,
      ),
      child: Icon(icon, size: 20),
    );
  }

  Widget _historyCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.history, 'Recorded Commands'),
          const SizedBox(height: 8),
          Expanded(
            child: cmdHist.isEmpty
                ? const Center(
                    child: Text('No commands yet',
                        style: TextStyle(color: _muted)),
                  )
                : ListView.separated(
                    itemCount: cmdHist.length,
                    separatorBuilder: (context, i) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, i) {
                      final revIndex = (cmdHist.length - 1) - i;
                      final time =
                          revIndex < cmdTimes.length ? cmdTimes[revIndex] : '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: _blue, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cmdHist[revIndex],
                                style: const TextStyle(
                                    color: _navy, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              time,
                              style:
                                  const TextStyle(color: _muted, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                cmdHist.clear();
                cmdTimes.clear();
                index = 0;
              });
              prefs.setStringList('cmdHist', cmdHist);
              prefs.setStringList('cmdTimes', cmdTimes);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => save(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save'),
          ),
        ),
      ],
    );
  }

  // ---------------- Actions ----------------

  void updateAxesFromCommand(String command) {
    final regex =
        RegExp(r'([XYZAB])\s*(-?\d+(?:\.\d+)?)', caseSensitive: false);

    for (final match in regex.allMatches(command)) {
      final axis = match.group(1)!.toUpperCase();
      final value = double.parse(match.group(2)!);

      switch (axis) {
        case 'X':
          posX = value;
          break;
        case 'Y':
          posY = value;
          break;
        case 'Z':
          posZ = value;
          break;
        case 'A':
          posA = value;
          break;
        case 'B':
          posB = value;
          break;
      }
    }

    setState(() {});
  }

  void _handleSend() {
    if (input.text.trim().isEmpty) return;
    if (client.connectionStatus!.state == MqttConnectionState.connected &&
        !start) {
      subscribe();
      setState(() {
        start = true;
      });
    }
    final cmd = input.text;
    sentHist.add(input.text);
    try {
      setState(() {
        sendData(cmd, sendingTopic, false);
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
    debugPrint(cmd);
    updateAxesFromCommand(input.text);
    input.clear();
  }

  void _handleRecord() {
    if (input.text.trim().isEmpty) return;
    setState(() {
      cmdHist.add(input.text);
      cmdTimes.add(_timestamp());
      index = 0;
    });
    prefs.setStringList('cmdHist', cmdHist);
    prefs.setStringList('cmdTimes', cmdTimes);
    Fluttertoast.showToast(
      msg: 'Command recorded',
      backgroundColor: _blue,
      textColor: Colors.white,
    );
  }

  void _historyUp() {
    if (sentHist.isEmpty) return;
    setState(() {
      if (index < sentHist.length) index++;
      input.text = sentHist[sentHist.length - index];
    });
  }

  void _historyDown() {
    if (sentHist.isEmpty) return;
    setState(() {
      if (index > 1) {
        index--;
        input.text = sentHist[sentHist.length - index];
      } else {
        index = 0;
        input.text = '';
      }
    });
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
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
            final user = Provider.of<UserProvider>(context, listen: false);
            SavedCommandsServices().add(
              uid: user.user.uid,
              commandName: name.text,
              commands: cmdHist,
            );
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
