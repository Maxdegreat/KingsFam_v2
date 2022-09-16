import 'package:cloud_firestore/cloud_firestore.dart';

class PrayerRepo {
  final FirebaseFirestore _firebaseFirestore;

  PrayerRepo({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  void createPrayerShare({required String prayer, required String userId, }) {
    // upload prayer to the cloud

    // 
  }
}
