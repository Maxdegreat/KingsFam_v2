import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/roles/role_types.dart';



// a role id is stored in the db and the role Id leads to a list of permisnsions.
// nd let it relet this take in the role id (rid). aturn a list of permissios.

// the class will then need to have maybe a static method that will take a list
// of permissions and and action. if the permisssion list contains the action
// then allow it to work.

// if there is no rid then just return a "0" this means basic permissions

class CmActions {

  static Future<Map<String, dynamic>> getRidPermissions({required String rid, required String cmId}) async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection(Paths.communityMembers).doc(cmId).collection(Paths.communityRoles).doc(rid).get();
    if (snap.exists && snap.data() != null) {
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      return {
        "permissions" : data["permissions"] ?? ["0"],
        "roleName" : data["roleName"] ?? "Member"
      } ;
    } else {
      return {
        "permissions" : ["0"],
        "roleName" : "Member"
      };
    }

  } 

  bool accessBeenGranted({required List<String> permissions, required String action}) {
    return permissions.contains(action);
  }

  // diff roles can be assigned actions to be written to their permissions
  // roles can also 

  // admin grants all the basic privalaged roles below
  static const String admin = "admin";

  static const String makeCord = "makeCord";
  static const String makeEvent = "makeEvent";
  static const String accessToSettings = "accessToSettings";
  static const String canChangeRoles = "canChangeRoles";
  static const String updatePrivacy = "updatePrivacy";
  static const String kickAndBan = "kickAndBan";

  // roles can also be written as 
  // "roleName" ...
  // "permissions" [...]
  // this allows users to make more flexible roles for ex
  // a cord has access rules. must have permission x to join.
  // we will have to call getRidPermissions in the cm bloc. store perm in state
  // once loaded hop into cord and call accessGranted passing state perm and cord rule
  
  // use case: chior and mucisians in one gc. allows seperation.

  // make a chior role
  // make a mucisian role

  

  // static const communityActions = [
  //   /* 0 */ 'cm/settings/updateName',
  //   /* 1 */ 'cm/settings/updateCommunityBanner',
  //   /* 2 */ 'cm/settings/updateAbout',
  //   /* 3 */ 'cm/settings/manageAndUpdateRoles',
  //   /* 4 */ 'cm/addChatRooms',
  //   /* 5 */ 'cm/addVvr',
  //   /* 6 */ 'cm/kickMembers',
  //   /* 7 */ 'cm/delChatRooms',
  //   /* 8 */ 'cm/leaveCommunity'
  // ];

}
