import 'package:flutter/material.dart';

Future<dynamic> descriptionPopup(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Description"),
          content: SizedBox(
            height: 500,
            child: Column(
              children: [
                Image.network(
                  "https://www.freshpoint.com/wp-content/uploads/commodity-red-onion.jpg",
                  height: 200,
                ),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
        );
      });
}
