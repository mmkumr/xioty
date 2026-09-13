import 'package:flutter/material.dart';

Color elementsC = Colors.black;
Color primaryC = Colors.black12;
Color bgC = Colors.white;
String algoliaAppId = 'JVYQL6PARJ';
String algoliaSearchAPIKey = '46d75cf5091c5a21ffe9522fb3b2fa5f';
String algoliaWriteAPIKey = '0fd92b5d090c00709af250df62d08658';

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
