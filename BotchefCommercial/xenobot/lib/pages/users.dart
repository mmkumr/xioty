import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:xenobot/db/users.dart';
import 'package:xenobot/models/user.dart';

import '../commons.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserModel> users = [];
  String updated = "";
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
                  FirestorePagination(
                    key: Key(updated),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    query: FirebaseFirestore.instance
                        .collection("users")
                        .orderBy("created_on", descending: true),
                    itemBuilder: (context, documentSnapshot, index) {
                      UserModel user = UserModel.fromSnapshot(documentSnapshot);
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 20.0, right: 20.0),
                        child: Column(
                          children: [
                            ListTile(
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
                                child: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      user.profileUrl),
                                ),
                              ),
                              title: Text(
                                user.email,
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                              subtitle: Text(
                                user.createdOn.toDate().toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (user.type == UserType.normal)
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () async {
                                        await UserServices().updateType(
                                            id: user.id,
                                            type: UserType.chef,
                                            context: context);
                                        setState(() {
                                          updated = Random().toString();
                                        });
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
                            if (user.type == UserType.chef)
                              Row(
                                children: [
                                  Expanded(
                                    child: MaterialButton(
                                      onPressed: () {
                                        UserServices().updateType(
                                            id: user.id,
                                            type: UserType.normal,
                                            context: context);
                                        setState(() {
                                          updated = Random().toString();
                                        });
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

  getUsers() async {
    users = await UserServices().getAll();
  }
}
