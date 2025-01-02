// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../db/users.dart';
import '../models/user.dart';

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

class UserProvider with ChangeNotifier {
  late FirebaseAuth _auth;
  late User _user;
  late UserServices _userServices = UserServices();
  late UserModel _userModel;

  //setters
  Status _status = Status.uninitialized;
  Status get status => _status;
  User get user => _user;
  UserModel get userModel => _userModel;
  GoogleSignIn googleSignIn = GoogleSignIn();

  UserProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onStateChanged);
  }

  Future<bool> addUser(
      {required String id,
      required String name,
      required String email,
      required String profileUrl}) async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      await _userServices.createUser(
          id: id, name: name, email: email, profileUrl: profileUrl);
      _userModel = await _userServices.getUserById(user.uid);
      _status = Status.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = Status.unauthenticated;
      notifyListeners();
      debugPrint("---error saving data: ${e.toString()}");
      return false;
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      _status = Status.authenticating;
      notifyListeners();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
      try {
        _userModel = await _userServices.getUserById(user.uid);
      } catch (e) {
        _status = Status.authenticating;
        notifyListeners();
        addUser(
            id: user.uid,
            name: user.displayName!,
            email: user.email!,
            profileUrl: user.photoURL!);
        _status = Status.authenticated;
        return "new";
      }
      _status = Status.authenticated;
      notifyListeners();
      return "old";
    } catch (e) {
      debugPrint("Login error:$e");
      _status = Status.unauthenticated;
      notifyListeners();
      if (e.toString().contains("PigeonUserDetails?")) {
        return "old";
      }
      return "Login error:$e";
    }
  }

  signOut() async {
    _auth.signOut();
    _status = Status.unauthenticated;
    notifyListeners();
  }

  Future<void> _onStateChanged(User? user) async {
    if (user == null) {
      _status = Status.unauthenticated;
    } else {
      try {
        _user = user;
        _userModel = await _userServices.getUserById(user.uid);
        _status = Status.authenticated;
        notifyListeners();
      } catch (e) {
        _status = Status.unauthenticated;
        notifyListeners();
        debugPrint("error login  ${e.toString()}");
      }
    }
    notifyListeners();
  }
}
