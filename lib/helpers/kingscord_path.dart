
// used to see if a user needs to revive a notification in app for rooms.
import 'dart:developer';

class CurrentKingsCordRoomId {
  static String? currentKingsCordRoomId;
  
  // when user joins room pass kcId as var
  // when user leaves room pass null
  static void updateRoomId({required String? roomId}) {
    // call userpref and update the kcId
    
    currentKingsCordRoomId = roomId;
  }
}