import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/pages/home.dart';
import 'package:xenobot/providers/kiosk_provide.dart';

import '../providers/user_provider.dart';

class ScanKiosk extends StatefulWidget {
  const ScanKiosk({super.key});

  @override
  State<ScanKiosk> createState() => _ScanKioskState();
}

class _ScanKioskState extends State<ScanKiosk> {
  TextEditingController code = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  String name = "";
  String address = "";
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    final kiosk = Provider.of<KioskProvider>(context);
    return Scaffold(
      backgroundColor: bgC,
      body: Center(
        child: Form(
          key: form,
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: width(context) * 0.9,
                    width: width(context) * 0.9,
                    child: MobileScanner(
                      onDetect: (capture) async {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          final data = json.decode(barcode.rawValue!);
                          debugPrint("Kiosk ID: ${data['Kiosk ID']}");
                          String kioskName = await kiosk.getKiosk(
                              data['Kiosk ID']); // For checking if id is valid.
                          if (kioskName.isNotEmpty) {
                            setState(() {
                              code.text = kiosk.kioskModel.id;
                              address = kiosk.kioskModel.address;
                              name = kiosk.kioskModel.name;
                            });
                          } else {
                            code.clear();
                            address = "";
                            name = "";
                          }
                        }
                      },
                    ),
                  ),
                  const Text(
                    "Scan QR to identify the kiosk",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const Text(
                    "\n\nOR",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: code,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Field can't be empty!";
                        }
                        return null;
                      },
                      onEditingComplete: () async {
                        String kioskName = await kiosk.getKiosk(
                            code.text); // For checking if id is valid.
                        if (kioskName.isNotEmpty) {
                          setState(() {
                            code.text = kiosk.kioskModel.id;
                            address = kiosk.kioskModel.address;
                            name = kiosk.kioskModel.name;
                          });
                        } else {
                          code.clear();
                          address = "";
                          name = "";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Kiosk ID",
                        icon: const Icon(Icons.food_bank),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: primaryC,
                      ),
                    ),
                  ),
                  Text("Name: $name"),
                  Text(
                    "Address: $address",
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: elementsC,
                      onPressed: () {
                        if (form.currentState!.validate() &&
                            name.isNotEmpty &&
                            address.isNotEmpty) {
                          navigate(
                              type: PageType.replace,
                              context: context,
                              page: const HomePage());
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Next",
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: MaterialButton(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: elementsC,
                      onPressed: () {
                        user.signOut();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Log Out",
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
          ),
        ),
      ),
    );
  }
}
