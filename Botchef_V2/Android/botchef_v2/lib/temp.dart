import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:botchef_v2/commons.dart';
import 'package:botchef_v2/pages/recipe_info.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchMetadata {
  final int nbHits;

  const SearchMetadata(this.nbHits);

  factory SearchMetadata.fromResponse(SearchResponse response) =>
      SearchMetadata(response.nbHits);
}

class Recipes {
  final String name;
  final String image;
  final String chefName;
  final String objectID;

  Recipes(this.objectID, this.name, this.image, this.chefName);

  static Recipes fromJson(Map<String, dynamic> json) {
    return Recipes(
        json['objectID'], json['recipeName'], json['image'], json['chefName']);
  }
}

class HitsPage {
  const HitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<Recipes> items;
  final int pageKey;
  final int? nextPageKey;

  factory HitsPage.fromResponse(SearchResponse response) {
    final items = response.hits.map(Recipes.fromJson).toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return HitsPage(items, response.page, nextPageKey);
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchTextController = TextEditingController();

  final _productsSearcher = HitsSearcher(
      applicationID: 'KWPCAWUHDW',
      apiKey: 'bf30ae35483ea194e02366cd3bf0737e',
      indexName: 'xara');

  Stream<SearchMetadata> get _searchMetadata =>
      _productsSearcher.responses.map(SearchMetadata.fromResponse);

  final PagingController<int, Recipes> _pagingController =
      PagingController(firstPageKey: 0);

  Stream<HitsPage> get _searchPage =>
      _productsSearcher.responses.map(HitsPage.fromResponse);

  final GlobalKey<ScaffoldState> _mainScaffoldKey = GlobalKey();

  final _filterState = FilterState();

  late final _facetList = _productsSearcher.buildFacetList(
    filterState: _filterState,
    attribute: 'type',
  );

  @override
  void initState() {
    super.initState();
    _searchTextController.addListener(
      () => _productsSearcher.applyState(
        (state) => state.copyWith(
          query: _searchTextController.text,
          page: 0,
        ),
      ),
    );
    _searchPage.listen((page) {
      if (page.pageKey == 0) {
        _pagingController.refresh();
      }
      _pagingController.appendPage(page.items, page.nextPageKey);
    }).onError((error) => _pagingController.error = error);
    _pagingController.addPageRequestListener(
        (pageKey) => _productsSearcher.applyState((state) => state.copyWith(
              page: pageKey,
            )));
    _productsSearcher.connectFilterState(_filterState);
    _filterState.filters.listen((_) => _pagingController.refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainScaffoldKey,
      appBar: AppBar(
        title: const Text('Algolia & Flutter'),
        actions: [
          IconButton(
              onPressed: () => _mainScaffoldKey.currentState?.openEndDrawer(),
              icon: const Icon(Icons.filter_list_sharp))
        ],
      ),
      endDrawer: Drawer(
        child: _filters(context),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchTextController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter a search term',
                    prefixIcon: Icon(Icons.search),
                  ),
                )),
            StreamBuilder<SearchMetadata>(
              stream: _searchMetadata,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${snapshot.data!.nbHits} hits'),
                );
              },
            ),
            Expanded(
              child: _hits(context),
            )
          ],
        ),
      ),
    );
  }

  Widget _hits(BuildContext context) => PagedListView<int, Recipes>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Recipes>(
          noItemsFoundIndicatorBuilder: (_) => const Center(
            child: Text('No results found'),
          ),
          itemBuilder: (_, item, __) => Container(
            color: Colors.white,
            height: 80,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(width: 50, child: Image.network(item.image)),
                const SizedBox(width: 20),
                Expanded(child: Text(item.name))
              ],
            ),
          ),
        ),
      );

  Widget _filters(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Filters'),
        ),
        body: StreamBuilder<List<SelectableItem<Facet>>>(
            stream: _facetList.facets,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final selectableFacets = snapshot.data!;
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: selectableFacets.length,
                  itemBuilder: (_, index) {
                    final selectableFacet = selectableFacets[index];
                    return CheckboxListTile(
                      value: selectableFacet.isSelected,
                      title: Text(
                          "${selectableFacet.item.value} (${selectableFacet.item.count})"),
                      onChanged: (_) {
                        _facetList.toggle(selectableFacet.item.value);
                      },
                    );
                  });
            }),
      );

  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher.dispose();
    _pagingController.dispose();
    _filterState.dispose();
    _facetList.dispose();
    super.dispose();
  }
}

Widget temp = ListView.builder(
  itemCount: 8,
  itemBuilder: (BuildContext context, int index) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(bottom: 10, left: 10, right: 10)
          : const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        width: width(context) * 0.5,
        decoration: BoxDecoration(
          color: primaryC,
          border: Border.all(),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        child: ListTile(
          onTap: () {
            navigate(
                type: Type.push,
                context: context,
                page: const RecipeInfoPage());
          },
          titleAlignment: ListTileTitleAlignment.center,
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
              fit: BoxFit.fill,
            ).image,
          ),
          title: const Text(
            "Chicken Pakoda",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          subtitle: const Text(
            "Cooking Time: 1.5 Hours",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  },
);
