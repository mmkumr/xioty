import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:picovoice_flutter/picovoice_manager.dart';
import 'package:picovoice_flutter/picovoice_error.dart';
import 'package:rhino_flutter/rhino.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
///////////////////////////picovoice
  PicovoiceManager? _picovoiceManager;
  bool listeningForCommand = false;
  final String accessKey =
      "+b4fkyh9nscp8W6Rtj/YiY2EhJII0mZImPhQ5m/g9Low5bJNtSfoMQ=="; // your Picovoice AccessKey
  String keywordAsset = "assets/picovoice/keywordAsset.ppn";
  String contextAsset = "assets/picovoice/contextAsset.rhn";
  void initPicovoice() async {
    try {
      _picovoiceManager = await PicovoiceManager.create(accessKey, keywordAsset,
          _wakeWordCallback, contextAsset, inferenceCallback);

      // start audio processing
      _picovoiceManager!.start();
    } on PicovoiceException catch (ex) {
      print(ex);
    }
  }

  void _wakeWordCallback() {
    setState(() {
      listeningForCommand = true;
    });
    Fluttertoast.showToast(
      msg: "voice mode",
    );
  }

  void inferenceCallback(RhinoInference inference) async {
    setState(() {
      connected = false;
    });
    await check();
    if (connected) {
      if (inference.isUnderstood != null) {
        if (inference.intent == 'Turnon') {
          Fluttertoast.showToast(
            msg: "Turning on",
          );
          setState(() {
            toggle = true;
          });
          toggleon();
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              push = true;
            });
            pushon();
          });
          Future.delayed(const Duration(seconds: 4), () {
            setState(() {
              push = false;
            });
            pushoff();
          });
        } else if (inference.intent == 'Turnoff') {
          setState(() {
            toggle = false;
          });
          toggleoff();
          Fluttertoast.showToast(
            msg: "Turning off",
          );
        } else {
          Fluttertoast.showToast(
            msg: "No command found",
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Device not connected",
      );
    }
    setState(() {
      listeningForCommand = false;
    });
  }

//////////////////Server fucntions
  bool connected = false;
  //String device = '192.168.4.1';
  String device = '192.168.194.218';
  check() async {
    var url = Uri.http(device);
    try {
      await http.get(url);
      setState(() {
        connected = true;
      });
    } catch (e) {
      setState(() {
        connected = false;
      });
    }
  }

  toggleon() async {
    var url = Uri.http(device, '26/on');
    try {
      await http.get(url);
      setState(() {
        connected = true;
      });
    } catch (e) {
      setState(() {
        connected = false;
      });
    }
  }

  toggleoff() async {
    var url = Uri.http(device, '26/off');
    try {
      await http.get(url);
      setState(() {
        connected = true;
      });
    } catch (e) {
      setState(() {
        connected = false;
      });
    }
  }

  pushon() async {
    var url = Uri.http(device, '27/on');
    try {
      await http.get(url);
      setState(() {
        connected = true;
      });
    } catch (e) {
      setState(() {
        connected = false;
      });
    }
  }

  pushoff() async {
    var url = Uri.http(device, '27/off');
    try {
      await http.get(url);
      setState(() {
        connected = true;
      });
    } catch (e) {
      setState(() {
        connected = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPicovoice();
  }

  bool toggle = false;
  bool push = false;
  @override
  Widget build(BuildContext context) {
    check();
    return Scaffold(
      backgroundColor: const Color(0xffD8E3E4),
      appBar: AppBar(
        backgroundColor: connected ? Colors.green : Colors.red,
        title: Center(
          child: Text(
            connected ? "Connected" : "Not connected",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30),
              child: NeumorphicButton(
                onPressed: () async {
                  setState(() {
                    connected = false;
                  });
                  if (!toggle) {
                    await toggleon();
                  } else {
                    await toggleoff();
                  }
                  if (connected == true) {
                    setState(() {
                      toggle = !toggle;
                    });
                  }
                },
                style: NeumorphicStyle(
                  shape:
                      !toggle ? NeumorphicShape.flat : NeumorphicShape.concave,
                  boxShape: const NeumorphicBoxShape.circle(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: !toggle
                      ? const Text(
                          "OFF",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        )
                      : const Text(
                          "ON",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: NeumorphicButton(
                onPressed: () async {
                  setState(() {
                    connected = false;
                  });
                  await pushon();
                  if (connected) {
                    setState(() {
                      push = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      pushoff();
                      setState(() {
                        push = false;
                      });
                    });
                  }
                },
                style: NeumorphicStyle(
                  shape: !push ? NeumorphicShape.flat : NeumorphicShape.concave,
                  boxShape: const NeumorphicBoxShape.circle(),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    "Fire",
                    style: TextStyle(
                      fontSize: 20,
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
