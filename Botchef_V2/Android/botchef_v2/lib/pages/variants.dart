import 'package:flutter/material.dart';

class VariantsPage extends StatefulWidget {
  const VariantsPage({super.key});

  @override
  State<VariantsPage> createState() => _VariantsPageState();
}

class _VariantsPageState extends State<VariantsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            GridTile(
              footer: Container(
                color: Colors.white,
                child: const Text("Chicken Pakoda"),
              ),
              child: Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtVS-yJjgRy8IKB6HIs497p-IYFXQweSa7ww&usqp=CAU",
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
