import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/your_recipes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

Widget menu(BuildContext context) {
  return SpeedDial(
    closedForegroundColor: Colors.black,
    openForegroundColor: Colors.white,
    closedBackgroundColor: Colors.white,
    openBackgroundColor: Colors.black,
    labelsBackgroundColor: Colors.white,
    speedDialChildren: <SpeedDialChild>[
      SpeedDialChild(
        child: CircleAvatar(
          backgroundImage: Image.network(
            "https://pics.craiyon.com/2023-07-15/dc2ec5a571974417a5551420a4fb0587.webp",
          ).image,
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightGreen.withOpacity(0),
        label: 'Xara Solutions',
        onPressed: () {},
        closeSpeedDialOnPressed: false,
      ),
      SpeedDialChild(
        child: const Icon(Icons.history),
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        label: 'History',
        onPressed: () {},
        closeSpeedDialOnPressed: false,
      ),
      SpeedDialChild(
        child: const Icon(Icons.favorite),
        foregroundColor: Colors.white,
        backgroundColor: Colors.yellow,
        label: 'Favorites',
        onPressed: () {},
        closeSpeedDialOnPressed: false,
      ),
      SpeedDialChild(
        child: const Icon(FontAwesomeIcons.utensils),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        label: 'Your recipes',
        onPressed: () {
          navigate(
              type: Type.push, context: context, page: const YourRecipesPage());
        },
      ),
      SpeedDialChild(
        child: const Icon(FontAwesomeIcons.spoon),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightGreen,
        label: 'Edited recipes',
        onPressed: () {},
      ),
      SpeedDialChild(
        child: const Icon(Icons.home),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        label: 'Home',
        onPressed: () {},
      ),
      SpeedDialChild(
        child: const Icon(Icons.headset_mic),
        foregroundColor: Colors.white,
        backgroundColor: Colors.lightBlueAccent,
        label: 'Contact Us',
        onPressed: () {},
      ),
      SpeedDialChild(
        child: const Icon(Icons.logout),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        label: 'Log Out',
        onPressed: () {},
      ),
    ],
    child: const Icon(Icons.menu),
  );
}
