// @dart=2.9
// ignore: import_of_legacy_library_into_null_safe
import 'package:easymed/run.dart';
import 'package:easymed/widget/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:algolia/algolia.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  bool loading = false;
  String search = "";
  final _formKey = GlobalKey<FormState>();

  final Algolia _algoliaApp = Algolia.init(
    applicationId: '0W9920TY0I', //ApplicationID
    apiKey:
        'b2f116b752f5480de1af77457694079f', //search-only api key in flutter code
  );

  String _searchTerm = "";

  Future<List<AlgoliaObjectSnapshot>> _operation(String input) async {
    AlgoliaQuery query = _algoliaApp.instance.index("easymed").search(input);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("easymed"),
      ),
      drawer: MyDrawer(),
      body: Center(
        child: loading == true
            ? CircularProgressIndicator()
            : Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: " ",
                        //controller: _name,
                        onChanged: (word) {
                          setState(() {
                            _searchTerm = word;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Medicine name",
                          hintText: "Medicine name",
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
                            return "The name field cannot be empty";
                          }
                          return null;
                        },
                      ),
                    ),

                    // algolia stream

                    StreamBuilder<List<AlgoliaObjectSnapshot>>(
                      stream: Stream.fromFuture(_operation(_searchTerm)),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Start Typing",
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        } else {
                          List<AlgoliaObjectSnapshot> currSearchStuff =
                              snapshot.data;

                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container(
                                  child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "searching.....",
                                  textAlign: TextAlign.center,
                                ),
                              ));
                            default:
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              else
                                return CustomScrollView(
                                  shrinkWrap: true,
                                  slivers: <Widget>[
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          return DisplaySearchResult(
                                            name: currSearchStuff[index]
                                                .data["name"],
                                            label: currSearchStuff[index]
                                                .data["label"],
                                            quantity: currSearchStuff[index]
                                                .data["quantity"],
                                          );
                                        },
                                        childCount: currSearchStuff.length ?? 0,
                                      ),
                                    ),
                                  ],
                                );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DisplaySearchResult extends StatelessWidget {
  final String name;
  final String label;
  final int quantity;

  DisplaySearchResult({
    Key key,
    this.name,
    this.label,
    this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Run(
              name: name,
              label: label,
              quantity: quantity,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "Name: $name" ?? "",
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Label: $label" ?? "",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                    Text(
                      "Quantity: $quantity" ?? "",
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                )
              ],
            ),
            Divider(
              color: Colors.black,
            ),
            SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
