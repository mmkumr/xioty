import 'dart:async';

import 'package:botchef_v2/pages/rating.dart';
import 'package:flutter/material.dart';

import '../commons.dart';

class CookingPage extends StatefulWidget {
  const CookingPage({super.key});

  @override
  State<CookingPage> createState() => _CookingPageState();
}

class _CookingPageState extends State<CookingPage> {
  Duration timeDifference = DateTime.parse("2024-01-01 00:01:00")
      .difference(DateTime.parse("2024-01-01 00:00:00"));
  int time = 0;
  bool start = false, pause = false;
  @override
  void initState() {
    time = timeDifference.inSeconds;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!start) {
      startCountdown();
      start = true;
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Please Wait\nYour food will be ready in:",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 300,
                  width: 300,
                  child: CircularProgressIndicator(
                    strokeWidth: 20,
                    valueColor: const AlwaysStoppedAnimation(Colors.black),
                    backgroundColor: Colors.grey,
                    value: (time / timeDifference.inSeconds) * 1,
                  ),
                ),
                Text(
                    '${(Duration(seconds: time))}'
                        .split('.')[0]
                        .padLeft(8, '0')
                        .toString(),
                    style: const TextStyle(fontSize: 30)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: MaterialButton(
                minWidth: 300,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  if (pause) {
                    startCountdown();
                    setState(() {
                      pause = false;
                    });
                  } else {
                    setState(() {
                      pause = true;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    pause ? "Resume" : "Pause",
                    style: TextStyle(
                      fontSize: 30,
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

  startCountdown() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (Timer timer) {
      if (time <= 0) {
        setState(() {
          timer.cancel();
          navigate(
              type: Type.replace, context: context, page: const RatingPage());
        });
      }
      if (pause) {
        timer.cancel();
      } else {
        setState(() {
          --time;
        });
      }
    });
  }
}
