import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

class VcRepository {
  final FirebaseFirestore _firebaseFirestore;

  VcRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Stream<List<Future<Userr>>> participantsListen(
    {required String cmId, required String kcId}
  ) {
    return _firebaseFirestore
    .collection(Paths.church)
    .doc(cmId)
    .collection(Paths.kingsCord)
    .doc(kcId)
    .collection("participants")
    .limit(30)
    .snapshots()
    .map((snap) => snap.docs.map((doc) => UserrRepository().getUserrWithId(userrId: doc.id)).toList());
  }

  Future<List<Userr>> waitForParticipants(List<Future<Userr>> lst) async {
    List<Userr> bucket = [];
        for (Future<Userr> u in lst)  {
          Userr usr =  await u;
          bucket.add(usr);
        }

        return bucket;
  }

  Future<void> userJoinVc(
      {required String cmId,
      required String kcId,
      required Userr userr}) async {
    CollectionReference pathCm = _firebaseFirestore.collection(Paths.church);
    pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection("participants")
        .doc(userr.id)
        .set({});

    DocumentSnapshot docSnap = await pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId).get();

    KingsCord? k = await KingsCord.fromDoc(docSnap);
    int count = 0;
    if (k != null) {
      if (k.metaData == null) count = 1;
      else if (!k.metaData!.containsKey("inCall")) count = 1;
      else count = k.metaData!["inCall"] + 1;
    } else {
      count = 1;
    }
    pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId).update({"metaData" : { "inCall" : count}});
  }

    Future<void> userLeaveVc(
      {required String cmId,
      required String kcId,
      required Userr userr}) async {
    CollectionReference pathCm = _firebaseFirestore.collection(Paths.church);
    pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection("participants")
        .doc(userr.id)
        .delete();

        DocumentSnapshot docSnap = await pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId).get();

    KingsCord? k = await KingsCord.fromDoc(docSnap);
    int count = 0;
    if (k != null) {
      if (k.metaData == null) count = 0;
      else if (!k.metaData!.containsKey("inCall")) count = 0;
      else count = k.metaData!["inCall"] - 1;
    } else {
      count = 0;
    }
    pathCm
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId).update({"metaData" : { "inCall" : count}});
  }

  
}
