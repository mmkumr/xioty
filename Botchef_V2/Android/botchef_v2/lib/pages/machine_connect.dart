import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/user.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class MachineConnectPage extends StatefulWidget {
  const MachineConnectPage({super.key});

  @override
  State<MachineConnectPage> createState() => _MachineConnectPageState();
}

class _MachineConnectPageState extends State<MachineConnectPage> {
  @override
  void didChangeDependencies() {
    final user = Provider.of<UserProvider>(context);
    macCode.text = user.userModel.machineId!;
    super.didChangeDependencies();
  }

  TextEditingController macCode = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Connect with your machine",
                style: TextStyle(
                  fontSize: width(context) * 0.06,
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
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter valid code for connecting";
                    }
                    return null;
                  },
                  onEditingComplete: () {
                    final user =
                        Provider.of<UserProvider>(context, listen: false);
                    if (form.currentState!.validate()) {
                      UserServices().updateMachineId(
                        uid: user.user.uid,
                        machineId: macCode.text,
                      );
                      navigate(
                        type: PageType.push,
                        context: context,
                        page: const HomePage(),
                      );
                    }
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
                  final user =
                      Provider.of<UserProvider>(context, listen: false);
                  if (form.currentState!.validate()) {
                    UserServices().updateMachineId(
                      uid: user.user.uid,
                      machineId: macCode.text,
                    );
                    navigate(
                      type: PageType.push,
                      context: context,
                      page: const HomePage(),
                    );
                  }
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
                  type: PageType.push,
                  context: context,
                  page: const HomePage(),
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
