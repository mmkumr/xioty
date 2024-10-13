import 'package:flutter/material.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryC),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
