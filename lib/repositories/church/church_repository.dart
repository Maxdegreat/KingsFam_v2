import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/base_church_repository.dart';

class ChurchRepository extends BaseChurchRepository {

  final fb = FirebaseFirestore.instance.collection(Paths.church);
  final fire = FirebaseFirestore.instance;

  @override
  Future<void> newChurch({required Church church, required ChurchMembers churchMemberIds,  required Userr recentSender }) async {
    fb.add(church.toDoc()).then((value) async {
      final doc = await value.get(); 
    fb.doc(doc.id).collection(Paths.churchMemIds).doc(doc.id).set(churchMemberIds.toDoc());
      final kingsCord = KingsCord(
        tag: doc.id,
        cordName: "Welcome Kings Family!",
        // memberInfo: church.memberInfo,
        recentMessage: "whats good Gods People!",
        recentSender: recentSender.username,
        memberIds: church.memberIds
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

  Future<List<KingsCord?>> getCommuinityCords({required String churchId}) async {
    var firebaseCommuinites = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(churchId)
          .collection(Paths.kingsCord)
          .where('tag', isEqualTo: churchId).limit(7).get(); 
    return firebaseCommuinites.docs.map((e) => KingsCord.fromDoc(e)).toList();
  }

  Future<KingsCord?> newKingsCord2({required Church ch, required String cordName}) async{
    KingsCord kc = KingsCord(tag: ch.id!, recentMessage: "ayeee Yoo", recentSender: '', memberIds: ch.memberIds, cordName: cordName);
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

    return churchSnap.docs.map((snap) => Church.fromDoc(snap)).toList();
  }

  @override
  Future<List<Church>> grabChurchWithLocation({required String location}) async {
    final churches = await FirebaseFirestore.instance
        .collection(Paths.church)
        .where('location', isEqualTo: location)
        .get();
    return churches.docs.map((doc) => Church.fromDoc(doc)).toList();
    //return userSnap.docs.map((doc) => Userr.fromDoc(doc)).toList();
  }

  @override
  Future<Church> grabChurchWithId({required Church commuinity}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity.id)
        .get();
    return churchSnap.exists ? Church.fromDoc(churchSnap) : Church.empty;
  }

  Future<Church> grabChurchWithIdStr({required String commuinity}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(commuinity)
        .get();
    return churchSnap.exists ? Church.fromDoc(churchSnap) : Church.empty;
  }

  @override
  Future<List<Church>> grabChurchWithSpecial({required String special}) async {
    final churchSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .where('hashTags', arrayContains: special)
        .get();
    return churchSnap.docs.map((doc) => Church.fromDoc(doc)).toList();
  }

  Future<List<Church>> grabChurchAllOver({required String location}) async  {
    final churchSnap = await FirebaseFirestore.instance.collection(Paths.church).where('location', isNotEqualTo: location).get();
    return churchSnap.docs.map((doc) => Church.fromDoc(doc)).toList();
  }

  Future <void> updateCommuinity({required Church commuinity}) async => FirebaseFirestore.instance.collection(Paths.church).doc(commuinity.id).update(commuinity.toDoc());

  Future<void> leaveCommuinity({required Church commuinity, required String currId}) async {
      final doc = fb.doc(commuinity.id); //FirebaseFirestore.instance.collection(Paths.church).doc(...)
      final joinMembersDoc = doc.collection(Paths.churchMemIds).doc(commuinity.id);

      final kingsCordDocs = await doc.collection(Paths.kingsCord).where('tag', isEqualTo: commuinity.id).get();
      //List<String> idContainer = [];
      for (var kc in kingsCordDocs.docs) {
        //idContainer.add(kc.id);
        doc.collection(Paths.kingsCord).doc(kc.id).update({'memberIds' : FieldValue.arrayRemove([currId]) });
        doc.collection(Paths.kingsCord).doc(kc.id).update({'memberIds' : FieldValue.arrayUnion(['del_$currId']) });
      }
      

      doc.update({'memberIds': FieldValue.arrayRemove([currId])}); // updates main commuinity memids
      doc.update({'memberIds': FieldValue.arrayUnion(['del_$currId'])});
      
      joinMembersDoc.update({'memberIds' : FieldValue.arrayRemove([currId])}); // updates main -> churchmemids memids
      joinMembersDoc.update({'memberIds' : FieldValue.arrayUnion(['del_$currId'])});

      // to update the size
      doc.update({'size' : commuinity.size! - 1});

      
      //commuinity.memberInfo.remove(currId);
      
      //doc.update({'memberInfo': commuinity.memberInfo});
      
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
    final doc = fb.doc(commuinity.id);
    // update the commuinity size
    int size = 0;
    if (commuinity.size != null)
      size = commuinity.size!;
    else 
      size = 0;
    size += 1;

    doc.update({'size': size});
    // create the docs we will be working with
    final joinMembersDoc = doc.collection(Paths.churchMemIds).doc(commuinity.id);
    final kingsCordDocs = await doc.collection(Paths.kingsCord).where('tag', isEqualTo: commuinity.id).get();
    //List<String> idContainer = [];
    for (var kc in kingsCordDocs.docs) {
      //idContainer.add(kc.id);
      doc.collection(Paths.kingsCord).doc(kc.id).update({'memberIds' : FieldValue.arrayUnion([user.id]) });
      doc.collection(Paths.kingsCord).doc(kc.id).update({'memberIds' : FieldValue.arrayRemove(['del_${user.id}']) });
    }
    //update the docs
    doc.update({'memberIds': FieldValue.arrayUnion([user.id])});
    doc.update({'memberIds': FieldValue.arrayRemove(['del_${user.id}'])});
    joinMembersDoc.update({'memberIds' : FieldValue.arrayUnion([user.id])});
    joinMembersDoc.update({'memberInfo' : FieldValue.arrayRemove(['del_${user.id}'])});
    //create a user map for the new memeber info
    Map<String, dynamic> userMap = {
      'isAdmin' : false,
      'username': user.username,
      'pfpImageUrl': user.profileImageUrl,
      'email': user.email,
      'token': user.token,
    };
    print("updating commuinity data");
    // bc when a user leaves i keep his memberinfo to prevent an error so when joining again
    // no use in writing it twice. it will update based on another function found in the commuinity 
    // screen or kingscord screen on join. the update in case anything is diff.
    if (!commuinity.memberInfo.containsKey(user.id)) {
      commuinity.memberInfo[user.id] = userMap; // this is an updated commuinity member map
      doc.update({'memberInfo': commuinity.memberInfo}); // this is the application of the updated map
    }
    
    print("updating commuinity kingscord");
   
    
  }
  
  Future<bool> isCommuinityMember({required Church commuinity, required String authorId}) async {
    final docRef = 
      await
      FirebaseFirestore
     .instance
      .collection(Paths.church)
      .doc(commuinity.id)
      .collection(Paths.churchMemIds)
      .where('memberIds', arrayContains: authorId)
      .get();

    final List<DocumentSnapshot> docs = docRef.docs;
    print("The docs length is ${docs.length}" );
    return docs.length == 1;
      
  }

  Future<void> onLeaveCommuinity({required Church commuinity, required Userr user}) async {
    // remove from commuinity
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
