import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class GreyScreen extends StatefulWidget {
  const GreyScreen({super.key});

  @override
  State<GreyScreen> createState() => _GreyScreenState();
}

class _GreyScreenState extends State<GreyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
