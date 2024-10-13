import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:xenobot/commons.dart';
import 'package:xenobot/pages/rating.dart';

import '../partials/appbar.dart';
import '../partials/menu.dart';

class OrderPreparingPage extends StatefulWidget {
  const OrderPreparingPage({super.key});

  @override
  State<OrderPreparingPage> createState() => _OrderPreparingPageState();
}

class _OrderPreparingPageState extends State<OrderPreparingPage> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 5), () {
      navigate(type: PageType.replace, context: context, page: const Rating());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar,
      drawer: menu(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 100,
                backgroundImage: CachedNetworkImageProvider(
                    "https://c8.alamy.com/comp/2F1KG86/cup-of-healthy-garlic-tea-on-white-background-2F1KG86.jpg"),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 50.0),
              child: Text(
                "Irani Tea",
                softWrap: true,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Please wait your order \n is being prepared",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: LoadingAnimationWidget.inkDrop(
                color: Colors.blue,
                size: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
