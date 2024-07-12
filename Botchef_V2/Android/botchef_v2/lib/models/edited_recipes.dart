// ignore_for_file: constant_identifier_names

import 'package:botchef_v2/models/recipe.dart';
import 'package:botchef_v2/models/variant.dart';

class EditedRecipeModel {
  static const UID = "uid";
  static const VMODEL = "vModel";
  static const RMODEL = "rModel";
  static const SOLID_MICRO = "solidMicro";
  static const LIQUID_MICRO = "liquidMicro";

  String? _uid;
  VariantModel? _vModel;
  RecipeModel? _rModel;
  List? _solidMicro;
  List? _liquidMicro;

  //  getters
  String? get uid => _uid;
  VariantModel? get vModel => _vModel;
  RecipeModel? get rModel => _rModel;
  List? get solidMicro => _solidMicro;
  List? get liquidMicro => _liquidMicro;

  // public variables
  EditedRecipeModel.fromMap(Map snapshot) {
    _uid = snapshot[UID];
    _vModel = snapshot[VMODEL];
    _rModel = snapshot[RMODEL];
    _solidMicro = snapshot[SOLID_MICRO];
    _liquidMicro = snapshot[LIQUID_MICRO];
  }
}
