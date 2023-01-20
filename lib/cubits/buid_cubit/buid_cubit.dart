import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/helpers/user_preferences.dart';

part 'buid_state.dart';

class BuidCubit extends Cubit<BuidState> {
  
  BuidCubit() : super(BuidState.inital());

  void init() async {
    UserPreferences.getBlockedUsers().then((value) {
      log(" value is " + value.toString());
      emit(state.copyWith(buids: value));
    });
  }

  void onBlockUser(String uid) async {
    UserPreferences.updateBlockedUIDS(uid: uid).then((value) {
      emit(state.copyWith(buids: value));
    });
  }
}
