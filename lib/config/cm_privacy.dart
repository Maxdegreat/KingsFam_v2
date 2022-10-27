class CmPrivacy {

  // no one can join unless invited by an admin,
  // does not show up in explore lst
  static const String locked = "locked";

  // no one can join unless admitted by admin
  // still shows up in explore lst
  // messages in Cords and says are hidden too,
  // post are readable
  static const String private = "private";

  // anyone can join, and view cm and read chats, says
  static const String open = "open";


}