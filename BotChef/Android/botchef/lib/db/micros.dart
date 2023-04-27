import 'package:cloud_firestore/cloud_firestore.dart';

class MicrosServices {
  String collection = 'micros';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List> getMicros() {
    return _firestore.collection(collection).get().then((value) {
      return value.docs[0].data()[collection];
    });
  }
}
