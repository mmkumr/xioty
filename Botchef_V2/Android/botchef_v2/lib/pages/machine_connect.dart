import 'package:botchef_v2/commons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MachineConnect extends StatefulWidget {
  const MachineConnect({super.key});

  @override
  State<MachineConnect> createState() => _MachineConnectState();
}

class _MachineConnectState extends State<MachineConnect> {
  TextEditingController macCode = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Connect with your machine",
                style: TextStyle(
                  fontSize: size(context: context, type: Type.width) * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text(
              "Please make sure the machine is turned ON",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            Form(
              key: form,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: macCode,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid code for connecting";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter the scratch code",
                    icon: const Icon(FontAwesomeIcons.robot),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: primaryC,
                  ),
                ),
              ),
            ),
            Image.asset(
              "assets/imgs/chefbot.png",
              height: 300,
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
                  if (form.currentState!.validate()) {}
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 10, bottom: 10),
                  child: Text(
                    "Connect",
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
            MaterialButton(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: elementsC,
              onPressed: () {
                navigate(
                  type: Type.push,
                  context: context,
                  page: const MachineConnect(),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30.0, right: 30.0, top: 10, bottom: 10),
                child: Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 20,
                    color: elementsC.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
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
