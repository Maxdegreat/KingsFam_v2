import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

import 'base_noty_repository.dart';

class NotificationRepository extends BaseNotificationRepository {


  @override
  Stream<List<NotificationKF?>> getUserNotifications({required String userId}) {
    return FirebaseFirestore.instance
        .collection(Paths.noty)
        .doc(userId)
        .collection(Paths.notifications)
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => NotificationKF.fromDoc(doc)).toList());
  }
}
