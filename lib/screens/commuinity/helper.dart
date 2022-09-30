import 'package:flutter/material.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/profile_image.dart';

import '../../models/church_model.dart';
import '../../models/user_model.dart';
import 'actions.dart';

String? getAccessCmHelp(Church cm, String uid) {
  // Actions actions = Actions();
  Userr? currUsr;
  var lst = cm.members.keys.toList();
  for (int i = 0; i < cm.members.length; i++) {
    if (lst[i].id == uid) {
      currUsr = lst[i];
      // log("found the informatjion we were looking gor and rhis is me tping ewithout thinkting at all as ig you lweant to see how sgas ttla dcaion tipa rt;his is my true speds");
      break;
    }
  }
  return cm.members.containsKey(currUsr) ? cm.members[currUsr]["role"] : null;
}

List<Userr> orderListByRole(Map<Userr, dynamic> memInfo, List<Userr> users) {
  Set<String> seen = {};
  seen.add(users[1].id);
  List<Userr> returnList = [
    users[1]
  ]; // allows me to push at 1 if owner is not first or member
  for (int i = 0; i < users.length; i++) {
    if (seen.contains(users[i].id)) continue;
    if (memInfo[users[i]]['role'] == Roles.Owner) {
      seen.add(users[i].id);
      returnList.insert(0, users[i]);
    } else if (memInfo[users[i]]['role'] == Roles.Admin) {
      seen.add(users[i].id);
      returnList.insert(1, users[i]);
    } else if (memInfo[users[i]]['role'] == Roles.Elder) {
      seen.add(users[i].id);
      returnList.add(users[i]);
    } else {
      seen.add(users[i].id);
      returnList.add(users[i]);
    }
  }
  return returnList;
}

