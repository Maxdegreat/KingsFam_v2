import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/base_church_repository.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class ChurchRepository extends BaseChurchRepository {
  final fb = FirebaseFirestore.instance.collection(Paths.church);
  final fire = FirebaseFirestore.instance;

  Stream<List<Future<Message?>>> getMsgStream(
      {required String cmId, required String kcId, required int limit}) {
    return fb
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection(Paths.messages)
        .limit(limit)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      List<Future<Message?>> bucket = [];
      snap.docs.forEach((doc) {
        Future<Message?> msg = Message.fromDoc(doc);
        bucket.add(msg);
      });
      return bucket;
    });
  }

  Stream<List<Future<Church?>>> getCmsStream({required String currId}) {
    log("we are now in the getCmsStream");
    final userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(currId);
    return FirebaseFirestore.instance
        .collection(Paths.church)
        .limit(10)
        .where('members.$currId.userReference', isEqualTo: userRef)
        .snapshots()
        .map((snap) {
      log("in the snnap map");
      List<Future<Church?>> chs = [];
      snap.docs.forEach((doc) async {
        log("got a doc");
        Future<Church> ch = Church.fromDoc(doc);
        chs.add(ch);
      });
      return chs;
    });
  }

  // Stream<List<Church?>> getCmsStream(StreamingSharedPreferences preferences) {
  //   log("we are now in the getCmsStream shared prefs");
  //   var p = preferences.getCustomValue<List<Church>>(Paths.church, defaultValue: [], adapter: JsonAdapter(
  //   deserializer: (value) {
  //     log("in the get custom val");
  //     Iterable itr = value as Iterable<dynamic>;
  //     log("the len of stream is: ${itr.length}");
  //     return List<Church>.from(itr.map((model)=> Church.fromJson(model)));
  //   }));
  //   log("p: ${p}");
  //   return p;
  // }

  Future<List<Church>> getCommuinitysUserIn(
      {required String userrId, required int limit}) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      List<Church> bucket = [];
      DocumentReference userRef =
          FirebaseFirestore.instance.collection(Paths.users).doc(userrId);
      var querys = await fb
          .where('members.$userrId.userReference', isEqualTo: userRef)
          .limit(limit)
          .get(); //'members.$currId.userReference', isEqualTo: userRef
      for (var snap in querys.docs) {
        var ch = await Church.fromDoc(snap);
        bucket.add(ch);
      }

      return bucket;
    } catch (err) {
      log(err.toString());
    }
    return [];
  }

  delCord({required KingsCord cord, required Church cmmuinity}) {
    fb.doc(cmmuinity.id).collection(Paths.kingsCord).doc(cord.id).delete();
    var messagesToBeDeleated = fb
        .doc(cmmuinity.id)
        .collection(Paths.kingsCord)
        .doc(cord.id)
        .collection(Paths.messages);
    WriteBatch batch = FirebaseFirestore.instance.batch();
    var messages = messagesToBeDeleated.get().then((value) {
      value.docs.forEach((doc) {
        messagesToBeDeleated.doc(doc.id).delete();
        //batch.delete(messagesToBeDeleated.doc(doc.id));
      });
    });

    //batch.commit();
  }

  @override
  Future<void> newChurch(
      {required Church church,
      required Userr recentSender,
      required Map<String, String> roles}) async {
    try {
      fb
          .add(church.toDoc(
        roles: roles,
      ))
          .then((value) async {
        final doc = await value.get();
        final kingsCord = KingsCord(
            tag: doc.id,
            cordName: "Welcome To ${church.name}!",
            recentMessage: "whats good Gods People!",
            recentSender: [recentSender.id, recentSender.username],
            recentTimestamp: Timestamp.now());

        //send off the repo
        fb.doc(doc.id).collection(Paths.kingsCord).add(kingsCord.toDoc());
      });
    } catch (e) {
      log("The newchurch in repo failed e code: $e");
    }
  }

  Future<List<Post?>> getCommuinityPosts({required Church cm}) async {
    final cmDocRef =
        FirebaseFirestore.instance.collection(Paths.church).doc(cm.id);

    var posts = await FirebaseFirestore.instance
        .collection(Paths.posts)
        .where('commuinity', isEqualTo: cmDocRef)
        .limit(3)
        .get();

    List<Post?> bucket = [];
    for (var doc in posts.docs) {
      var post = await Post.fromDoc(doc);
      bucket.add(post);
    }

    return bucket;
  }

  Stream<List<Future<KingsCord?>>> getCommuinityCordsStream(
      {required Church commuinity, required int limit}) {
    return FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .collection(Paths.kingsCord)
        .where('tag', isEqualTo: commuinity.id)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => KingsCord.fromDocAsync(doc)).toList());
  }

  Future<List<KingsCord?>> getCommuinityCords(
      {required String churchId}) async {
    var firebaseCommuinites = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(churchId)
        .collection(Paths.kingsCord)
        .where('tag', isEqualTo: churchId)
        .limit(7)
        .get();
    return firebaseCommuinites.docs.map((e) => KingsCord.fromDoc(e)).toList();
  }

  Future<KingsCord?> newKingsCord2(
      {required Church ch, required String cordName, Userr? currUser}) async {
    KingsCord kc = KingsCord(
        tag: ch.id!,
        cordName: cordName,
        recentMessage: "Welcome To $cordName!",
        recentSender: [
          currUser != null ? currUser.id : '',
          currUser != null ? currUser.username.substring(0, 5) : ''
        ],
        recentTimestamp: Timestamp.now());
    var kcPath = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(ch.id)
        .collection(Paths.kingsCord)
        .add(kc.toDoc());
    return kc;
  }

  @override
  Future<void> newKingsCord(
      {required Church church, required KingsCord kingsCord}) async {
    //will then write the KingsCord collection
    FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(church.id)
        .collection(Paths.kingsCord)
        .add(kingsCord.toDoc());
  }

  @override
  Future<List<Church>> searchChurches({required String query}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .where('searchPram', arrayContains: query)
        .get();

    List<Church> bucket = [];
    for (var x in churchSnap.docs) {
      var ch = await Church.fromDoc(x);
      bucket.add(ch);
    }
    return bucket;
    // return churchSnap.docs.map((snap) async =>  Church.fromDoc(snap)).toList();
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<List<Church>> grabChurchWithLocation(
      {required String location, int limit = 3, String? lastPostId}) async {
    final QuerySnapshot<Map<String, dynamic>> churches;
    if (lastPostId == null) {
      churches = await FirebaseFirestore.instance
          .collection(Paths.church)
          .where('location', isEqualTo: location)
          .limit(limit)
          .get();

      List<Church> bucket = [];
      for (var x in churches.docs) {
        var ch = await Church.fromDoc(x);
        bucket.add(ch);
      }
      return bucket;
      // return churches.docs.map((doc) => Church.fromDoc(doc)).toList();
      //return userSnap.docs.map((doc) => Userr.fromDoc(doc)).toList();
    } else {
      // make the doc snap for last post ID
      final lastDocSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(lastPostId)
          .get();
      churches = await FirebaseFirestore.instance
          .collection(Paths.church)
          .where('location', isEqualTo: location)
          .limit(limit)
          .startAfterDocument(lastDocSnap)
          .get();

      List<Church> bucket = [];
      for (var x in churches.docs) {
        var ch = await Church.fromDoc(x);
        bucket.add(ch);
      }
      return bucket;
    }
  }

  @override
  Future<Church> grabChurchWithId({required Church commuinity}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .get();
    var ch = await Church.fromDoc(churchSnap);
    return churchSnap.exists ? ch : Church.empty;
  }

  Future<Church> grabChurchWithIdStr({required String commuinity}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity)
        .get();
    var ch = await Church.fromDoc(churchSnap);
    return churchSnap.exists ? ch : Church.empty;
  }

  @override
  Future<List<Church>> grabChurchWithSpecial({required String special}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .where('hashTags', arrayContains: special)
        .get();
    List<Church> bucket = [];
    for (var doc in churchSnap.docs) {
      var ch = await Church.fromDoc(doc);
      bucket.add(ch);
    }
    return bucket;
    // return churchSnap.docs.map((doc) => Church.fromDoc(doc)).toList();
  }

  Future<List<Church>> grabChurchAllOver(
      {required String location, int limit = 3, String? lastPostId}) async {
    final QuerySnapshot<Map<String, dynamic>> churchSnap;
    if (lastPostId == null) {
      churchSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .where('location', isNotEqualTo: location)
          .limit(limit)
          .get();
      List<Church> bucket = [];
      for (var doc in churchSnap.docs) {
        var ch = await Church.fromDoc(doc);
        bucket.add(ch);
      }
      return bucket;
    } else {
      final DocumentSnapshot lastDocSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(lastPostId)
          .get();

      churchSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .where('location', isNotEqualTo: location)
          .limit(limit)
          .startAfterDocument(lastDocSnap)
          .get();

      List<Church> bucket = [];
      for (var doc in churchSnap.docs) {
        var ch = await Church.fromDoc(doc);
        bucket.add(ch);
      }
      return bucket;
    }
  }

  Future<void> updateCommuinity(
          {required Church commuinity,
          required Map<String, String> roles}) async =>
      FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(commuinity.id)
          .update(commuinity.toDocUpdate(roles: roles));

  Future<void> updateCommuinityMember(
          {required Map memInfo, required String cmId}) async =>
      FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(cmId)
          .update({'members': memInfo});

  Future<void> leaveCommuinity(
      {required Church commuinity, required String leavingUserId}) async {
    final docRef = fb.doc(commuinity.id);
    final docSnap = await docRef.get();
    var cmIds = Church.getCommunityMemberIds(docSnap);
    if (!cmIds.contains(leavingUserId)) return;

    var cmSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .get();
    var memRefs = Church.fromDocMemRefs(cmSnap);
    var memRefsMap = memRefs['memRefs'] as Map<String, dynamic>;
    memRefsMap.remove(leavingUserId);

    // to update the size
    docRef.update({'size': commuinity.members.length - 1});
    docRef.update({'members': memRefsMap});
  }

  void inviteUserToCommuinity(
      {required Userr fromUser,
      required String toUserId,
      required Church commuinity}) {
    //make a noty
    final NotificationKF noty = NotificationKF(
        fromUser: fromUser,
        notificationType: Notification_type.invite_to_commuinity,
        date: Timestamp.now(),
        fromCommuinity: commuinity);

    fire
        .collection(Paths.noty)
        .doc(toUserId)
        .collection(Paths.notifications)
        .add(noty.toDoc());
  }

  void onJoinCommuinity(
      {required Userr user, required Church commuinity}) async {
    final docRef = fb.doc(commuinity.id);
    final docSnap = await docRef.get();
    var cmIds = await Church.getCommunityMemberIds(docSnap);
    if (cmIds.contains(user.id)) return;

    // update the commuinity size
    docRef.update({'size': commuinity.members.length + 1});
    var cmSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .get();
    var memRefs = Church.fromDocMemRefs(cmSnap);
    var memRefsMap = memRefs['memRefs'] as Map<String, dynamic>;
    memRefsMap[user.id] = {
      'role': Roles.Member,
      'timestamp': Timestamp(0, 0),
      'userReference':
          FirebaseFirestore.instance.collection(Paths.users).doc(user.id)
    };
    docRef.update({'members': memRefsMap});
    return;
  }

  Future<Stream<bool>> streamIsCmMember(
      {required Church cm, required String authorId}) async {
    final doc = await fb.doc(cm.id).get();

    Set<String> memIds = Church.getCommunityMemberIds(doc);

    return Stream<bool>.value(memIds.contains(authorId));
  }

  Future<bool> isCommuinityMember(
      {required Church commuinity, required String authorId}) async {
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection(Paths.users).doc(authorId);
    final docRef = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .collection(Paths.churchMemIds)
        .where('members', arrayContains: userRef)
        .get();

    final List<DocumentSnapshot> docs = docRef.docs;
    print("The docs length is of commuinities member of: ${docs.length}");
    return docs.length == 1;
  }

  void updateUserTimestampOnOpenCm(Church cm, String usrId) {
    log("in updateUserTimestampOnOpenCm: usrId = $usrId");
    Map<String, dynamic> memsMap = {};
    var memListFromCm = cm.members.keys.toList();

    for (int i = 0; i < cm.members.keys.length; i++) {
      log("currId in loop = ${memListFromCm[i].id}");
      if (memListFromCm[i].id == usrId) {
        memsMap[memListFromCm[i].id] = {
          'timestamp': Timestamp.now(),
          'role': cm.members[memListFromCm[i]]['role'],
          'userReference': FirebaseFirestore.instance
              .collection(Paths.users)
              .doc(memListFromCm[i].id),
        };
      }
      if (memListFromCm[i].id != usrId) {
        memsMap[memListFromCm[i].id] = {
          'timestamp': cm.members[memListFromCm[i]]['timestamp'],
          'role': cm.members[memListFromCm[i]]['role'],
          'userReference': FirebaseFirestore.instance
              .collection(Paths.users)
              .doc(memListFromCm[i].id),
        };
      }
    }
    fb.doc(cm.id).update({'members': memsMap});
  }

  void onBoostCm({required String cmId}) {
    fb.doc(cmId).set({"boosted": 1}, SetOptions(merge: true));
  }

  void setTheme({required String cmId, required String theme}) {
    fb.doc(cmId).set({"themePack": theme}, SetOptions(merge: true));
  }

  // Future<List<Userr>> searchForUsersInCommuinity(
  //     {required String query, required String doc}) async {
  //   final churchSnap = await FirebaseFirestore.instance
  //       .collection(Paths.church)
  //       .doc(doc)
  //       .get();
  //   //now we have the doc containing all the users we want.
  //   final tempChurch = Church.fromDoc(churchSnap);
  //   final List<Userr> bucket = [];
  //   for (String userrId in tempChurch.memberIds) {
  //     final user = await UserrRepository().getUserrWithId(userrId: userrId);
  //     bucket.add(user);
  //   }
  //   return bucket;
  // }
}
