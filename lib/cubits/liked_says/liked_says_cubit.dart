import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';

part 'liked_says_state.dart';

class LikedSaysCubit extends Cubit<LikedSaysState> {

  final SaysRepository _saysRepository;
  final AuthBloc _authBloc;

  LikedSaysCubit({
    required SaysRepository saysRepository,
    required AuthBloc authBloc,
  }) : _saysRepository = saysRepository, _authBloc = authBloc,  super(LikedSaysState.inital());

  /// when calling a says it will come back with x amount of likes as they are stored in cloud.
  /// in event user onlike we need to then update local likes to + 1 or - 1 if they remove a like
  /// we then need to simulate this action on the cloud.
  
  // update like localy
  void updateLocalLikes({required Set<String> saysIds}) {
    // when reading says from cloud we add all ids of says that user liked and push the says ids into this state.local likes.
    // we are not grabing a says entire like list... just grab the say if it contains the users id in its like. one query read per say. 
    Set<String> ids = Set<String>.from(state.localLikedSaysIds)..addAll(saysIds);
    emit(state.copyWith(localLikedSaysIds: ids));
  }

  // update the like on cloud
  Future<void> updateOnCloudLike({required String cmId, required String kcId, required String sayId, required int currLikes}) async {
     Set<String> ids = Set<String>.from(state.localLikedSaysIds);
    await _saysRepository.onLikeSays(uid: _authBloc.state.user!.uid, cmId: cmId, kcId: kcId, sayId: sayId, currLikes: currLikes).then((value) {
      if (value) {
        if (!ids.contains(sayId)) {
          ids.add(sayId);
          emit(state.copyWith(localLikedSaysIds: ids));
        }   
      } else {
        if (ids.contains(sayId)) {
          ids.remove(sayId);
          emit(state.copyWith(localLikedSaysIds: ids));
        }
      }
    });
  }

  
  // clear liked post in the case you refresh
}
