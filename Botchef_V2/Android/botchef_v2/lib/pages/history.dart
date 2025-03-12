import 'package:botchef_v2/db/history.dart';
import 'package:botchef_v2/models/history.dart';
import 'package:botchef_v2/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../commons.dart';
import '../partials/menu.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryModel>? history = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await getHistory();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgC,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("History"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      drawer: menu(context),
      body: ListView.builder(
        itemCount: history!.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: history![index].photoUrl!,
              fit: BoxFit.fill,
            ),
            title: Text(
              history![index].recipeName!,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("Chef name: ${history![index].chefName}"),
            trailing: Text(
              "${history![index].dateTime!.substring(0, 10)}\n${DateTime.now().toString().substring(11, 16)}",
              softWrap: true,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }

  getHistory() async {
    final user = Provider.of<UserProvider>(context);
    history = await HistoryServices().history(user.user.uid);
    history = history!.reversed.toList();
    setState(() {});
  }
}
