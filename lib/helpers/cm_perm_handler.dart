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
  static bool canRemoveMember(CommuinityBloc cmBloc) {
    var p = cmBloc.state.role["permissions"];
    return p.contains("*") || p.contains("#") || p.contains('mod');
  }

  // psemission for updating the cm privacy
  static bool canUpdatePrivacy(CommuinityBloc cmBloc) {
    var p = cmBloc.state.role["permissions"];
    return p.contains("*") || p.contains("#") || p.contains('mod');
  }

  // permission for updating roles (can not change the owners role)
  static bool canUpdateRole(CommuinityBloc cmBloc) {
    var p = cmBloc.state.role["permissions"];
    return p.contains("*") || p.contains("#");
  }
}
