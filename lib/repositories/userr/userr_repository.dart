//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/user_model.dart';

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
    final doc =
        await _firebaseFirestore.collection(Paths.users).doc(userrId).get();
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
  void followerUserr({required String userrId, required String followersId}) {
    // This function handels both cases for both followed and following
    // ex: currID follows GabbyCallwood. 
    // Followers -> GabbysID -> userFollowers -> docs (containing the currID)
    // Following -> currID -> userFollowing -> docs (containing GabbysID)

    //add follow user to the current user's userr following
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userrId)
        .collection(Paths.userrFollowing)
        .doc(followersId)
        .set({});

    // populate the guy who got followed
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(followersId)
        .collection(Paths.userFollowers)
        .doc(userrId)
        .set({});

    //handel notifications for a new follower
    final NotificationKF noty = NotificationKF(
      notificationType:  Notification_type.new_follower,
      fromUser: Userr.empty.copyWith(id: userrId),
      fromCommuinity: null,
      fromDirectMessage: null,
      date:Timestamp.now(),
    );

    _firebaseFirestore
    .collection(Paths.noty)
    .doc(followersId)
    .collection(Paths.notifications)
    .add(noty.toDoc());
  }

  @override
  void unFollowUserr(
      {required String userrId, required String unFollowedUserr}) {
    //reomove the dude that unfollowed from charli's following when charli is the user
    _firebaseFirestore
        .collection(Paths.following)
        .doc(userrId)
        .collection(Paths.userrFollowing)
        .doc(unFollowedUserr)
        .delete();
    //remove charli while charli is the curr user from the dudes followers
    _firebaseFirestore
        .collection(Paths.followers)
        .doc(unFollowedUserr)
        .collection(Paths.userFollowers)
        .doc(userrId)
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
        .where('usernameSearchCase', arrayContains: query)
        .get();
    return usersnap.docs.map((e) => Userr.fromDoc(e)).toList();
  }
  
  @override
  Future<void> snedFriendRequest({required String senderId, required String currUserId}) async {
    // final senderUser = await UserrRepository().getUserrWithId(userrId: senderId);
    // final noty = Notification(
    //     fromUser: senderUser,
    //     type: Notification_type.friend_request,
    //     date: DateTime.now());
    // FirebaseFirestore.instance
    //     .collection(Paths.notifications)
    //     .doc(currUserId)
    //     .collection(Paths.userNotifications)
    //     .add(noty.toDoc());
    // //write into friend collection : friend -> reciever.id -> friends -> sender.id
    // //if the sender is in the recievers collection they are not friends however if both have each other added then they are friends!
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


  // This is a method to add find new users. so it will be very basic because well for now this is a start up. what we want to do is make a 
  // query for the first (change to last maybe later) users in the user collection. b4 we grab the first (changing) 5 users check is this user
  // alredy being followed by our curr userr?? if so do not add them to the query list. on refresh grab the next 5 users
  Future<List<Userr>> grabUserExploreListFirst10(Userr owner, int limit, String currId) async {
    List<Userr> bucket = [];
    List<String> returningIds = [];
    List<int> idxToRemove = [];
    var fire = FirebaseFirestore.instance;
    int EdgeCaseLimit = 0;
    // go into the user collection and grab the first 5 id's

    // remove our self from the list
    // this will be done at the end of bloc

    // get snapshot of first x users where x = limit 
    var qSnaps = await fire.collection(Paths.users).limit(limit).get();

    // populate returning ids list
    qSnaps.docs.forEach((doc) => returningIds.add(doc.id));

    // in the case there are less than 5 users we need to handel that so we will update the limit via this edge case
      // if (limit > returningIds.length) {

      //   limit = returningIds.length;
      // }
 
    // check the followers collection to of the 5 id's if contains the ownerId inc the add counter per contain and remove the id
    var userHasFollowers = owner.followers > 0 ? true : false;
    if (userHasFollowers) {
      for (int i = 0; i < (limit - 1); i++) {
        var containingIdDoc = await fire
        .collection(Paths.followers)
        .doc(returningIds[i])
        .collection(Paths.userFollowers)
        .doc(owner.id)
        .get();
        if (containingIdDoc.exists) {
            // remove the user from the returningIds
            idxToRemove.add(i);
        }
      }

     for (int idx in idxToRemove) {
      returningIds.remove(returningIds[idx]);

     }
    }



    // go back and grab inc amount of new id's, repet till we have 5

    // turn to actual users then return the list

    for (String userId in returningIds) {
      if (userId == currId) continue;
      Userr addUserToBucket = await UserrRepository().getUserrWithId(userrId: userId);
      bucket.add(addUserToBucket);
    }
    // remove our self from the list
    // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    return bucket;
  }



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
