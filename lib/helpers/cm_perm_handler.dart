import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

// roles will be: owner (soon migrate to captin), admin, mod

class CmPermHandler {
  // permission for owners
  static bool isOwner(CommuinityBloc cmBloc) {
    return cmBloc.state.role["permissions"].contains("*");
  }

  // permission for admins
  static bool isAdmin(CommuinityBloc cmBloc) {
    return cmBloc.state.role["permissions"].contains("*") ||
        cmBloc.state.role["permissions"].contains("#");
  }
// -----------------------------------------------
  // permission for creating a room
  static bool canMakeRoom(CommuinityBloc cmBloc) {
    return cmBloc.state.role["permissions"].contains("*") ||
        cmBloc.state.role["permissions"].contains("#") ||
        cmBloc.state.role["permissions"].contains(CmActions.makeRoom);
  }

  // permission for del a room (same as creating room)

  // permission for kicking / baning a user
  static bool canRemoveMember({required CommuinityBloc? cmBloc, required String? givenRole}) {
    if (givenRole != null) {
      return roleNameToPerm[givenRole].contains("*") || roleNameToPerm[givenRole].contains("#") || roleNameToPerm[givenRole].contains("mod");
    } else if (cmBloc != null) {
      var p = cmBloc.state.role["permissions"];
      return p.contains("*") || p.contains("#") || p.contains('mod');
    } else {
      return false;
    }

  }

  // psemission for updating the cm privacy
  static bool canUpdatePrivacy({required CommuinityBloc? cmBloc, required String? givenRole}) {
    if (givenRole != null) {
      return roleNameToPerm[givenRole].contains("*") || roleNameToPerm[givenRole].contains("#") || roleNameToPerm[givenRole].contains("mod");
    } else if (cmBloc != null) {
      var p = cmBloc.state.role["permissions"];
      return p.contains("*") || p.contains("#") || p.contains('mod');
    } else {
      return false;
    }
  }

  // permission for updating roles (can not change the owners role)
  static bool canUpdateRole({required CommuinityBloc? cmBloc, required String? givenRole}) {
    if (givenRole != null) {
      return roleNameToPerm[givenRole].contains("*") || roleNameToPerm[givenRole].contains("#");
    } else if (cmBloc != null) {
      var p = cmBloc.state.role["permissions"];
      return p.contains("*") || p.contains("#");
    } else {
      return false;
    }
  }

  // list of actions can be used to depict or calculate actions
  static const List<String> permissionsUi = [
    // child 1
    CmActions.makeRoom, CmActions.accessToSettings,
    CmActions.canChangeRoles,
    CmActions.updatePrivacy, CmActions.kickAndBan,
  ];

  // map where roleName is key and maps to permissions.
  static const Map<String, dynamic> roleNameToPerm = {
    "Lead": [
      CmActions.makeRoom,
      CmActions.accessToSettings,
      CmActions.canChangeRoles,
      CmActions.updatePrivacy,
      CmActions.kickAndBan,
    ],
    "Admin": [
      CmActions.makeRoom,
      CmActions.accessToSettings,
      CmActions.canChangeRoles,
      CmActions.updatePrivacy,
      CmActions.kickAndBan,
    ],
    "Mod": [
      CmActions.updatePrivacy,
      CmActions.kickAndBan,
    ],
    "Member": []
  };

  static void promoteMember({required String memId, required String cmId, required String promotionRoleName}) {
    // path to firebase
    var fire = FirebaseFirestore.instance;
    // update
    fire.collection(Paths.communityMembers).doc(cmId).collection(Paths.members).doc(memId).update({"kfRole" : promotionRoleName});
    // done

  }
}
