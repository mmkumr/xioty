import 'package:cloud_firestore/cloud_firestore.dart';

class OtherssServices {
  String collection = 'others';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List> getMicros() {
    return _firestore.collection(collection).get().then((value) {
      return value.docs[0].data()[collection];
    });
  }
}
