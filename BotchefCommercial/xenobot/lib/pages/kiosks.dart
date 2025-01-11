import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xenobot/pages/coupons.dart';
import 'package:xenobot/pages/ingredients_level.dart';
import 'package:xenobot/pages/kiosk.dart';
import 'package:xenobot/pages/users.dart';

import '../commons.dart';

class KiosksPage extends StatefulWidget {
  const KiosksPage({super.key});

  @override
  State<KiosksPage> createState() => _KiosksPageState();
}

class _KiosksPageState extends State<KiosksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiosks"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              onPressed: () {
                navigate(
                    type: PageType.push,
                    context: context,
                    page: const UsersPage());
              },
              color: elementsC,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Text("Users"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                navigate(
                    type: PageType.push,
                    context: context,
                    page: const CouponsPage());
              },
              color: elementsC,
              icon: const Icon(FontAwesomeIcons.tag),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: MaterialButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: elementsC,
                onPressed: () {
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: const NewKioskPage());
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Add Kiosk",
                    style: TextStyle(
                      fontSize: 20,
                      color: elementsC.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                navigate(
                                    type: PageType.replace,
                                    context: context,
                                    page: const NewKioskPage());
                              },
                              tileColor: Colors.black12,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              leading: Text(
                                "Kiosk ID: ${index + 1}",
                                softWrap: true,
                              ),
                              title: const Text(
                                "Mukesh Kumar, Baad Baazar, Berhampur, Odisha",
                                softWrap: true,
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        content: SizedBox(
                                          width: width(context) * 0.7,
                                          child: QrImageView(
                                            data:
                                                '{"Kiosk ID": "${index + 1}", "Name": "Mukesh Kumar", "Address": "Baada Baazar, Berhampur, Odisha"}',
                                            version: QrVersions.auto,
                                            embeddedImage: Image.asset(
                                              "assets/imgs/logo.png",
                                            ).image,
                                            size: width(context) * 0.7,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.qr_code)),
                              subtitle: const Text("22/12/2022 24:30"),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      navigate(
                                          type: PageType.push,
                                          context: context,
                                          page: const IngredientsLevelPage());
                                    },
                                    color: elementsC,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                      ),
                                    ),
                                    child: const Text("Ingredients Level"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
