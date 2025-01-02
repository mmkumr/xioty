import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/firebase_options.dart';
import 'package:xenobot/pages/login.dart';
import 'package:xenobot/pages/scan_kiosk.dart';
import 'package:xenobot/pages/splash_screen.dart';
import 'package:xenobot/providers/kiosk_provide.dart';

import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
            create: (context) => UserProvider.initialize()),
        ChangeNotifierProvider<KioskProvider>(
            create: (context) => KioskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Scaffold(
              body: Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.blue,
                  size: 200,
                ),
              ),
            );
          };
          return widget!;
        },
        title: "Xara",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ScreensController(),
      ),
    ),
  );
}

class ScreensController extends StatefulWidget {
  const ScreensController({super.key});

  @override
  State<ScreensController> createState() => _ScreensControllerState();
}

class _ScreensControllerState extends State<ScreensController> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    switch (user.status) {
      case Status.uninitialized:
        return const SplashScreen();
      case Status.unauthenticated:
        return const LoginPage();
      case Status.authenticating:
        return Scaffold(
          body: Center(
            child: LoadingAnimationWidget.inkDrop(
              color: Colors.blue,
              size: 200,
            ),
          ),
        );
      case Status.authenticated:
        return const ScanKiosk();
    }
  }
}
