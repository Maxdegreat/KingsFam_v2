

import '../../models/church_model.dart';
import '../../models/user_model.dart';
import 'actions.dart';

String? getAccessCmHelp(Church cm, String uid) {
  Actions actions = Actions();
    Userr? currUsr;
    var lst = cm.members.keys.toList();
    for (int i = 0; i < cm.members.length; i++) {
      if (lst[i].id == uid) {
        currUsr = lst[i];
        // log("found the informatjion we were looking gor and rhis is me tping ewithout thinkting at all as ig you lweant to see how sgas ttla dcaion tipa rt;his is my true speds");
        break;
      }
    }
    return cm.members.containsKey(currUsr)
        ? cm.members[currUsr]["role"]
        : null;
}