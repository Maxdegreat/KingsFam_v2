import 'package:cloud_firestore/cloud_firestore.dart';
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
    FirebaseFirestore.instance.collection(Paths.church).add(church.toDoc()).then((value) async {
      final doc = await value.get(); 
    fire.collection(Paths.church).doc(doc.id).collection(Paths.churchMemIds).doc(doc.id).set(churchMemberIds.toDoc());
      final kingsCord = KingsCord(
        tag: doc.id,
        cordName: null,
        memberInfo: church.memberInfo,
        recentMessage: "whats good Gods People!",
        recentSender: recentSender.username,
        memberIds: church.memberIds
      );
      //send off the repo
    fb.doc(doc.id).collection(Paths.kingsCord).add(kingsCord.toDoc());
    });
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

  Future <void> updateCommuinity({required Church commuinity}) async => FirebaseFirestore.instance.collection(Paths.church).doc(commuinity.id).update(commuinity.toDoc());

  Future<void> leaveCommuinity({required Church commuinity, required String currId}) async {
      final doc = fb.doc(commuinity.id);
      final joinMembersDoc = doc.collection(Paths.churchMemIds).doc(commuinity.id);

      doc.update({'memberIds': FieldValue.arrayRemove([currId])});
      joinMembersDoc.update({'memberIds' : FieldValue.arrayRemove([currId])});

      
      commuinity.memberInfo.remove(currId);
      
      doc.update({'memberInfo': commuinity.memberInfo});
      
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

  void onJoinCommuinity({required Userr user, required Church commuinity}) {
    print("in onJoinCommuinity function in church_repository");
    // create the docs we will be working with
    final doc = fb.doc(commuinity.id);
    final joinMembersDoc = doc.collection(Paths.churchMemIds).doc(commuinity.id);
    
    //update the docs
    doc.update({'memberIds': FieldValue.arrayUnion([user.id])});
    joinMembersDoc.update({'memberIds' : FieldValue.arrayUnion([user.id])});
    //create a user map for the new memeber info
    Map<String, dynamic> userMap = {
      'isAdmin' : false,
      'username': user.username,
      'pfpImageUrl': user.profileImageUrl,
      'email': user.email,
      'token': user.token,
    };
    print("updating commuinity data");
    commuinity.memberInfo[user.id] = userMap; // this is an updated commuinity member map
    doc.update({'memberInfo': commuinity.memberInfo}); // this is the application of the updated map
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
