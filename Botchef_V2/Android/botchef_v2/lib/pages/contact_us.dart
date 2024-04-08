import 'package:botchef_v2/commons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../partials/menu.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Contact Us"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Click on the tile for the action.",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    launchUrl(Uri.parse("tel:+916370194242"));
                  },
                  tileColor: Colors.white,
                  leading: const Icon(
                    Icons.phone,
                    color: Colors.deepOrange,
                  ),
                  trailing: const Icon(Icons.copy),
                  title: const Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(
                        "Phone",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text("+916370194242"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: Colors.white,
                  onTap: () {
                    launchUrl(
                      Uri.parse("https://xara.com"),
                    );
                  },
                  leading: const Icon(
                    FontAwesomeIcons.globe,
                    color: Colors.blue,
                  ),
                  trailing: const Icon(Icons.copy),
                  title: const Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(
                        "Website",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text("xara.com"),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: Colors.white,
                  onTap: () {
                    launchUrl(Uri.parse(
                        "mailto:rxhundred2021@gmail.com?suject=query through app"));
                  },
                  leading: const Icon(
                    Icons.email,
                    color: Colors.blue,
                  ),
                  trailing: const Icon(Icons.copy),
                  title: const Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(
                        "Email",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text("rxhundred2021@gmail.com"),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: Colors.white,
                  leading: Icon(
                    Icons.pin_drop,
                    color: Colors.greenAccent,
                  ),
                  title: Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      Text(
                        "Address",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      Text("Bhubaneswar, Odisha"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
