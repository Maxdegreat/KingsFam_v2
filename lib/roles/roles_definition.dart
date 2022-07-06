class RoleDefinitions {
  // owns the cm
  static const String Owner = 'Owner';
  // has equal rights to admin but can not kick admin or affect admin
  static const String Admin = 'Admin';
  // lower than admin but can still make kcs and vvrs
  static const String Elder = 'Elder';
  // your handy dandy member
  static const String Member = 'Member';
}