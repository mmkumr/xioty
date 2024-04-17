import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/contact_us.dart';
import 'package:botchef_v2/pages/edited_recipes.dart';
import 'package:botchef_v2/pages/history.dart';
import 'package:botchef_v2/pages/home.dart';
import 'package:botchef_v2/pages/your_recipes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../pages/favorites.dart';
import '../providers/user_provider.dart';

Widget menu(BuildContext context) {
  final user = Provider.of<UserProvider>(context);
  return Drawer(
    child: ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        UserAccountsDrawerHeader(
          accountName: const Text('Xara Solutions'),
          accountEmail: const Text("rxhundred@gmail.com"),
          currentAccountPicture: CircleAvatar(
            backgroundImage: Image.network(
              "https://pics.craiyon.com/2023-07-15/dc2ec5a571974417a5551420a4fb0587.webp",
            ).image,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          onTap: () {
            navigate(
                type: Type.push, context: context, page: const HistoryPage());
          },
        ),
        ListTile(
          title: const Text('Favorites'),
          onTap: () {
            navigate(
                type: Type.push, context: context, page: const FavoritesPage());
          },
          leading: const Icon(Icons.favorite),
        ),
        ListTile(
          title: const Text('Your recipes'),
          onTap: () {
            navigate(
                type: Type.push,
                context: context,
                page: const YourRecipesPage());
          },
          leading: const Icon(FontAwesomeIcons.utensils),
        ),
        ListTile(
          title: const Text('Edited recipes'),
          onTap: () {
            navigate(
                type: Type.push,
                context: context,
                page: const EditedRecipesPage());
          },
          leading: const Icon(FontAwesomeIcons.spoon),
        ),
        ListTile(
          title: const Text('Home'),
          onTap: () {
            navigate(type: Type.push, context: context, page: const HomePage());
          },
          leading: const Icon(Icons.home),
        ),
        ListTile(
          title: const Text('Contact Us'),
          onTap: () {
            navigate(
                type: Type.push, context: context, page: const ContactUsPage());
          },
          leading: const Icon(Icons.headset_mic),
        ),
        ListTile(
          title: const Text('Log Out'),
          onTap: () {
            user.signOut();
          },
          leading: const Icon(Icons.logout),
        ),
      ],
    ),
  );
}
