import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/base_church_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';

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
    
    // this was members { "currId":userRef } or top level was a list
    // .where('members.$currId.userReference', isEqualTo: userRef)
    
    log("we are now in the getCmsStream");
    List<Future<Church?>> bucket = [];
    return FirebaseFirestore.instance
        .collection(Paths.users)
        .doc(currId)
        .collection(Paths.church)
        .limit(15)
        .snapshots()
        .map((snap) {
          
          for (var j in snap.docs) {
            Future<Church> ch = Church.fromId(j.id);
            bucket.add(ch);
          }
      return bucket;
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

  Future<bool> isBaned({
    required String usrId,
    required String cmId,
  }) async {
    DocumentSnapshot docSnap = await fire
        .collection(Paths.communityBan)
        .doc(cmId)
        .collection(Paths.bans)
        .doc(usrId)
        .get();
    return docSnap.exists;
  }

  Future<List<Userr>> getBanedUsers(
      {required String cmId, required String? lastDocId}) async {
    List<Userr> bucket = [];

    if (lastDocId == null) {
      final usrSnaps = await fire
          .collection(Paths.communityBan)
          .doc(cmId)
          .collection(Paths.bans)
          .limit(10)
          .get();

      for (var x in usrSnaps.docs) {
        if (x.exists) {
          Userr u = await UserrRepository().getUserrWithId(userrId: x.id);
          bucket.add(u);
        }
      }
      log("The len of the bucket is " + bucket.length.toString());
      return bucket;
    } else {
      DocumentSnapshot docSnap =
          await fire.collection(Paths.users).doc(lastDocId).get();

      final usrSnaps = await fire
          .collection(Paths.communityBan)
          .doc(cmId)
          .collection(Paths.bans)
          .limit(20)
          .startAfterDocument(docSnap)
          .get();

      for (var x in usrSnaps.docs) {
        if (x.exists) {
          Userr? u = Userr.fromDoc(x);
          bucket.add(u);
        }
      }
      return bucket;
    }
  }

  void unBan({required String cmId, required String usrId}) {
    fire
        .collection(Paths.communityBan)
        .doc(cmId)
        .collection(Paths.bans)
        .doc(usrId)
        .delete();
  }

  Future<List<Church>> getCommuinitysUserIn(
      {required String userrId,
      required int limit,
      String? lastStringId}) async {
    try {
      if (lastStringId == null) {
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
      } else {
        // get the last doc
        var lastDocSnap = await FirebaseFirestore.instance
            .collection(Paths.church)
            .doc(lastStringId)
            .get();
        List<Church> bucket = [];
        DocumentReference userRef =
            FirebaseFirestore.instance.collection(Paths.users).doc(userrId);
        var querys = await fb
            .where('members.$userrId.userReference', isEqualTo: userRef)
            .startAfterDocument(lastDocSnap)
            .limit(limit)
            .get(); //'members.$currId.userReference', isEqualTo: userRef
        for (var snap in querys.docs) {
          var ch = await Church.fromDoc(snap);
          bucket.add(ch);
        }

        return bucket;
      }
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

  // not everyone will have a role if you think about it.
  // if roleName is nullable then we assume that the role is non existant. just a member
  Future<void> createRole({required String cmId, required String roleName, required List<String> permissions,  required String userId, bool? isNewCm}) async {
    await fire.collection(Paths.communityMembers).doc(cmId).collection(Paths.communityRoles).add({
      "roleName" : roleName,
      "permissions" : permissions,
    }).then((role)  async {
      if (isNewCm!=null && isNewCm) {
        // we only need the rid aka roleId
        await addCommunityMember(userId: userId, cmId: cmId, roleId: role.id);
      }
    });
  }

  Future<void> addCommunityMember({required String userId, required String cmId, required String? roleId}) async {
    DocumentSnapshot userSnap = await fire.collection(Paths.users).doc(userId).get();
    Userr user = Userr.fromDoc(userSnap);
    log("we have created the user from data in the db: ${user.username}");
    // this is the assignment of the role. not a creation of the role.
    // this also holds the users name so that a query for mentions can be done.
    fire.collection(Paths.communityMembers).doc(cmId).collection(Paths.members).doc(userId).set({
      "roleId" : roleId,
      "userNameCaseList" :  user.usernameSearchCase
    });

    // I also need to add the cmId somewhere so that I can find all cm's the user is a part of
    FirebaseFirestore.instance.collection(Paths.users).doc(userId).collection(Paths.church).doc(cmId).set({});

  }

  Future<void> newChurch({required Church church, required Userr recentSender, required String userId}) async {
    try {
      fb.add(church.toDoc()).then((value) async {
        final doc = await value.get();
        // make a separate collection to hold members and roles. The top level collection
        // will also hold doc id which will map to a role. a role is a list of permissions
        createRole(cmId: doc.id, roleName: "Owner", permissions: ["*"], userId: userId, isNewCm: true); //isNewCm is not required. only called on creation
        final kingsCord = KingsCord(
            tag: doc.id,
            cordName: "Welcome To ${church.name}!", 
            subscribedIds: [],
            // recentSender: [recentSender.id, recentSender.username],
          );

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
        .orderBy("date", descending: true)
        .where('commuinity', isEqualTo: cmDocRef)
        .limit(2)
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

  Future<KingsCord?> newKingsCord2({
    required Church ch,
    required String cordName,
    Userr? currUser,
    required String mode,
    required String? rolesAllowed,
  }) async {
    try {
      log("making kc");
      KingsCord kc = KingsCord(
          tag: ch.id!,
          cordName: cordName,
          mode: mode,
          rolesAllowed: rolesAllowed, 
          subscribedIds: [],
          );
      log("sending to db");
      await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(ch.id)
          .collection(Paths.kingsCord)
          .add(kc.toDoc());
      log("done");
      
    } catch (e) {
      log("error: " + e.toString());
    }
    return null;
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

  Future<bool> isInCm(String currId, String userId) async {
    
    // .where('members.$currId.userReference', isEqualTo: userRef)
    
    final cmSnap = await FirebaseFirestore.instance
        .collection(Paths.users).doc(userId).collection(Paths.church).limit(1).get();
    
    if (cmSnap.docs.isNotEmpty) {
      if (cmSnap.docs.first.exists) {
        return true;
      }
    }
    return false;
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

  Future<List<Church>> grabChurchs({required int limit, lastPostId}) async {
    final QuerySnapshot<Map<String, dynamic>> churches;
    if (lastPostId == null) {
      churches = await FirebaseFirestore.instance
          .collection(Paths.church)
          .limit(limit)
          .get();
      List<Church> bucket = [];
      for (var x in churches.docs) {
        var ch = await Church.fromDoc(x);
        bucket.add(ch);
      }
      return bucket;
    } else if (lastPostId != null) {
      final lastDocSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(lastPostId)
          .get();

      churches = await FirebaseFirestore.instance
          .collection(Paths.church)
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
    return [];
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
          .orderBy("location")
          .where('location', isNotEqualTo: location)
          .startAfterDocument(lastDocSnap)
          .limit(limit)
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

  Future<void> banFromCommunity({
    required Church community,
    required String baningUserId,
  }) async {
    leaveCommuinity(commuinity: community, leavingUserId: baningUserId);
    log("left the cm");
    fire
        .collection(Paths.communityBan)
        .doc(community.id!)
        .collection(Paths.bans)
        .doc(baningUserId)
        .set({});
    log("baned the user");
  }

  Future<void> leaveCommuinity(
      {required Church commuinity, required String leavingUserId}) async {

        // to leave we must remove from the users church path

        // we must also remove from cmMembers path. thats it

        fire.collection(Paths.users).doc(leavingUserId).collection(Paths.church).doc(commuinity.id).delete();

        fire.collection(Paths.communityMembers).doc(commuinity.id).collection(Paths.members).doc(leavingUserId).delete();

        // we should also inc the size of the cm Id
        final docRef = fb.doc(commuinity.id);
        docRef.update({'size': commuinity.members.length - 1});
  }

  void inviteUserToCommuinity({required Userr fromUser,required String toUserId,required Church commuinity}) {
    //make a noty
    final NotificationKF noty = NotificationKF(
        fromUser: fromUser,
        notificationType: Notification_type.invite_to_commuinity,
        date: Timestamp.now(),
        fromCommuinity: commuinity);

    fire.collection(Paths.noty).doc(toUserId).collection(Paths.notifications).add(noty.toDoc());
  }

  Future<void> onJoinCommuinity({required Userr user, required Church commuinity}) async {

    // run a transaction

    // check if member in both user -> id -> church lst of documents and communityMembers -> cmId -> members -> lst of members if so do nothing

    // if not a member add to the path above and to the cmMembers path.
    // to do this just call addCmMember function and provide the availavble information

    fire.runTransaction((transaction) async {

      DocumentReference isInUserPathChurchRef = FirebaseFirestore.instance.collection(Paths.users).doc(user.id).collection(Paths.church).doc(commuinity.id);
      DocumentSnapshot isInUserPathChurchSnap = await transaction.get(isInUserPathChurchRef);

      DocumentReference isInCmMembersRef = fire.collection(Paths.communityMembers).doc(commuinity.id).collection(Paths.members).doc(user.id);
      DocumentSnapshot isInCmMemberSnap = await transaction.get(isInCmMembersRef);

      if (isInUserPathChurchSnap.exists) {
        throw Exception("church is in path users -> uid -> church -> id. does exist! id found. in church repo onJoinCommuinity");
      }

      if (isInCmMemberSnap.exists) {
        throw Exception("User is found in the CmMembers path. so how can they try joining? In Church repo onJoinCommunity");
      }

      addCommunityMember(cmId: commuinity.id!, roleId: "0", userId: user.id);

      final docRef = fb.doc(commuinity.id); 
      docRef.update({'size': commuinity.members.length + 1});
    });


  
  }

  Future<Stream<bool>> streamIsCmMember({required Church cm, required String authorId}) async {
    
    // I can look in users personal church path and see if the cm doc id is belonging.
    // I can return this value as true or false ig
    DocumentReference isInCm = FirebaseFirestore.instance.collection(Paths.users).doc(authorId).collection(Paths.church).doc(cm.id);
    DocumentSnapshot isInCmSnap = await isInCm.get();

    return Stream<bool>.value(isInCmSnap.exists);
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
    Map<String, dynamic> memsMap = {};
    var memListFromCm = cm.members.keys.toList();

    for (int i = 0; i < cm.members.keys.length; i++) {
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
