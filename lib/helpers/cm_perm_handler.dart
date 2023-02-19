import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

// roles will be: owner (soon migrate to captin), admin, mod

class CmPermHandler {
  // permission for owners
  static bool isOwner(CommuinityBloc cmBloc) {
    return cmBloc.state.role["kfRole"] == "Lead";
  }

  // permission for admins
  static bool isAdmin(CommuinityBloc cmBloc) {
    return cmBloc.state.role["kfRole"] == "Lead" ||
        cmBloc.state.role["kfRole"] == "Admin";
  }
// -----------------------------------------------
  // permission for creating a room
  static bool canMakeRoom(CommuinityBloc cmBloc) {
    return cmBloc.state.role["kfRole"] == "Lead" ||
        cmBloc.state.role["kfRole"] == "Admin" || cmBloc.state.role["kfRole"] == "Mod";
  }

  // permission for del a room (same as creating room)

  // permission for kicking / baning a user
  static bool canRemoveMember({required CommuinityBloc? cmBloc}) {
    if (cmBloc!.state.role["kfRole"] == "Lead" || cmBloc.state.role["kfRole"] == "Mod" || cmBloc.state.role["kfRole"] == "Admin") {
      return true;
    } else {
      return false;
    }
  }

  // permission for updating roles (can not change the owners role)
  static bool canUpdateRole({required CommuinityBloc? cmBloc,}) {
      if (cmBloc!.state.role["kfRole"] == "Lead" || cmBloc.state.role["kfRole"] == "Mod" || cmBloc.state.role["kfRole"] == "Admin") {
      return true;
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
