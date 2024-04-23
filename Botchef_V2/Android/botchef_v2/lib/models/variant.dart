// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class VariantModel {
  static const RID = "rid";
  static const VID = "vid";
  static const DESCRIPTION = "description";
  static const SPICY = "spicy";
  static const PORTION_SIZE = "portionSize";
  static const MACROS = "macros";
  static const SOLIDMiCROS = "solidMicros";
  static const LIQUIDMiCROS = "liquidMicros";
  static const OPERATIONS = "operations";

  String? _rid;
  String? _vid;
  String? _description;
  String? _spicy;
  String? _portionSize;
  List? _macros;
  List? _liquidMicros;
  List? _solidMicros;
  List? _operations;

  //  getters
  String? get rid => _rid;
  String? get vid => _vid;
  String? get description => _description;
  String? get spicy => _spicy;
  String? get portionSize => _portionSize;
  List? get macros => _macros;
  List? get liquidMicros => _liquidMicros;
  List? get solidMicros => _solidMicros;
  List? get operations => _operations;

  // public variables
  VariantModel.fromSnapshot(DocumentSnapshot snapshot) {
    _vid = snapshot.id;
    _rid = snapshot[RID];
    _description = snapshot[DESCRIPTION];
    _spicy = snapshot[SPICY];
    _portionSize = snapshot[PORTION_SIZE];
    _macros = snapshot[MACROS];
    _liquidMicros = snapshot[LIQUIDMiCROS];
    _solidMicros = snapshot[SOLIDMiCROS];
    _operations = snapshot[OPERATIONS];
  }
}
