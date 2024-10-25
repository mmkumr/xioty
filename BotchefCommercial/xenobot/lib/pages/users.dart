import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:xenobot/pages/ingredients_level.dart';

import '../commons.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        centerTitle: true,
        backgroundColor: bgC,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {},
                              tileColor: Colors.black12,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              leading: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      "https://lh3.googleusercontent.com/a/ACg8ocJ4IhUP1z32yYbb2A2CL3WW_kkISolKvWSge0E4RiVQ3Db-6c4u=s288-c-no"),
                                ),
                              ),
                              title: const Text(
                                "mmkumr.ping@gmail.com",
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              subtitle: const Text(
                                "22/12/2022 24:30",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (index % 2 == 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        navigate(
                                            type: PageType.push,
                                            context: context,
                                            page: const IngredientsLevelPage());
                                      },
                                      color: elementsC,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        ),
                                      ),
                                      child:
                                          const Text("Assign Chef Permissions"),
                                    ),
                                  ),
                                ],
                              ),
                            if (index % 2 != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        navigate(
                                            type: PageType.push,
                                            context: context,
                                            page: const IngredientsLevelPage());
                                      },
                                      color: elementsC,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(40),
                                          bottomRight: Radius.circular(40),
                                        ),
                                      ),
                                      child:
                                          const Text("Remove Chef Permissions"),
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
}
