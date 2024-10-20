import 'package:flutter/material.dart';
import 'package:xenobot/pages/kiosks.dart';

import '../commons.dart';

class NewKioskPage extends StatefulWidget {
  const NewKioskPage({super.key});

  @override
  State<NewKioskPage> createState() => _NewKioskPageState();
}

class _NewKioskPageState extends State<NewKioskPage> {
  TextEditingController kioskId = TextEditingController(text: "6");
  TextEditingController ownerName = TextEditingController();
  TextEditingController address = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: AppBar(
        title: const Text("New Kiosk"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: ownerName,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff6f2f2),
                  label: const Text(
                    "Owner Name",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: ownerName,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xfff6f2f2),
                  label: const Text(
                    "Kiosk Address",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "This field is required";
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MaterialButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: const KiosksPage());
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10, bottom: 10),
                  child: Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 20,
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
}
