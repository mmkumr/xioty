import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/save_commands.dart';
import 'package:botchef_v2/pages/saved_command.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedCommands extends StatefulWidget {
  final String uid;
  const SavedCommands({super.key, required this.uid});

  @override
  State<SavedCommands> createState() => _SavedCommandsState();
}

class _SavedCommandsState extends State<SavedCommands> {
  List<QueryDocumentSnapshot> commands = [];
  @override
  void didChangeDependencies() {
    getSavedCommands();
    super.didChangeDependencies();
  }

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
      body: Center(
        child: ListView.builder(
          itemCount: commands.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
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
    );
  }

  getSavedCommands() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    commands = await SavedCommandsServices().get(user.user.uid);
    setState(() {});
  }
}
