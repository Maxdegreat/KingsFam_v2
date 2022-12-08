import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/prayer_modal.dart';

class PrayerRepo {
  final FirebaseFirestore _firebaseFirestore;

  PrayerRepo({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  var fireb = FirebaseFirestore.instance.collection(Paths.prayer);
  void createPrayerShare({
    required String prayer,
    required String userId,
  }) {
    // upload prayer to the cloud
    fireb.add({
      "prayer": prayer,
      "userId": userId,
      "timestamp": Timestamp.now(),
    });
  }

  Future<List<PrayerModal>> getUsrsPrayers(
      {required String usrId, String? lastStringId, required int limit}) async {
    if (lastStringId == null) {
      try {
        List<PrayerModal> plist = [];
        log("in get prayers repo. usrId: $usrId");
        // get first limit prayers
        var snap =
            await fireb.where("userId", isEqualTo: usrId).limit(limit).get();
        log("UPDATE NEEDED IN THE PRAYER REPO...");
        for (var x in snap.docs) {
          plist.add(PrayerModal.fromDoc(x));
        }

        log(plist.length.toString() + "!!!!!!!!!!!!!!");
        return plist;
      } catch (e) {
        log("!!!!!!!!!!!!!!!!!!ERROR IN PRAYER REPO!!!!!!!!!!!!!!!!!!!");
        log(e.toString());
      }
      return [];
    } else {
      try {
        var lastDoc = await fireb.doc(lastStringId).get();
        List<PrayerModal> plist = [];
        var snap = await fireb
            .where("userId", isEqualTo: usrId)
            .startAfterDocument(lastDoc)
            .orderBy("timestamp", descending: true)
            .limit(limit)
            .get();
        for (var x in snap.docs) {
          plist.add(PrayerModal.fromDoc(x));
          return plist;
        }
      } catch (e) {
        log("!!!!!!!!!!!!!!!!!!ERROR IN PRAYER REPO!!!!!!!!!!!!!!!!!!!");
        log(e.toString());
      }
      return [];
    }
  }
}
