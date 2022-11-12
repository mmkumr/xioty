import 'package:easymed/main.dart';
import 'package:easymed/thankyou.dart';
import 'package:easymed/widget/mydrawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Run extends StatefulWidget {
  final String name;
  final String label;
  final int quantity;
  Run({Key key, this.name, this.label, this.quantity}) : super(key: key);

  @override
  _RunState createState() => _RunState();
}

class _RunState extends State<Run> {
  DatabaseReference _firebase = FirebaseDatabase.instance.reference();
  TextEditingController _count = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Self-Med"),
      ),
      drawer: MyDrawer(),
      body: loading == true
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ListTile(
                        title: Text(
                          widget.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        leading: Column(
                          children: [Text("Label:" + widget.label)],
                        ),
                        trailing: Column(
                          children: [
                            Text("Quantity: " + widget.quantity.toString()),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _count,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Quantity",
                            hintText: "Quantity",
                            icon: Icon(Icons.medical_services),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "This field cannot be empty";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                loading = true;
                              });
                              _firebase.child("/data").update(
                                {
                                  "label": widget.label,
                                  "quantity": int.parse(_count.text)
                                },
                              ).then((value) {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) => ThankYou()),
                                );
                              });
                            }
                          },
                          color: Colors.orangeAccent,
                          height: 50,
                          minWidth: 150,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
