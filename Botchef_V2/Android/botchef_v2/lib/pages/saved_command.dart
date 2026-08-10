import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:botchef_v2/services/mqtt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SavedCommand extends StatefulWidget {
  final String id;
  const SavedCommand({super.key, required this.id});

  @override
  State<SavedCommand> createState() => _SavedCommandState();
}

class _SavedCommandState extends State<SavedCommand> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCommands();
  }

  DocumentSnapshot? command;
  List commands = [];
  TextEditingController cmd = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    MQTTService.instance.unsubscribe('response');
    cmd.dispose();
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
                  String item = commands.removeAt(oldIndex);
                  commands.insert(newIndex, item);
                });
              },
              itemCount: commands.length,
              itemBuilder: (context, index) {
                return Padding(
                  key: ValueKey(index),
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    onTap: () {},
                    title: Text(commands[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Critical: Prevents the Row from expanding infinitely
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          style:
                              IconButton.styleFrom(shape: const CircleBorder()),
                          onPressed: () {
                            edit(commands[index], index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          style:
                              IconButton.styleFrom(shape: const CircleBorder()),
                          onPressed: () {
                            setState(() {
                              commands = commands.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
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
                  onPressed: () {
                    sendCommands();
                  },
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
                  onPressed: () {
                    save();
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  getCommands() async {
    command = await SavedCommandsServices().get(widget.id);
    commands = command!["commands"];
    setState(() {});
  }

  edit(String command, int index) {
    cmd.text = command;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Command"),
        content: TextField(
          controller: cmd,
          decoration: const InputDecoration(
            labelText: "Command Name",
            hintText: "Enter command name",
          ),
          onEditingComplete: () {
            setState(() {
              commands[index] = cmd.text;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  save() async {
    SavedCommandsServices().update(id: widget.id, commands: commands);
  }

  sendCommands() async {
    if (commands.isEmpty || sending) return;
    final user = Provider.of<UserProvider>(context, listen: false);
    final topic = "/xara/cmds/${user.userModel.machineId}";

    setState(() {
      sending = true;
    });

    await MQTTService.instance.connect(username: 'xioty', password: 'P@ssw0rd');
    MQTTService.instance.subscribe('response', _onMqttMessage);
    MQTTService.instance.sendData(commands.join("\n"), topic, false);

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

