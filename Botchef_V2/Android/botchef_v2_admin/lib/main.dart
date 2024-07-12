import 'package:botchef_v2_admin/commons.dart';
import 'package:botchef_v2_admin/firebase_options.dart';
import 'package:botchef_v2_admin/pages/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xara admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryC),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
