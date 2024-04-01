import 'package:flutter/material.dart';

Color elementsC = Colors.black;
Color primaryC = const Color(0xffa6a6a6);
Color bgC = Colors.white;

double size(String type, BuildContext context) {
  if (type == "h") {
    return MediaQuery.of(context).size.height;
  } else {
    return MediaQuery.of(context).size.width;
  }
}

void navigate(String type, BuildContext context, StatefulWidget page) {
  if (type == "r") {
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
