import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/repositories/vc/vcRepository.dart';

part 'vc_event.dart';
part 'vc_state.dart';

class VcBloc extends Bloc<VcEvent, VcState> {
  final UserrRepository _userrRepository;
  final VcRepository _vcRepository;

  StreamSubscription<List<Future<Userr>>>? _streamSubscription;

  VcBloc(
      {required UserrRepository userrRepository,
      required VcRepository vcRepository})
      : _userrRepository = userrRepository,
        _vcRepository = vcRepository,
        super(VcState.inital());


  @override
  Stream<VcState> mapEventToState(VcEvent event) async* {
    if (event is VcInit) {
      yield* _mapVcInitToState(event);
    } else if (event is VcEventUserJoined) {
      yield* _mapVcEventUserJoinToState(event);
    } else if (event is VcEventUserLeft) {
      yield* _mapVcEventUserLeftToState(event);
    }
  }

  @override
  Future<void> close() {
    _streamSubscription!.cancel();
    return super.close();
  }


  Stream<VcState> _mapVcInitToState(VcInit event) async* {
    try {
      _streamSubscription?.cancel();
      _streamSubscription = await _vcRepository.participantsListen(
        cmId: event.cmId,
        kcId: event.kcId,
      ).listen((participantList) async {
        _vcRepository.waitForParticipants(participantList).then((users) {
          emit(state.copyWith(participants: users));
        });
       });
    } catch (e) {
      log("error in vcBlock: " + e.toString());
    }
  }
  Stream<VcState> _mapVcEventUserJoinToState(VcEventUserJoined event) async* {
    _vcRepository.userJoinVc(cmId: event.cmId, kcId: event.kcId, userr: event.userr);
  }
    Stream<VcState> _mapVcEventUserLeftToState(VcEventUserLeft event) async* {
      _streamSubscription!.cancel();
    _vcRepository.userLeaveVc(cmId: event.cmId, kcId: event.kcId, userr: event.userr);
  }

  void rmvUserSetState(String id) {
    for (Userr u in state.participants) {
      if (u.id == id) {
        state.participants.remove(u);
        break;
      }
    }
    emit(state.copyWith(participants: state.participants));
  }
}
