import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'commuinity_event.dart';
part 'commuinity_state.dart';

class CommuinityBloc extends Bloc<CommuinityEvent, CommuinityState> {
  final ChurchRepository _churchRepository;
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final UserrRepository _userrRepository;
  final CallRepository _callRepository;

  StreamSubscription<List<Future<KingsCord?>>>? _streamSubscriptionKingsCord;
  StreamSubscription<List<Future<CallModel>>>? _streamSubscriptionCalls;


  CommuinityBloc({
  required ChurchRepository churchRepository,
  required StorageRepository storageRepository,
  required AuthBloc authBloc,
  required CallRepository callRepository,
  required UserrRepository userrRepository,    
  }) : 
     _churchRepository = churchRepository,
     _storageRepository = storageRepository,
     _authBloc = authBloc,
     _userrRepository = userrRepository,
     _callRepository = callRepository,
     super(CommuinityInitial());

     @override
  Future<void> close() {
    _streamSubscriptionCalls!.cancel();
    _streamSubscriptionKingsCord!.cancel();     
    return super.close();
  }

  @override
  Stream<CommuinityState> mapEventToState(CommuinityEvent event) async* {
    if (event is CommuinityLoadCommuinity) {
      yield* _mapCommuinityLoadCommuinityToState(event);
    } else if (event is ComuinityLoadingCords) {
      yield* _mapCommuinityLoadingCordsToState(event);
    } else if (event is CommuinityLoadedEvent) {
      yield* _mapCommuinityLoadedToState(event);
    } 
  }

  late List<KingsCord?> eKcs;
  late List<CallModel> eCalls;
  late List<Post?> ePosts;

  Stream<CommuinityState> _mapCommuinityLoadCommuinityToState(CommuinityLoadCommuinity event) async* {
    yield CommuinityLoading();
    _streamSubscriptionKingsCord?.cancel();
    _streamSubscriptionKingsCord = _churchRepository
      .getCommuinityCordsStream(churchId: event.commuinity.id!, limit: 7)
      .listen((kcords) async {
        final allCords = await Future.wait(kcords);
        add(ComuinityLoadingCords(commuinity: event.commuinity, cords: allCords));
      });
  }

  Stream<CommuinityState> _mapCommuinityLoadingCordsToState(ComuinityLoadingCords event) async* {
    // make calls sream
    // add calls to loaded yield
    // also add this.event to loaded yield ... now has both list
    //  STILL LOAFDING SO NO YIELD YET
    List<Post?> posts = await _churchRepository.getCommuinityPosts(cm: event.commuinity);
    _streamSubscriptionCalls?.cancel();
    _streamSubscriptionCalls = _callRepository  
      .getCommuinityCallsStream(commuinityId: event.commuinity.id!, limit: 7)
      .listen((calls) async {
        final allCalls = await Future.wait(calls);
        add(CommuinityLoadedEvent(calls: allCalls, kcs: event.cords, posts: posts, commuinity: event.commuinity));
      });
  }

  Stream<CommuinityState> _mapCommuinityLoadedToState(CommuinityLoadedEvent event) async* {
    var cmIds = event.commuinity.members.map((e) => e.id).toList();
    bool isMem = cmIds.contains(_authBloc.state.user!.uid);
    eKcs = event.kcs; eCalls = event.calls; ePosts = event.posts;
    yield CommuinityLoaded(calls: event.calls, kingCords: event.kcs, postDisplay: event.posts, isMember: isMem);
  }

  // ============== funcs =======================

  Future<void> onLeaveCommuinity( {required Church commuinity}) async {
    final userrId = _authBloc.state.user!.uid;
    _churchRepository.leaveCommuinity(commuinity: commuinity, currId: userrId);
  }

    Future<void> onJoinCommuinity ({required Church commuinity }) async {
    final userrId = _authBloc.state.user!.uid;
    final user = await _userrRepository.getUserrWithId(userrId: userrId);
    _churchRepository.onJoinCommuinity(commuinity: commuinity, user: user);
  }

  Future<void> delKc({ required KingsCord cord, required Church commuinity}) async {
    await _churchRepository.delCord(cmmuinity: commuinity, cord: cord);
  }

}
