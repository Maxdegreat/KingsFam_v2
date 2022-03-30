import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/call_model.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'ringer_event.dart';
part 'ringer_state.dart';

class RingerBloc extends Bloc<RingerEvent, RingerState> {

  
  final AuthBloc _authBloc;

  StreamSubscription<List<CallModel>>? _ringSubscription;

  RingerBloc({

    required AuthBloc authBloc,
  }) :  _authBloc = authBloc, super(RingerState.initial()) {
    
      print("trying the ring subscription");
      // _ringSubscription?.cancel();
      // _ringSubscription = _ringerRepository
      //   .getUserCalls(userId: _authBloc.state.user!.uid)
      //   .listen((value) {
      //     print("we heard a new value!");
      //     final allRings = value;
      //     add(RingerUpdateRings(rings: allRings));
    
  }

  Future<void> close() {
    _ringSubscription!.cancel();
    return super.close();
  }

  Stream<RingerState> mapEventToState(RingerEvent event) async* {
    if (event is RingerUpdateRings) {
      yield* _mapRingerUpdateRingsToState(event);
    }
  }

  Stream<RingerState>  _mapRingerUpdateRingsToState(RingerUpdateRings event) async* {
   yield state.copyWith(call: event.rings, status: RingerStatus.ringing);
  }

}
