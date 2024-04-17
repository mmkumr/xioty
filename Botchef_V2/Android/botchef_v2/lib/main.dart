import 'package:botchef_v2/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/splash_screen.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider.initialize(),
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

class ScreensController extends StatelessWidget {
  const ScreensController({super.key});
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
        return const HomePage();
    }
  }
}
