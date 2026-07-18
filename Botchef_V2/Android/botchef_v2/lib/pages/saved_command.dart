import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
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
            child: MaterialButton(
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
}
