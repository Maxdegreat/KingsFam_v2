import 'package:kingsfam/roles/role_types.dart';

class Actions {
  bool hasAccess({required String role, required String action}) {
    return accessChecker[role]!.contains(action);
  }

  Map<String, List<String>> accessChecker = {
    Roles.Owner : communityAdminDefaultActions,
    Roles.Admin : communityAdminDefaultActions,
    Roles.Elder : communityElderDefaultActions,
    Roles.Member : communityMembersActins,
  };

  // 777 stands for all roles
  static const communityActions = [
    /* 0 */ 'cm/settings/updateName',
    /* 1 */ 'cm/settings/updateCommunityBanner',
    /* 2 */ 'cm/settings/updateAbout',
    /* 3 */ 'cm/settings/manageAndUpdateRoles',
    /* 4 */ 'cm/addChatRooms',
    /* 5 */ 'cm/addVvr',
    /* 6 */ 'cm/kickMembers',
    /* 7 */ 'cm/delChatRooms'
  ];

  static final communityAdminDefaultActions = [
    communityActions[0],
    communityActions[1],
    communityActions[2],
    communityActions[3],
    communityActions[4],
    communityActions[5],
    communityActions[6]
  ];

  static final communityElderDefaultActions = [
    communityActions[6],
    communityActions[5],
    communityActions[4],
  ];

  static final communityMembersActins = [
    "none"
  ];
}
