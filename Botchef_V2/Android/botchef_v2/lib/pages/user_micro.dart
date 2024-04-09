import 'package:botchef_v2/pages/cooking.dart';
import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/description_popup.dart';
import '../partials/menu.dart';

class UserMicroPage extends StatefulWidget {
  const UserMicroPage({super.key});

  @override
  State<UserMicroPage> createState() => _UserMicroPageState();
}

class _UserMicroPageState extends State<UserMicroPage> {
  @override
  void initState() {
    quantity = List.generate(12, (index) => TextEditingController(text: "3"));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  ScrollController scrollController = ScrollController();
  bool start = false;
  GlobalKey<FormState> form = GlobalKey<FormState>();
  List<TextEditingController>? quantity;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgC,
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(Icons.save, size: 40),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        reverse: start,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              const Text(
                "Liquid Micros",
                style: TextStyle(fontSize: 30),
              ),
              ListView.builder(
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Container(
                        width: width(context) * 0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryC,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(60),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: Text(
                              "Oil",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 20),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      title: TextFormField(
                        onTap: () {
                          if (!start) {
                            setState(() {
                              start = true;
                            });
                          }
                        },
                        controller: quantity![index],
                        decoration: InputDecoration(
                          hintText: "tsp",
                          label: const Text("tsp"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
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
              const Text(
                "Solid Micros",
                style: TextStyle(fontSize: 30),
              ),
              ListView.builder(
                itemCount: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Container(
                        width: width(context) * 0.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryC,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(60),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: Text(
                              "Salt",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 20),
                              softWrap: true,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      title: TextFormField(
                        onTap: () {
                          if (!start) {
                            setState(() {
                              start = true;
                            });
                          }
                        },
                        controller: quantity![index],
                        decoration: InputDecoration(
                          hintText: "tsp",
                          label: const Text("tsp"),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: primaryC,
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
                        page: const CookingPage());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Let's Cook",
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: menu(context),
    );
  }
}
