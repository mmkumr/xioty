import 'package:flutter/material.dart';

import '../commons.dart';
import '../partials/appbar.dart';

class MiMaDescription extends StatefulWidget {
  const MiMaDescription({super.key});

  @override
  State<MiMaDescription> createState() => _MiMaDescriptionState();
}

class _MiMaDescriptionState extends State<MiMaDescription> {
  TextEditingController description = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgC,
      appBar: appbar,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "Description",
                style: TextStyle(fontSize: 39),
              ),
            ),
          ),
          Center(
            child: Container(
              height: height(context) * 0.75,
              width: width(context) * 0.8,
              decoration: BoxDecoration(
                color: primaryC,
                border: Border.all(),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Form(
                key: form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        maxLines: 5,
                        controller: description,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Field can't be empty";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Details",
                          label: const Text("Details"),
                          fillColor: primaryC,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Icon(
                        Icons.image,
                        size: height(context) * 0.3,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: MaterialButton(
                        elevation: 10,
                        minWidth: 250,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        color: elementsC,
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Text(
                            "Next",
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
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
