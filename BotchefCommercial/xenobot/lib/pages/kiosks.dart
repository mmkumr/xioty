import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xenobot/models/kiosk.dart';
import 'package:xenobot/pages/coupons.dart';
import 'package:xenobot/pages/history.dart';
import 'package:xenobot/pages/ingredients_level.dart';
import 'package:xenobot/pages/ingredients_price.dart';
import 'package:xenobot/pages/kiosk.dart';
import 'package:xenobot/pages/users.dart';

import '../commons.dart';

class KiosksPage extends StatefulWidget {
  const KiosksPage({super.key});

  @override
  State<KiosksPage> createState() => _KiosksPageState();
}

class _KiosksPageState extends State<KiosksPage> {
  int noOfKiosks = 0;
  @override
  void didChangeDependencies() {
    countKiosks();
    super.didChangeDependencies();
  }

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
          IconButton(
            onPressed: () {
              navigate(
                  type: PageType.push,
                  context: context,
                  page: const IngredientsPricePage());
            },
            color: elementsC,
            icon: const Icon(FontAwesomeIcons.indianRupeeSign),
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
                  debugPrint((noOfKiosks + 1).toString());
                  navigate(
                      type: PageType.replace,
                      context: context,
                      page: NewKioskPage(
                        id: (noOfKiosks + 1).toString(),
                      ));
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
                  FirestorePagination(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    query: FirebaseFirestore.instance
                        .collection("kiosks")
                        .orderBy("created_on", descending: true),
                    itemBuilder: (context, documentSnapshot, index) {
                      KioskModel kiosk =
                          KioskModel.fromSnapshot(documentSnapshot);
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
                                    page: NewKioskPage(
                                      id: kiosk.id,
                                      kiosk: kiosk,
                                    ));
                              },
                              tileColor: Colors.black12,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              leading: Text(
                                "Kiosk ID: ${kiosk.id}",
                                softWrap: true,
                              ),
                              title: Text(
                                "${kiosk.name},\n${kiosk.address}",
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
                                                '{"Kiosk ID": "${kiosk.id}", "Name": "${kiosk.name}", "Address": "${kiosk.address}"}',
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
                              subtitle:
                                  Text((kiosk.createdOn.toDate()).toString()),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      navigate(
                                          type: PageType.push,
                                          context: context,
                                          page: HistoryPage(
                                            admin: true,
                                            kioskId: kiosk.id,
                                          ));
                                    },
                                    color: elementsC,
                                    child: const Text("History"),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      navigate(
                                          type: PageType.push,
                                          context: context,
                                          page: IngredientsLevelPage(
                                            kiosk: kiosk,
                                          ));
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

  countKiosks() async {
    AggregateQuerySnapshot query =
        await FirebaseFirestore.instance.collection('kiosks').count().get();
    setState(() {
      noOfKiosks = query.count!;
    });
  }
}
