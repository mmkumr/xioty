import 'package:flutter/material.dart';

Color elementsC = Colors.black;
Color primaryC = Colors.black12;
Color bgC = Colors.white;

enum PageType { push, replace }

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

void navigate(
    {required PageType type,
    required BuildContext context,
    required StatefulWidget page}) {
  if (type == PageType.replace) {
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
