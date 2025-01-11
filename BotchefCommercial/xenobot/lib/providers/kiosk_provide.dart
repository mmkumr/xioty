// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xenobot/db/kiosks.dart';
import 'package:xenobot/models/kiosk.dart';

enum ScannedStatus { scanned, unscanned }

class KioskProvider with ChangeNotifier {
  KioskServices _kioskServices = KioskServices();
  late KioskModel _kioskModel;

  //setters
  ScannedStatus _status = ScannedStatus.unscanned;
  ScannedStatus get status => _status;
  KioskModel get kioskModel => _kioskModel;
  Future<String> getKiosk(String id) async {
    try {
      _kioskModel = await _kioskServices.getById(id);
      _status = ScannedStatus.scanned;
      Fluttertoast.showToast(
          msg: "Happy Ordering", backgroundColor: Colors.green);
      notifyListeners();
      return _kioskModel.name;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Invalid Kiosk Id", backgroundColor: Colors.red);
      _status = ScannedStatus.unscanned;
      notifyListeners();
      return "";
    }
  }
}
