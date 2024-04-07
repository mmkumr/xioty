import 'package:flutter/material.dart';

import '../commons.dart';

class UserMicroPage extends StatefulWidget {
  const UserMicroPage({super.key});

  @override
  State<UserMicroPage> createState() => _UserMicroPageState();
}

class _UserMicroPageState extends State<UserMicroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(Icons.save, size: 50),
            ),
          ),
        ],
        elevation: 0,
      ),
    );
  }
}
