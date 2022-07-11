class Actions {
  // 777 stands for all roles
  static const communityActions = [
   /* 1 */ 'cm/settings/updateName',
   /* 2*/ 'cm/settings/updateCommunityBanner',
   /* 3 */ 'cm/settings/updateAbout',
   /* 4 */ 'cm/settings/manageAndUpdateRoles',
   /* 5 */ 'cm/addChatRooms',
   /* 6 */ 'cm/addVvr',
   /* 7 */ 'cm/kickMembers',
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
}
