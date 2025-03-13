import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/pages/my_recipes.dart';
import 'package:xenobot/pages/contact_us.dart';
import 'package:xenobot/pages/history.dart';
import 'package:xenobot/pages/home.dart';
import 'package:xenobot/pages/login.dart';
import 'package:xenobot/pages/payment_options.dart';
import 'package:xenobot/pages/refer.dart';

import '../providers/user_provider.dart';

Widget menu(BuildContext context) {
  final user = Provider.of<UserProvider>(context);
  return Drawer(
    child: ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: primaryC),
          accountName: const Text(
            "Mukesh Kumar",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          accountEmail: const Text(
            "mmkumr.ping@gmail.com",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          currentAccountPicture: const CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              "https://lh3.googleusercontent.com/a/ACg8ocJ4IhUP1z32yYbb2A2CL3WW_kkISolKvWSge0E4RiVQ3Db-6c4u=s288-c-no",
            ),
          ),
        ),
        ListTile(
          leading: const Icon(FontAwesomeIcons.house),
          title: const Text('Home'),
          onTap: () {
            navigate(
                type: PageType.push, context: context, page: const HomePage());
          },
        ),
        ListTile(
          leading: const Icon(FontAwesomeIcons.moneyCheck),
          title: const Text('Payment Options'),
          onTap: () {
            navigate(
                type: PageType.push,
                context: context,
                page: const PaymentOptionsPage());
          },
        ),
        ListTile(
          leading: const Icon(FontAwesomeIcons.indianRupeeSign),
          title: const Text('Refer and Earn'),
          onTap: () {
            navigate(
                type: PageType.push, context: context, page: const ReferPage());
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          onTap: () {
            navigate(
                type: PageType.push,
                context: context,
                page: const HistoryPage(
                  admin: false,
                ));
          },
        ),
        ListTile(
          title: const Text('Your Recipes'),
          onTap: () {
            navigate(
                type: PageType.push, context: context, page: const MyRecipes());
          },
          leading: const Icon(FontAwesomeIcons.utensils),
        ),
        ListTile(
          title: const Text('Contact Us'),
          onTap: () {
            navigate(
                type: PageType.push,
                context: context,
                page: const ContactUsPage());
          },
          leading: const Icon(FontAwesomeIcons.headset),
        ),
        ListTile(
          title: const Text('Log Out'),
          onTap: () {
            user.signOut();
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => const LoginPage(),
              ),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          },
          leading: const Icon(FontAwesomeIcons.rightFromBracket),
        ),
      ],
    ),
  );
}
