import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:video_player/video_player.dart';

part 'bottomnavbar_state.dart';

class BottomnavbarCubit extends Cubit<BottomnavbarState> {
  BottomnavbarCubit()
      : super(BottomnavbarState(
            selectedItem: BottomNavItem.chats, showBottomNav: true));

  void setVidCtrl(VideoPlayerController vidCtrl) {
    emit(state.copyWith(vidCtrl: vidCtrl));
  }

  void rmvVidCtrl() => emit(state.copyWith(vidCtrl: null));

  void showBottomNav(bool b) => emit(state.copyWith(showBottomNav: b));

  void updateSelectedItem(BottomNavItem item) {
    if (state.vidCtrl != null && state.vidCtrl!.value.isPlaying) {
      state.vidCtrl!.pause();
      if (item != state.selectedItem) {
        emit(BottomnavbarState(
            selectedItem: item, showBottomNav: true));
      }
    } else {
      if (item != state.selectedItem) {
        emit(BottomnavbarState(
            selectedItem: item, showBottomNav: true));
      }
    }
  }
}
