import 'package:botchef_v2/firebase_options.dart';
import 'package:botchef_v2/pages/machine_connect.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/splash_screen.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
// NEW: activate App Check right here
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
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

class ScreensController extends StatefulWidget {
  const ScreensController({super.key});

  @override
  State<ScreensController> createState() => _ScreensControllerState();
}

class _ScreensControllerState extends State<ScreensController> {
  StatefulWidget? page;

  @override
  void didChangeDependencies() {
    final user = Provider.of<UserProvider>(context);
    // userModel is only populated once Firebase's auth state listener has
    // resolved and UserProvider has flipped to Status.authenticated. Reading
    // it any earlier (e.g. while still uninitialized/authenticating) throws
    // a LateInitializationError, so only resolve `page` once we know it's
    // safe to read.
    if (user.status == Status.authenticated) {
      _resolvePage(user);
    }
    super.didChangeDependencies();
  }

  Future<void> _resolvePage(UserProvider user) async {
    final machineId = user.userModel.machineId;
    StatefulWidget resolved;
    if (machineId == null || machineId.isEmpty) {
      resolved = const MachineConnectPage();
    } else {
      resolved = await firstTime();
    }
    if (!mounted) return;
    setState(() {
      page = resolved;
    });
  }

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
        // `page` is resolved asynchronously in _resolvePage(), so there's a
        // brief window where status is already authenticated but page
        // hasn't been set yet. Show a loader instead of force-unwrapping
        // page! and crashing.
        return page ??
            Scaffold(
              body: Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.blue,
                  size: 200,
                ),
              ),
            );
    }
  }

  Future<StatefulWidget> firstTime() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool first = preferences.getBool('first_time') ?? true;
    debugPrint(first.toString());
    if (first) {
      preferences.setBool('first_time', false);
      return const MachineConnectPage();
    } else {
      return const HomePage();
    }
  }
}
