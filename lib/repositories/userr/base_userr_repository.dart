import 'package:kingsfam/models/models.dart';

abstract class BaseUserrRepository {
  Future<Userr> getUserrWithId({required String userrId});
  
  Future<void> updateUserr({required Userr userr});
  
  Future<List<Userr>> searchUsers({required String query});
  
  Future<List<Userr>> searchUsersadvanced({required String query});
  
  void followerUserr({required String userrId, required String followersId});//followUserrId
  
  void unFollowUserr({required String userrId, required String unFollowedUserr});
  
  Future<bool> isFollowing({required String userrId, required String otherUserId});
  //send friend request
  Future<void> snedFriendRequest({required String senderId, required String currUserId});

  //accept friend request
  Future<void> acceptFriendRequest({required String senderId, currUserId});

  //unadd freind
  Future<void> unaddFriend({required String friendId, required String currUserId});

  Future<List<Userr>> listOfUsersCurrFollwoing({required String uid});
  
  Future<List<String>> listOfIdsCurrFollowing({required String uid});
}
