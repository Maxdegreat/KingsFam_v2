import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'follow_state.dart';

class FollowCubit extends Cubit<FollowState> {
  UserrRepository _userrRepository;
  FollowCubit({
    required UserrRepository userrRepository
  }) : _userrRepository = userrRepository, super(FollowState.inital());

  //  ---------------- methods --------------------
  Future<void> getFollowing({required String userId, required String? lastStringId}) async {
    var lst = await _userrRepository.followingList(currUserId: userId, lastStringId: lastStringId);
    emit(state.copyWith(following: List<Userr>.from(state.following)..addAll(lst)));
  }

  Future<void> getFollowers({required String userId, required String? lastStringId}) async {
    var lst = await _userrRepository.followerList(currUserId: userId, lastStringId: lastStringId);
    emit(state.copyWith(followers: List<Userr>.from(state.followers)..addAll(lst)));
  }

  

}
