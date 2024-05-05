import 'package:algolia/algolia.dart';
import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/db/recipe.dart';
import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/partials/appbar.dart';
import 'package:botchef_v2/partials/menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'recipe_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Algolia setup
  final Algolia _algoliaApp = const Algolia.init(
    applicationId: 'KWPCAWUHDW', //ApplicationID
    apiKey:
        '47c5b7823bb65ab1d4c7d8a4d4440776', //search-only api key in flutter code
  );
  String searchTerm = '';
  int pageSize = 20;
  int resultSize = 0;
  Future<List<AlgoliaObjectSnapshot>> operation(
      String input, String type, int page) async {
    AlgoliaQuery query = _algoliaApp.instance.index("xara").query(input);
    query = query.facetFilter('type:$type').setPage(page);
    AlgoliaQuerySnapshot querySnap = await query.getObjects();
    List<AlgoliaObjectSnapshot> results = querySnap.hits;
    maxPages = querySnap.nbPages;
    resultSize = querySnap.hits.length;
    return results;
  }

  //End of Algolia setup
  TextEditingController searchbox = TextEditingController();
  GlobalKey<FormState> form = GlobalKey<FormState>();
  ScrollController controller = ScrollController();
  List<String> categories = [
    "Rice",
    "One Pot Meal",
    "Curry",
    "Stir fry",
  ];
  int catindex = 0;
  int algoliaPage = 0;
  int maxPages = 0;
  Stream<List<AlgoliaObjectSnapshot>>? algolist;
  String? category;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    algolist = Stream.fromFuture(operation(searchTerm, "Rice", algoliaPage));
    category = categories[catindex];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      appBar: appbar,
      drawer: menu(context),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Find food for your mood",
                style: TextStyle(
                  fontSize: width(context) * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (catindex > 0) {
                      setState(() {
                        catindex--;
                      });
                    } else {
                      setState(() {
                        catindex = categories.length - 1;
                      });
                    }
                    setState(() {
                      category = categories[catindex];
                    });
                  },
                  child: const Icon(
                    Icons.arrow_left,
                    size: 50,
                  ),
                ),
                Container(
                  width: width(context) * 0.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryC,
                    border: Border.all(),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      category!,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (catindex < categories.length - 1) {
                      setState(() {
                        catindex++;
                      });
                    } else {
                      setState(() {
                        catindex = 0;
                      });
                    }
                    setState(() {
                      category = categories[catindex];
                    });
                  },
                  child: const Icon(
                    Icons.arrow_right,
                    size: 50,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 10, bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: primaryC,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: TextField(
                    controller: searchbox,
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
                    decoration: const InputDecoration(
                      focusedBorder: InputBorder.none,
                      hintText: "Search by Macro, Chef name, Recipe name",
                      hintMaxLines: 2,
                      icon: Icon(FontAwesomeIcons.magnifyingGlass),
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            if (context.mounted)
              Flexible(
                child: StreamBuilder<List<AlgoliaObjectSnapshot>>(
                  stream: Stream.fromFuture(
                    operation(searchTerm, category!, algoliaPage),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Loading.....",
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    } else if (snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.data!.isEmpty) {
                      return const Text("No data found!");
                    } else {
                      List<AlgoliaObjectSnapshot> currSearchStuff =
                          snapshot.data!;
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Fetching data",
                              textAlign: TextAlign.center,
                            ),
                          );
                        default:
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return CustomScrollView(
                              controller: controller,
                              shrinkWrap: true,
                              slivers: <Widget>[
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (index < resultSize) {
                                        return searchResults(
                                          image: currSearchStuff[index]
                                              .data["photo"],
                                          name: currSearchStuff[index]
                                              .data["recipeName"],
                                          objectID: currSearchStuff[index]
                                              .data["objectID"],
                                          chefName: currSearchStuff[index]
                                              .data["chefName"],
                                          index: index,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget searchResults({
    final String? name,
    final String? image,
    final String? chefName,
    final String? objectID,
    final int? index,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        width: width(context) * 0.5,
        decoration: BoxDecoration(
          color: primaryC,
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        child: Column(
          children: [
            if (algoliaPage != 0 && index == 0)
              TextButton(
                onPressed: () {
                  setState(() {
                    algoliaPage--;
                  });
                },
                child: const Text(
                  "Load Previous results",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ListTile(
              onTap: () async {
                RecipeModel recipe = await RecipeServices().getById(objectID!);
                if (!mounted) return;
                navigate(
                    type: PageType.push,
                    context: context,
                    page: RecipeInfoPage(recipe: recipe));
              },
              titleAlignment: ListTileTitleAlignment.center,
              contentPadding: const EdgeInsets.all(0),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(image!),
              ),
              title: Text(
                name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                "Chef Name: ${chefName!}",
                textAlign: TextAlign.center,
              ),
            ),
            if (index == pageSize - 1 && algoliaPage < maxPages - 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    algoliaPage++;
                  });
                },
                child: const Text(
                  "Load more",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
