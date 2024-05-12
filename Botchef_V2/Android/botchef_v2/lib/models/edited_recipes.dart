// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class EditedRecipeModel {
  static const UID = "uid";
  static const VID = "vid";
  static const RID = "rid";
  static const SOLID_MICRO = "solidMicro";
  static const LIQUID_MICRO = "liquidMicro";

  String? _uid;
  String? _vid;
  String? _rid;
  List? _solidMicro;
  List? _liquidMicro;

  //  getters
  String? get uid => _uid;
  String? get vid => _vid;
  String? get rid => _rid;
  List? get solidMicro => _solidMicro;
  List? get liquidMicro => _liquidMicro;

  // public variables
  EditedRecipeModel.fromMap(Map snapshot) {
    _uid = snapshot[UID];
    _vid = snapshot[VID];
    _rid = snapshot[RID];
    _solidMicro = snapshot[SOLID_MICRO];
    _liquidMicro = snapshot[LIQUID_MICRO];
  }
}
