import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/base_kingscord_repository.dart';

class KingsCordRepository extends BaseKingsCordRepository {
  //class data
  final FirebaseFirestore _firebaseFirestore;
  //class constructor
  KingsCordRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  //methods

  //create a KingsCord
  @override
  Future<void> createKingsCord(
      {required Church church, required KingsCord kingsCord}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(church.id)
        .collection(Paths.kingsCord)
        .add(kingsCord.toDoc());
  }

  Future<void> postSays(
      {required Says says, required Church cm, required String kcId}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(cm.id)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection(Paths.says)
        .add(says.toDoc());
  }

  Future<KingsCord?> getKcFirstCm(String cmId) async {
    var qs = await _firebaseFirestore
        .collection(Paths.church)
        .doc(cmId)
        .collection(Paths.kingsCord)
        .limit(1)
        .get();
    return await KingsCord.fromDoc(qs.docs.first);
  }

  Future<KingsCord?> getKcWithId(String kcId, String cmId) async {
    // go to path
    // get the kc w/ id
    DocumentSnapshot snap = await _firebaseFirestore
        .collection(Paths.church)
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .get();
    return await KingsCord.fromDoc(snap);
  }

  //sneding a message
  @override
  Future<void> sendMsgTxt(
      {required String churchId,
      required String kingsCordId,
      required Message message,
      required String senderId,
      String? saysId}) async {
    if (saysId != null) {
      _firebaseFirestore
          .collection(Paths.church)
          .doc(churchId)
          .collection(Paths.kingsCord)
          .doc(kingsCordId)
          .collection(Paths.says)
          .doc(saysId)
          .collection(Paths.messages)
          .add(message.ToDoc(senderId: senderId));
    } else {
      _firebaseFirestore
          .collection(Paths.church)
          .doc(churchId)
          .collection(Paths.kingsCord)
          .doc(kingsCordId)
          .collection(Paths.messages)
          .add(message.ToDoc(senderId: senderId));
    }
  }

  Future<void> onSendGiphyMessage(
      {required String giphyId,
      required String cmId,
      required String kcId,
      required Message msg,
      required String senderId,
      String? saysId}) async {
    try {
      log("starting");
      if (saysId == null) {
        _firebaseFirestore
          .collection(Paths.church)
          .doc(cmId)
          .collection(Paths.kingsCord)
          .doc(kcId)
          .collection(Paths.messages)
          .add(msg.ToDoc(senderId: senderId))
          .then((value) => log(value.toString()));
      } else {
        _firebaseFirestore
          .collection(Paths.church)
          .doc(cmId)
          .collection(Paths.kingsCord)
          .doc(kcId)
          .collection(Paths.says)
          .doc(saysId)
          .collection(Paths.messages)
          .add(msg.ToDoc(senderId: senderId))
          .then((value) => log(value.toString()));
      }
      log("done");
    } catch (e) {
      log("error in kingsCordRepo");
      log("error message: " + e.toString());
    }
  }

  Future<Map<String, List<KingsCord?>>> futureWaitCord(
    List<Future<KingsCord?>> futures,
    String cmId,
    String uid,
  ) async {
    List<KingsCord> kc_ = [];

    try {
      for (Future<KingsCord?> future in futures) {
        DateTime? tFromMsg;
        DateTime? localT;
        bool? readStatus;
        Message? recentM;
        Says? recentS;

        await future.then((kc) async {
          if (kc != null) {
            // log(kc.metaData!.toString());
            // if (kc.metaData == null)
            //   kc = kc.copyWith(metaData: {"inCall": 0});
            // else if (kc.metaData!["inCall"] != null)
            //   kc;
            // else
            //   kc = kc.copyWith(metaData: {"inCall": 0 });

            // vcL.add(kc);

            QuerySnapshot msgQs = await FirebaseFirestore.instance
                .collection(Paths.church)
                .doc(cmId)
                .collection(Paths.kingsCord)
                .doc(kc.id!)
                .collection(Paths.messages)
                .orderBy('date', descending: true)
                .limit(1)
                .get();

            if (msgQs.docs.isNotEmpty) {
              Message m = await Message.fromDoc(msgQs.docs[0], cmId, kc.id!);
              recentM = m;

              List<String>? savedKcTimeStmap =
                  await UserPreferences.getKcTimeStamps(cmId);
              DocumentReference userRef =
                  FirebaseFirestore.instance.collection(Paths.users).doc(uid);
              if (savedKcTimeStmap != null && m.sender != userRef) {
                tFromMsg = DateTime.fromMicrosecondsSinceEpoch(
                    m.date.microsecondsSinceEpoch);
                for (int i = 0; i < savedKcTimeStmap.length; i++) {
                  if (savedKcTimeStmap[i].substring(0, 20) == kc.id!) {
                    localT =
                        DateTime.tryParse(savedKcTimeStmap[i].substring(21));
                    if (localT != null) {
                      readStatus = !localT!.isBefore(tFromMsg!) ? false : true;
                    }
                  }
                }
              } else
                readStatus = false;
            } else {
              // if empty it could be a says
              QuerySnapshot qs = await FirebaseFirestore.instance
                  .collection(Paths.church)
                  .doc(cmId)
                  .collection(Paths.kingsCord)
                  .doc(kc.id!)
                  .collection(Paths.says)
                  .orderBy('date', descending: true)
                  .limit(1)
                  .get();
              if (qs.docs.isNotEmpty) {
                Says s = await Says.fromDoc(qs.docs.first);
                recentS = s;
              }
            }

            // var docRef = await FirebaseFirestore.instance
            //     .collection(Paths.mention)
            //     .doc(uid)
            //     .collection(cmId)
            //     .doc(kc.id);

            if (kc.metaData != null) {
              kc_.add(kc.copyWith(
                  readStatus: readStatus,
                  recentActivity: {"chat": recentM, "says": recentS}));
            }
          }
        });
        ;
      }
    } catch (e) {
      log("error in kc repo futureWaitCord: $e");
    }

    Map<String, List<KingsCord>> map = {};
    map["kc"] = kc_;
    return map;
  }
}
