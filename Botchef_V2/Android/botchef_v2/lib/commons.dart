import 'package:flutter/material.dart';

Color elementsC = Colors.black;
Color primaryC = const Color(0xffa6a6a6);
Color bgC = Colors.white;

enum Type { height, width, push, replace }

double size({required Type type, required BuildContext context}) {
  if (type == Type.height) {
    return MediaQuery.of(context).size.height;
  } else {
    return MediaQuery.of(context).size.width;
  }
}

void navigate(
    {required Type type,
    required BuildContext context,
    required StatefulWidget page}) {
  if (type == Type.replace) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}
