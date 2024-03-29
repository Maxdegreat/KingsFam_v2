//import 'dart:ffi';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/repositories/userr/base_userr_repository.dart';



// This is a table of contents of the different methods that we have in this repository

// listOfCurrFollowing
// listOfIdsCurrFollowing
// updateUserr
// searchUsers



class UserrRepository extends BaseUserrRepository {
  final FirebaseFirestore _firebaseFirestore;

  UserrRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<Userr> getUserrWithId({required String userrId}) async {
    final doc =await _firebaseFirestore.collection(Paths.users).doc(userrId).get();
    return doc.exists ? Userr.fromDoc(doc) : Userr.empty;
  }

  Future<List<Userr>> listOfUsersCurrFollwoing({required String uid}) async {
    //return a list of document snapshots
    //this will be used to acess each individual
    //user that the curr user is following
    final docs = await _firebaseFirestore
        .collection(Paths.following)
        .doc(uid)
        .collection(Paths.userrFollowing)
        .get();
    return docs.docs.map((data) => Userr.fromDoc(data)).toList();
  }

  Future<List<String>> listOfIdsCurrFollowing({required String uid}) async {
    final docs = await _firebaseFirestore
        .collection(Paths.following)
        .doc(uid)
        .collection(Paths.userrFollowing)
        .get();

    final ids = docs.docs.map((e) => e.id).toList();
    return ids;
  }

  @override
  Future<void> updateUserr({required Userr userr}) async {
    await _firebaseFirestore
        .collection(Paths.users)
        .doc(userr.id)
        .update(userr.toDoc());
  }

  @override
  Future<List<Userr>> searchUsers({required String query}) async {
    final userSnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('username', isGreaterThanOrEqualTo: query)
        .get();
    return userSnap.docs.map((doc) => Userr.fromDoc(doc)).toList();
  }

  @override
  void followerUserr({required Userr userr, required String followersId}) {

    _firebaseFirestore
        .collection(Paths.following)
        .doc(followersId)
        .collection(Paths.userrFollowing)
        .doc(userr.id)
        .set({});

    // populate the guy who got followed
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(userr.id)
        .collection(Paths.userFollowers)
        .doc(followersId)
        .set({});

    // //handel notifications for a new follower
    // final NotificationKF noty = NotificationKF(
    //   msg: userr.username + " started following you",
    //   fromUser: Userr.empty.copyWith(id: userr.id, username: userr.username, profileImageUrl: userr.profileImageUrl ),
    //   fromCm: null,
    //   fromDm: null,
    //   date:Timestamp.now(),
    // );

    // _firebaseFirestore
    // .collection(Paths.noty)
    // .doc(followersId)
    // .collection(Paths.notifications)
    // .add(noty.toDoc());
  }

  @override
  void unFollowUserr(
      {required String userrId, required String unFollowingUser}) {
    //reomove the dude that unfollowed from charli's following when charli is the user
    _firebaseFirestore
        .collection(Paths.following)
        .doc(unFollowingUser)
        .collection(Paths.userrFollowing)
        .doc(userrId)
        .delete();
    //remove charli while charli is the curr user from the dudes followers
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(userrId)
        .collection(Paths.userFollowers)
        .doc(unFollowingUser)
        .delete();
  }

  @override
  Future<bool> isFollowing({required String userrId, required String otherUserId}) async {
    //check esistance of charli in other user following
    final otherUserDoc = await _firebaseFirestore
        .collection(Paths.following)
        .doc(userrId)
        .collection(Paths.userrFollowing)
        .doc(otherUserId)
        .get();
    return otherUserDoc.exists;
  }

  @override
  Future<List<Userr>> searchUsersadvanced({required String query}) async {
    final usersnap = await _firebaseFirestore
        .collection(Paths.users)
        .where('usernameSearchCase', arrayContains: query).limit(20)
        .get();
    return usersnap.docs.map((e) => Userr.fromDoc(e)).toList();
  }
  
  Future<List<Userr>> searchUsersAdvancedFollowing({required String query, required String currUserId}) async {
    List<Userr> bucket = [];
    List<Userr> users = [];
    users = await searchUsersadvanced(query: query);
    for (Userr user in users) {
      var userSnap = await _firebaseFirestore.collection(Paths.following).doc(currUserId).collection(Paths.userrFollowing).doc(user.id).get();
      if (userSnap.exists) {
        bucket.add(user);
      }
    }

    return bucket;

    // final userSnap = await _firebaseFirestore.collection(Paths.following).doc(currUserId).collection(Paths.userrFollowing).limit(20).get();
    // for (var v in  userSnap.docs) {
    //     if (v.exists) {
    //       Userr user = await getUserrWithId(userrId: v.id);
    //       bucket.add(user);
    //     }
    // }

    // return bucket;
    //return userSnap.docs.length > 0 ? userSnap.docs.map((id) => Userr.fromDoc(id)).toList() : [];
  }
    Future<List<Userr>> followingList({required String currUserId, required String? lastStringId}) async {
      List<Userr> bucket = [];
      if (lastStringId == null) {
        final userSnap = await _firebaseFirestore.collection(Paths.following).doc(currUserId).collection(Paths.userrFollowing).limit(15).get();
        for (var v in  userSnap.docs) {
         if (v.exists) {
           Userr user = await getUserrWithId(userrId: v.id);
           bucket.add(user);
         }
        }
      } else {
        var startAfterUserDoc = await _firebaseFirestore.collection(Paths.users).doc(lastStringId).get();
        final userSnap = await _firebaseFirestore.collection(Paths.following).doc(currUserId).collection(Paths.userrFollowing).startAfterDocument(startAfterUserDoc).limit(15).get();
        for (var v in  userSnap.docs) {
         if (v.exists) {
           Userr user = await getUserrWithId(userrId: v.id);
           bucket.add(user);
         }
        }
      }
      return bucket;   
    }
  
  Future<List<Userr>> followerList({required String currUserId, required String? lastStringId}) async {
    List<Userr> bucket = [];
    if (lastStringId == null) {
      final userSnap = await _firebaseFirestore.collection(Paths.followers).doc(currUserId).collection(Paths.userFollowers).limit(15).get();
      for (var v in userSnap.docs) {
        if (v.exists) {
          Userr user = await getUserrWithId(userrId: v.id);
          bucket.add(user);
        }
      }
    } else {
      var startAfterDoc = await _firebaseFirestore.collection(Paths.users).doc(lastStringId).get();
      var userSnap = await _firebaseFirestore.collection(Paths.followers).doc(currUserId).collection(Paths.userFollowers).startAfterDocument(startAfterDoc).limit(15).get();
      for (var v in userSnap.docs) {
        if (v.exists) {
          Userr user = await getUserrWithId(userrId: v.id);
          bucket.add(user);
        }
      }
    }
    return bucket;
  }
  
  @override
  Future<void> snedFriendRequest({required String senderId, required String currUserId}) async {

  }

  Future<bool> updateUserInField(String userId, Map<String, dynamic> fieldMap) async {
    
    // "fieldMap" in atm making this is the kingscord memberInfo map
    Userr user = await UserrRepository().getUserrWithId(userrId: userId); // optimize by using profilestate.user maybe?
    Map<String, dynamic> checkMap = {};
    bool flag = false; // This means it needs to be updated if flag ever becomes true
   
   // if user is alredy in the chat (fieldMap...memberInfo)
   print("user in chat? ${fieldMap.containsKey(userId)}");
   print(fieldMap.keys);
   
    if (fieldMap.containsKey(userId)) {
      // make a new map with updated values 
      Map<String, dynamic> currUserValuesToBeUpdated = {
        'username': user.username,
        'pfpImageUrl': user.profileImageUrl,
        'colorPref' : user.colorPref,
        'email': user.email,
        'token': user.token,
      };
      // set check map at userId euqal to to updated map
      checkMap[userId] = currUserValuesToBeUpdated;
      // check if the values are the same for this key in chat's memberInfo (by reading local state)
      Map<String, dynamic> tempMap = fieldMap[userId]; // the value "userId" itsself is another map
      tempMap.forEach((key, value) {
        // print("when checking difference... ${currUserValuesToBeUpdated[key] !=  value}");
        // print("${currUserValuesToBeUpdated[key]}, $value");
         if (currUserValuesToBeUpdated.containsKey(key) && currUserValuesToBeUpdated[key] != value) {
           
             flag = true; // we need to update

           
         }
      });
       //else update the users field values
       //will do outsid of this function. I am just taking a var of flag if true ill update else null
     } 


    // else add the user
    
      return flag; // flag... NOT FALSE
  }

  Future<List<Userr>> getSearchUsers({ required String currId, required  int limit, required String? lastId}) async{
    List<Userr> bucket = [];
    
    var usersCollections = FirebaseFirestore.instance.collection(Paths.users);
    var fire2 = FirebaseFirestore.instance.collection(Paths.followers);

    QuerySnapshot usersSnap;
    if (lastId == null) {
      print("last post id is null");
      usersSnap = await usersCollections.limit(8).get();
      print(usersSnap.docs.length);
      for (var document in usersSnap.docs) {
        if (document.id == currId) continue;
        //print("777777777777777777777777777777${document.id}77777777777777777777777777777777777777777") ;
        var isFollowing = await fire2.doc(document.id).collection(Paths.userFollowers).doc(currId).get();
        if (!isFollowing.exists ) {
          Userr addUserToBucket = Userr.fromDoc(document);
          bucket.add(addUserToBucket);
        }
      }
      return bucket;

    } else {
      var lastIdDoc = await usersCollections.doc(lastId).get();
      if (!lastIdDoc.exists){ print("last IdDoc N/A "); return [];}
      usersSnap = await usersCollections.startAfterDocument(lastIdDoc).limit(limit).get();
      for (var document in usersSnap.docs) {
        if (document.id == currId) continue;
        // print("(((((((((((((((((((((((((((((((((((((((((((((((((((${document.id}))))))))))))))))))))))))))))))))))))))))))") ; 
        var isFollowing = await fire2.doc(document.id).collection(Paths.userFollowers).doc(currId).get();
        if (!isFollowing.exists) {
          Userr addUserToBucket = Userr.fromDoc(document);
          bucket.add(addUserToBucket);
        }
      }

      // Future.delayed(const Duration(seconds: 3));
      print("The length of this new bucket is ${bucket.length}");
      var cleanBucket = bucket.toSet();
      bucket = cleanBucket.toList();
      return bucket;
    }
  }
/*
  if (lastId == null) {
      print("last post id is null");
      usersSnap = await usersCollections.limit(limit).get();
      print(usersSnap.docs.length);
      usersSnap.docs.forEach((document) async {
        print("777777777777777777777777777777${document.id}77777777777777777777777777777777777777777") ;
        var isFollowing = await fire2.doc(document.id).collection(Paths.userFollowers).doc(currId).get();
        users.add(document.id);
        if (isFollowing.exists) {
          users.remove(document.id);
        }
       });
      
      for (String id in users) {
        Userr addUserToBucket = await UserrRepository().getUserrWithId(userrId: id);
        bucket.add(addUserToBucket);
      }
      print("len of bucket: ${bucket.length}");
       return bucket;
    }
    */



  Future<void> acceptFriendRequest({required String senderId, currUserId}) {
    // TODO: implement acceptFriendRequest
    throw UnimplementedError();
  }

  @override
  Future<void> unaddFriend(
      {required String friendId, required String currUserId}) {
    // TODO: implement unaddFriend
    throw UnimplementedError();
  }
}
