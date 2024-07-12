// ignore_for_file: constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  static const RID = "rid";
  static const NAME = "name";
  static const COMMENT = "comment";
  static const RATING = "rating";

  String? _rid;
  String? _name;
  String? _comment;
  double? _rating;

  //  getters
  String? get rid => _rid;
  String? get name => _name;
  String? get comment => _comment;
  double? get rating => _rating;

  // public variables
  CommentModel.fromSnapshot(DocumentSnapshot snapshot) {
    _name = snapshot[NAME];
    _rid = snapshot[RID];
    _comment = snapshot[COMMENT];
    _rating = snapshot[RATING].toDouble();
  }
}
