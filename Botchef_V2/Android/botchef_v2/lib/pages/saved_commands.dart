import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/pages/saved_command.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:botchef_v2/services/mqtt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SavedCommands extends StatefulWidget {
  final String uid;
  const SavedCommands({super.key, required this.uid});

  @override
  State<SavedCommands> createState() => _SavedCommandsState();
}

class _SavedCommandsState extends State<SavedCommands> {
  List<QueryDocumentSnapshot> commands = [];
  bool sending = false;

  @override
  void didChangeDependencies() {
    getSavedCommands();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    MQTTService.instance.unsubscribe('response');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sending) {
      return Scaffold(
        backgroundColor: bgC,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("Saved Commands"),
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = commands.removeAt(oldIndex);
                  commands.insert(newIndex, item);
                });
              },
              itemCount: commands.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  key: ValueKey(commands[index].id),
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20.0), // Adjust the radius here
                    ),
                    tileColor: primaryC,
                    title: Text(
                      commands[index].get("commandName"),
                    ),
                    onTap: () {
                      navigate(
                        type: PageType.push,
                        context: context,
                        page: SavedCommand(id: commands[index].id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: sendAll,
                  child: const Padding(
                    padding:
                        EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                    child: Text("Send"),
                  ),
                ),
                const SizedBox(width: 12),
                MaterialButton(
                  color: primaryC,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: saveOrder,
                  child: const Padding(
                    padding:
                        EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getSavedCommands() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    commands = await SavedCommandsServices().getAll(user.user.uid);
    commands.sort((a, b) {
      final orderA = (a.data() as Map<String, dynamic>)['order'] ?? 0;
      final orderB = (b.data() as Map<String, dynamic>)['order'] ?? 0;
      return (orderA as num).compareTo(orderB as num);
    });
    setState(() {});
  }

  // Persists the current on-screen order back to each document as an
  // `order` field, since the collection has no ordering field by default.
  // Goes straight through Firestore rather than SavedCommandsServices,
  // since that service doesn't currently expose an order-update method.
  saveOrder() async {
    for (var i = 0; i < commands.length; i++) {
      await FirebaseFirestore.instance
          .collection('savedCommands')
          .doc(commands[i].id)
          .update({'order': i});
    }
    if (!mounted) return;
    Fluttertoast.showToast(msg: "Order saved");
  }

  sendAll() async {
    if (commands.isEmpty || sending) return;
    final user = Provider.of<UserProvider>(context, listen: false);
    final topic = "/xara/cmds/${user.userModel.machineId}";

    final combined = <String>[];
    for (final doc in commands) {
      final data = doc.data() as Map<String, dynamic>;
      combined.addAll(List<String>.from(data['commands'] ?? []));
    }
    if (combined.isEmpty) return;

    setState(() {
      sending = true;
    });

    try {
      await MQTTService.instance
          .connect(username: 'xioty', password: 'P@ssw0rd');
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        sending = false;
      });
      Fluttertoast.showToast(
        msg: 'MQTT server not connected',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    MQTTService.instance.subscribe('response', _onMqttMessage);
    MQTTService.instance.sendData(combined.join("\n"), topic, false);

    // If nothing comes back in time, stop waiting and let the user know.
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted || !sending) return;
      setState(() {
        sending = false;
      });
      Fluttertoast.showToast(
        msg: "No response from the machine - check it's powered on",
        backgroundColor: Colors.red,
      );
    });
  }

  void _onMqttMessage(String topic, String payload) {
    if (!sending) return;
    if (payload == 'Received') {
      setState(() {
        sending = false;
      });
      Fluttertoast.showToast(msg: "Commands received by the machine");
      MQTTService.instance.sendData('', 'response', true);
    }
  }
}
