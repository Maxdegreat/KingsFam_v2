import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';

part 'says_event.dart';
part 'says_state.dart';

class SaysBloc extends Bloc<SaysEvent, SaysState> {
  final LikedPostCubit _likedPostCubit;
  final AuthBloc _authBloc;
  final SaysRepository _saysRepository;

  SaysBloc(
      {required SaysRepository saysRepository,
      required LikedPostCubit likedPostCubit,
      required AuthBloc authBloc})
      : _saysRepository = saysRepository,
        _likedPostCubit = likedPostCubit,
        _authBloc = authBloc,
        super(SaysState.inital());

  @override
  Stream<SaysState> mapEventToState(SaysEvent event) async* {
    if (event is SaysFetchSays) {
      yield* _mapSaysFetchSaysToState(event);
    }
  }

  Stream<SaysState> _mapSaysFetchSaysToState(SaysFetchSays event) async* {
    yield state.copyWith(status: SaysStatus.loading, says: []);
    try {
      List<Says?> says = await _saysRepository.fetchSays(
          cmId: event.cmId, kcId: event.kcId, lastPostId: null, limit: null);
      log("The Len of Says is: " + says.length.toString());
      yield state.copyWith(says: says, status: SaysStatus.inital);
    } catch (e) {
      log("There was an error when fetching says in saysbloc: " + e.toString());
    }
  }
}
