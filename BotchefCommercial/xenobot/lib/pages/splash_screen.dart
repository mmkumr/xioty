import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff010a1c),
      body: Center(
        child: Animate(
          effects: const [
            ScaleEffect(duration: Duration(seconds: 1)),
          ],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset("assets/imgs/logo.png"),
          ),
        ),
      ),
    );
  }
}
