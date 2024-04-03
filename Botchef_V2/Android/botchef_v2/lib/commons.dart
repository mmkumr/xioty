import 'package:flutter/material.dart';

Color elementsC = Colors.black;
Color primaryC = Colors.black12;
Color bgC = Colors.white;

enum Type { push, replace }

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
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
