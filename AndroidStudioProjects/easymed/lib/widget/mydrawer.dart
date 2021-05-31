import 'package:easymed/main.dart';
import 'package:easymed/search.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({Key key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              );
            },
            leading: Icon(
              Icons.add_box_outlined,
              color: Colors.orange,
            ),
            title: Text("Add Medicine"),
          ),
          Divider(),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Search(),
                ),
              );
            },
            leading: Icon(
              Icons.medical_services,
              color: Colors.orange,
            ),
            title: Text("Get Medicines"),
          ),
          Divider(),
        ],
      ),
    );
  }
}
