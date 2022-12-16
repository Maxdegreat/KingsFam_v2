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


  Future<bool> onLikeSays({required String uid, required String cmId, required String kcId, required String sayId, required int currLikes}) async {
    
    try {
      // should never read this as a batch or limit this. I should only query this.
    DocumentSnapshot snap = await
    _firebaseFirestore.collection(Paths.church).doc(cmId).collection(Paths.kingsCord).doc(kcId).collection(Paths.says).doc(sayId).collection(Paths.likes).doc(uid).get();
    log("passed first test");
    DocumentReference sayRef = _firebaseFirestore.collection(Paths.church).doc(cmId).collection(Paths.kingsCord).doc(kcId).collection(Paths.says).doc(sayId);
    log("passed second test");
    // this is a collection of docs that are used as an id if user has liked the says.
    DocumentReference likesRef = _firebaseFirestore.collection(Paths.church).doc(cmId).collection(Paths.kingsCord).doc(kcId).collection(Paths.says).doc(sayId).collection(Paths.likes).doc(uid);
    log("log third test");


    if (snap.exists) {
      // we unlike
      if (currLikes == 0) return false;
      log("we are del the like atm");
      sayRef.set({'likes' : currLikes - 1 }, SetOptions(merge: true));
      likesRef.delete();
      return false;
    } else {
      // we add a like
      log("we are seting the like");
      sayRef.set({'likes' : currLikes + 1}, SetOptions(merge: true)).then((value) { 
         _firebaseFirestore.collection(Paths.church).doc(cmId).collection(Paths.kingsCord).doc(kcId).collection(Paths.says).doc(sayId).collection(Paths.likes).doc(uid).set({});
      });
      return true;
    }
    } catch (e) {
      log("error in says repository method: onLikeSays");
      log("error meessage is: " + e.toString()); 
      return false;
    }
  }

  Future<Set<String>> getLikedSaysIds({required List<Says?> says, required String cmId, required String kcId, required String uid}) async {
    Set<String> likedSaysIds = {};
    for (Says? s in says) {
        // check if the like exsist
        if (s != null && s.id != null) {
          DocumentSnapshot snap = await FirebaseFirestore.instance
              .collection(Paths.church)
              .doc(cmId)
              .collection(Paths.kingsCord)
              .doc(kcId)
              .collection(Paths.says)
              .doc(s.id)
              .collection(Paths.likes)
              .doc(uid)
              .get();
          if (snap.exists) {
            likedSaysIds.add(s.id!);
          }
        }
      }
      return likedSaysIds;
  }
}
