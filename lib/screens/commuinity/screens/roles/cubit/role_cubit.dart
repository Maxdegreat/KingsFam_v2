import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';

part 'role_state.dart';

class RoleCubit extends Cubit<RoleState> {
  RoleCubit() : super(RoleState.inital());

  // This does not need a whole cm just the id, and permissions, 
  void onSetCommunity({required Church community}) {
    emit(state.copyWith(community: community));
  }
  
  // go look for permissions and grab what is needed
  Future<void> getPermissions({required String doc}) async {
    var documentSnap = await FirebaseFirestore.instance.collection(Paths.church).doc(doc).get();
    if (documentSnap.exists) {
      var permissions = Church.fromDocPermissions(documentSnap);
      Map<String, List<String>> pMap = {};
      for (var key in permissions.keys) {
        pMap[key] = List<String>.from(permissions[key]);
      }
      log("The permissions is $pMap"); 
      emit(state.copyWith(permissionsMap: pMap));
  } else {
    log("THE DOC DOES NOT EXITST");

  } 
  
  }

  // populat the isChecked
  void onPopulateIsChecked(String role) {
    log(state.permissionsMap.toString());
    log("that was the pemissions map that was updated with dummy data");
    if (state.permissionsMap[role] != null) {
      for (String a in Actions.communityActions) {
      // check if state.permissions contains this role. rtn a bool
      if (state.permissionsMap[role]!.contains(a)) {
        state.isChecked[a] = true;
      } else {
        state.isChecked[a] = false;
      }
    }
    } else {
      log("!!!!!!!!!!!!!! The state.permissionsMap does not contain $role");
    }
   }
  // update state based on what permissions are needed

  // emit states
  void onChanged(String role, String action) {
    var isChecked = state.isChecked;
    var map = state.permissionsMap;
    if (map[role]!.contains(action)) {
      map[role]!.remove(action);
      isChecked[action] = false;
      emit(state.copyWith(permissionsMap: map, isChecked: isChecked));
    } else {
      map[role]!.add(action);
      isChecked[action] = true;
      emit(state.copyWith(permissionsMap: map, isChecked: isChecked));
    }
  }
  // make a save btn
  void onSave(String docId) async {
    FirebaseFirestore.instance.collection(Paths.church).doc(docId).collection(Paths.permissions).doc(docId).update(state.permissionsMap);
  }

}
