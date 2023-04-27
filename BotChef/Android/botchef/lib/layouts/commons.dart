import 'package:flutter_neumorphic/flutter_neumorphic.dart';

Color elementsC = Color(0xff8d99ae);
Color fgC = Color(0xffeeeeee);
Color bgC = Color(0xffedf2f4);

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
