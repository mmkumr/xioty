import 'package:botchef_v2/pages/machine_connect.dart';
import 'package:flutter/material.dart';

import '../commons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset(
                "assets/imgs/logo.png",
                height: 100,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "`Some jobs are meant for machines!`",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              height: 60,
              child: MaterialButton(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/imgs/glogo.png",
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        "Login with google",
                        style: TextStyle(
                          color: elementsC.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
