import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/base_church_repository.dart';

class   ChurchRepository extends BaseChurchRepository {

  final fb = FirebaseFirestore.instance.collection(Paths.church);
  final fire = FirebaseFirestore.instance;

  Stream<List<Future<Message?>>> getMsgStream({required String cmId, required String kcId, required int limit}) {
    return fb.doc(cmId).collection(Paths.kingsCord).doc(kcId).collection(Paths.messages).limit(limit).orderBy('date', descending: true)
      .snapshots().map((snap) {
         List<Future<Message?>> bucket = [];
         snap.docs.forEach((doc) { 
           Future<Message?> msg = Message.fromDoc(doc);
           bucket.add(msg);
        });
        return bucket;
      });
  }
  
  Stream<List<Future<Church?>>> getCmsStream({required String currId}) {
    final userRef = FirebaseFirestore.instance.collection(Paths.users).doc(currId);
    return FirebaseFirestore.instance.collection(Paths.church).where('members',arrayContains: userRef)
    .snapshots().map((snap) {
      List<Future<Church?>> chs = [];
      snap.docs.forEach((doc) async{ 
        Future<Church> ch = Church.fromDoc(doc);
        chs.add(ch);
      });
      return chs;
    });
  }
  Future<List<Church>> getCommuinitysUserIn({required String userrId, required int limit  }) async {
    try {
    List<Church> bucket = [];
    DocumentReference userRef = FirebaseFirestore.instance.collection(Paths.users).doc(userrId);
    var querys = await fb.where('members', arrayContains: userRef).limit(limit).get();
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
  }

  @override
  Future<void> newChurch({required Church church, required Userr recentSender}) async {
    fb.add(church.toDoc()).then((value) async {
      final doc = await value.get(); 
      final kingsCord = KingsCord(
        tag: doc.id,
        cordName: "Welcome To ${church.name}!",
        recentMessage: "whats good Gods People!",
        recentSender: recentSender.username,
      );
      //send off the repo
    fb.doc(doc.id).collection(Paths.kingsCord).add(kingsCord.toDoc());
    });
  }

  Future<List<Post?>> getCommuinityPosts({required Church cm}) async {
    
    final cmDocRef =  FirebaseFirestore.instance.collection(Paths.church).doc(cm.id);

    
    var posts = await FirebaseFirestore.instance.collection(Paths.posts).where('commuinity', isEqualTo: cmDocRef).limit(3).get();

     List<Post?> bucket = [];
     for (var doc in posts.docs) {
       var post = await Post.fromDoc(doc);
       bucket.add(post);
     } 

    return bucket;
  }

  Stream<List<Future<KingsCord?>>> getCommuinityCordsStream({required String churchId, required int limit}) {
    return FirebaseFirestore.instance.collection(Paths.church).doc(churchId)  
      .collection(Paths.kingsCord).where('tag', isEqualTo: churchId).limit(limit)
      .snapshots().map((snap) => snap.docs.map((doc) => KingsCord.fromDocAsync(doc)).toList());
  }

  Future<List<KingsCord?>> getCommuinityCords({required String churchId}) async {
    var firebaseCommuinites = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(churchId)
          .collection(Paths.kingsCord)
          .where('tag', isEqualTo: churchId).limit(7).get(); 
    return firebaseCommuinites.docs.map((e) => KingsCord.fromDoc(e)).toList();
  }

  Future<KingsCord?> newKingsCord2({required Church ch, required String cordName}) async{
    KingsCord kc = KingsCord(tag: ch.id!, recentMessage: "Welcome To $cordName!", recentSender: '', cordName: cordName);
    var kcPath = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(ch.id)
        .collection(Paths.kingsCord)
        .add(kc.toDoc());
      return kc;
  }

  @override
  Future<void> newKingsCord({required Church church, required KingsCord kingsCord}) async {
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
  Future<List<Church>> grabChurchWithLocation({required String location}) async {
    final churches = await FirebaseFirestore.instance
        .collection(Paths.church)
        .where('location', isEqualTo: location)
        .get();

    List<Church> bucket = [];
    for (var x in churches.docs) {
      var ch = await Church.fromDoc(x);
      bucket.add(ch);
    }
    return bucket;
    // return churches.docs.map((doc) => Church.fromDoc(doc)).toList();
    //return userSnap.docs.map((doc) => Userr.fromDoc(doc)).toList();
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

  Future<List<Church>> grabChurchAllOver({required String location}) async  {
    final churchSnap = await FirebaseFirestore.instance.collection(Paths.church).where('location', isNotEqualTo: location).get();
     List<Church> bucket = [];
    for (var doc in churchSnap.docs) {
      var ch = await Church.fromDoc(doc);
      bucket.add(ch);
    }
    return bucket;
    // return churchSnap.docs.map((doc) => Church.fromDoc(doc)).toList();
  }

  Future <void> updateCommuinity({required Church commuinity}) async => FirebaseFirestore.instance.collection(Paths.church).doc(commuinity.id).update(commuinity.toDoc());

  Future<void> leaveCommuinity({required Church commuinity, required currId}) async {
      var cmIds = commuinity.members.map((usr) => usr.id).toList();
      if (!cmIds.contains(currId)) return;


      final doc = fb.doc(commuinity.id); //FirebaseFirestore.instance.collection(Paths.church).doc(...)
      // to update the size
      doc.update({'size' : commuinity.members.length - 1});
      doc.update({'members': FieldValue.arrayRemove([FirebaseFirestore.instance.collection(Paths.users).doc(currId)])});
    }
    
  void inviteUserToCommuinity({required Userr fromUser, required String toUserId, required Church commuinity}) {
    //make a noty
    final NotificationKF noty = NotificationKF(
      fromUser: fromUser, 
      notificationType: Notification_type.invite_to_commuinity, 
      date: Timestamp.now(),
      fromCommuinity: commuinity
    );

    fire
    .collection(Paths.noty)
    .doc(toUserId)
    .collection(Paths.notifications)
    .add(noty.toDoc());
  }

  void onJoinCommuinity({required Userr user, required Church commuinity}) async  {
    
    var cmIds = commuinity.members.map((usr) => usr.id).toList();
    if (cmIds.contains(user.id)) return;

    final doc = fb.doc(commuinity.id);
    
    // update the commuinity size
    doc.update({'size': commuinity.members.length + 1});
    doc.update({'members': FieldValue.arrayUnion([FirebaseFirestore.instance.collection(Paths.users).doc(user.id)])});
    return;
  }
  Stream<bool> streamIsCmMember({required Church cm, required String authorId}) {
    var ids = cm.members.map((e) => e.id).toSet();
    if (ids.contains(authorId)) {
       return Stream<bool>.value(true);
    } else {
      return Stream<bool>.value(false);
    }
  }
  Future<bool> isCommuinityMember({required Church commuinity, required String authorId}) async {
    final DocumentReference userRef = FirebaseFirestore.instance.collection(Paths.users).doc(authorId);
    final docRef = await
      FirebaseFirestore
     .instance
      .collection(Paths.church)
      .doc(commuinity.id)
      .collection(Paths.churchMemIds)
      .where('members', arrayContains: userRef)
      .get();

    final List<DocumentSnapshot> docs = docRef.docs;
    print("The docs length is of commuinities member of: ${docs.length}" );
    return docs.length == 1;
      
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
