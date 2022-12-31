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

  //sneding a message
  @override
  Future<void> sendMsgTxt(
      {required String churchId,
      required String kingsCordId,
      required Message message,
      required String senderId}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(churchId)
        .collection(Paths.kingsCord)
        .doc(kingsCordId)
        .collection(Paths.messages)
        .add(message.ToDoc(senderId: senderId));
  }

  Future<Map<String, List<KingsCord?>>> futureWaitCord(
      List<Future<KingsCord?>> futures, String cmId, String uid) async {
    String mentioned = "mentioned";
    String kingsCord = "kinscord";

    List<KingsCord> mentionedL = [];
    List<KingsCord> kingsCordL = [];

    for (Future<KingsCord?> future in futures) {
      DateTime? tFromMsg;
      DateTime? localT;
      bool? readStatus;
      Message? recentM;
      Says? recentS;

      KingsCord? kc = await future;
      if (kc != null) {
        List<String>? savedKcTimeStmap =
            await UserPreferences.getKcTimeStamps(cmId);
        if (savedKcTimeStmap != null) {
          QuerySnapshot qs = await FirebaseFirestore.instance
              .collection(Paths.church)
              .doc(cmId)
              .collection(Paths.kingsCord)
              .doc(kc.id!)
              .collection(Paths.messages)
              .orderBy('date', descending: true)
              .limit(1)
              .get();
          if (qs.docs.isNotEmpty) {
            Message m = await Message.fromDoc(qs.docs[0]);
            recentM = m;
            DocumentReference userRef =
                FirebaseFirestore.instance.collection(Paths.users).doc(uid);
            // sender is a docRef on the cloud
            // if curr is last to send leave the readStatus as default which is false or null
            if (m.sender != userRef) {
              tFromMsg = DateTime.fromMicrosecondsSinceEpoch(
                  m.date.microsecondsSinceEpoch);
              for (int i = 0; i < savedKcTimeStmap.length; i++) {
                if (savedKcTimeStmap[i].substring(0, 20) == kc.id!) {
                  localT = DateTime.tryParse(savedKcTimeStmap[i].substring(21));
                  if (localT != null) {
                    readStatus = !localT.isBefore(tFromMsg) ? false : true;
                  }
                }
              }
            } else {
              // has not been seen bf so pass null... i think.
              // also null will show the kc as not read via the cm wraper
              readStatus = false;
            }
          } else {
            // if empty it could be a says
            QuerySnapshot qs = await FirebaseFirestore.instance
                .collection(Paths.church)
                .doc(cmId)
                .collection(Paths.kingsCord)
                .doc(kc.id!)
                .collection(Paths.messages)
                .orderBy('date', descending: true)
                .limit(1)
                .get();
            if (qs.docs.isNotEmpty) {
              Says s = await Says.fromDoc(qs.docs.first);
              recentS = s;
              // we do not currently save kc time stamps
            }
          }
        }
        // kingsCordL.add(kc);
        var docRef = await FirebaseFirestore.instance
            .collection(Paths.mention)
            .doc(uid)
            .collection(cmId)
            .doc(kc.id);

        DocumentSnapshot docSnap = await docRef.get();

        if (docSnap.exists) {
          mentionedL.add(kc.copyWith(
              readStatus: readStatus, recentActivity: {"chat": recentM, "says": recentS}));
        } else {
          kingsCordL.add(kc.copyWith(
              readStatus: readStatus, recentActivity: {"chat": recentM, "says": recentS}));
        }
      }
    }

    Map<String, List<KingsCord>> map = {};
    map[mentioned] = mentionedL;
    map[kingsCord] = kingsCordL;
    return map;
  }
}
