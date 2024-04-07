import 'package:botchef_v2/partials/appbar.dart';
import 'package:botchef_v2/partials/description_popup.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import 'user_micro.dart';

class UserMacroPage extends StatefulWidget {
  const UserMacroPage({super.key});

  @override
  State<UserMacroPage> createState() => _UserMacroPageState();
}

class _UserMacroPageState extends State<UserMacroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      body: Column(
        children: [
          const Text(
            "Macros",
            style: TextStyle(fontSize: 30),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://www.freshpoint.com/wp-content/uploads/commodity-red-onion.jpg"),
                    ),
                    title: Container(
                      decoration: BoxDecoration(
                        color: primaryC,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(60),
                        ),
                      ),
                      child: const Text(
                        "Onions",
                        style: TextStyle(fontSize: 20),
                        softWrap: true,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    trailing: InkWell(
                      onTap: () {
                        descriptionPopup(context);
                      },
                      child: const Icon(Icons.info),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: MaterialButton(
              minWidth: 300,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: elementsC,
              onPressed: () {
                navigate(
                    type: Type.push,
                    context: context,
                    page: const UserMicroPage());
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 30,
                    color: elementsC.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
