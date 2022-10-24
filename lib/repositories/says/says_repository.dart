import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/says_model.dart';

class SaysRepository {
  FirebaseFirestore _firebaseFirestore;
  SaysRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<List<Says?>> fetchSays(
      {required String cmId,
      required String kcId,
      required String? lastPostId,
      int? limit}) async {
    try {
      QuerySnapshot saySnap;
      if (limit == null) limit = 7;
      if (lastPostId == null) {
        saySnap = await _firebaseFirestore
            .collection(Paths.church)
            .doc(cmId)
            .collection(Paths.kingsCord)
            .doc(kcId)
            .collection(Paths.says)
            .limit(limit)
            .orderBy('date', descending: true)
            .get();
            
        final says =
            Future.wait(saySnap.docs.map((doc) => Says.fromDoc(doc)).toList());
        return says;
      }
    } catch (e) {
      log("!!!!!!!!error when fetching says in the says repo: " + e.toString());
    }
    return [];
  }

  Future<void> createSays(
      {required String cmId, required String kcId, required Says says}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection(Paths.says)
        .add(says.toDoc());
  }
}
