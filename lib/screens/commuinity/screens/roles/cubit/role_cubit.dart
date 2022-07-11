import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';

part 'role_state.dart';

class RoleCubit extends Cubit<RoleState> {
  RoleCubit() : super(RoleState.inital());

  // go look for permissions and grab what is needed
  void getPermissions({required String doc}) async {
    var documentSnap = await FirebaseFirestore.instance.collection(Paths.church).doc(doc).collection(Paths.permissions).doc(doc).get();
    if (documentSnap.exists) {
      log("THE DOC ECISTSSSSSSSSSSSSSSSS");
      final data = documentSnap.data() as Map<String, dynamic>;
      final map =  {
        Roles.Owner : ['*'],
        Roles.Admin : List<String>.from(data[Roles.Admin]),
        Roles.Elder : List<String>.from(data[Roles.Elder]),
        // Roles.Member : Set<int>.from(data[Roles.Member]),
      };
      emit( state.copyWith(permissionsMap: map));
  } else {
    log("THE DOC DOES NOT EXITST");

  } 
  
  }

  // populat the isChecked
  void onPopulateIsChecked(String role) {
    for (String a in Actions.communityActions) {
      // check if state.permissions contains this role. rtn a bool
      if (state.permissionsMap[role]!.contains(a)) {
        state.isChecked[a] = true;
      } else {
        state.isChecked[a] = false;
      }
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
