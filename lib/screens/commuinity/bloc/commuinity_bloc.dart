import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/mentioned_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/widgets/snackbar.dart';
import 'package:video_player/video_player.dart';

part 'commuinity_event.dart';
part 'commuinity_state.dart';

class CommuinityBloc extends Bloc<CommuinityEvent, CommuinityState> {
  final ChurchRepository _churchRepository;
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final UserrRepository _userrRepository;
  final CallRepository _callRepository;

  // three stream subscriptions used for listening to new values of each
  // respectivly
  StreamSubscription<List<Future<KingsCord?>>>? _streamSubscriptionKingsCord;
  StreamSubscription<List<Future<CallModel>>>? _streamSubscriptionCalls;
  StreamSubscription<bool>? _streamSubscriptionIsMember;

  CommuinityBloc({
    required ChurchRepository churchRepository,
    required StorageRepository storageRepository,
    required AuthBloc authBloc,
    required CallRepository callRepository,
    required UserrRepository userrRepository,
  })  : _churchRepository = churchRepository,
        _storageRepository = storageRepository,
        _authBloc = authBloc,
        _userrRepository = userrRepository,
        _callRepository = callRepository,
        super(CommuinityState.inital());

  @override
  Future<void> close() {
    _streamSubscriptionCalls!.cancel();
    _streamSubscriptionKingsCord!.cancel();
    _streamSubscriptionIsMember!.cancel();
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

  String failed = 'failed to load commuinty screen';

  

  Stream<CommuinityState> _mapCommuinityLoadCommuinityToState(CommuinityLoadCommuinity event) async* {
    if(event.vidCtrl != null) {
      event.vidCtrl!.pause();
    }
    emit(state.copyWith(status: CommuintyStatus.loading));
    try {
      
      final Userr userr = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);

      
      emit(state.copyWith(themePack: event.commuinity.themePack, boosted: event.commuinity.boosted));

      // update the usr timestamp for the cm when they open the cm
      Church cm = Church.empty.copyWith(id: event.commuinity.id, members: event.commuinity.members, );

      _churchRepository.updateUserTimestampOnOpenCm(cm, _authBloc.state.user!.uid);
      final List<KingsCord> allCords = [];
      final Map<String, bool> mentionedMap = {};
      _streamSubscriptionKingsCord?.cancel();
      _streamSubscriptionKingsCord = _churchRepository
          .getCommuinityCordsStream(commuinity: event.commuinity, limit: 20)
          .listen((kcords) async {
          final allCords = await Future.wait(kcords);
           for (var kcAwait in kcords) {
             final kc = await kcAwait;
             if (kc!=null) {
               //allCords.add(kc);
               var docRef = await FirebaseFirestore.instance.collection(Paths.mention).doc(_authBloc.state.user!.uid).collection(event.commuinity.id!).doc(kc.id);
               docRef.get().then((value) => {
                 if (value.exists) {
                   mentionedMap[kc.id!] = true,
                 }
                 else {
                   mentionedMap[kc.id!] = false
                 },
                 emit(state.copyWith(mentionedMap: mentionedMap, currUserr: userr))
               });
             }
           }
          
        add(ComuinityLoadingCords(
            commuinity: event.commuinity, cords: allCords));
      });
    } catch (e) {
      emit(state.copyWith(
          status: CommuintyStatus.error,
          failure: Failure(message: failed, code: e.toString())));
    }
  }

  Stream<CommuinityState> _mapCommuinityLoadingCordsToState(
      ComuinityLoadingCords event) async* {
    // make calls sream
    // add calls to loaded then yield
    // also add this.event to loaded yield ... now has both list (this event has the cord and cm)
    // STILL LOAFDING SO NO YIELD YET
    try {
      List<Post?> posts = await _churchRepository.getCommuinityPosts(cm: event.commuinity);
      _streamSubscriptionCalls?.cancel();
      _streamSubscriptionCalls = _callRepository
          .getCommuinityCallsStream(
              commuinityId: event.commuinity.id!, limit: 7)
          .listen((calls) async {
        final allCalls = await Future.wait(calls);
        add(CommuinityLoadedEvent(
            calls: allCalls,
            kcs: event.cords,
            posts: posts,
            commuinity: event.commuinity));
      });
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: failed, code: e.toString())));
    }
  }

  Stream<CommuinityState> _mapCommuinityLoadedToState(
      CommuinityLoadedEvent event) async* {
    try {
      //var cmIds = event.commuinity.members.keys.map((e) => e.id).toList();
      late bool isMem;
  
      var ism = await _churchRepository
          .streamIsCmMember(cm: event.commuinity, authorId: _authBloc.state.user!.uid);
      _streamSubscriptionIsMember = ism.listen((isMemStream) async {
        for (var kc in event.kcs) 

          log("from bloc kc recentSenderInfo is: ${kc!.recentSender}");
        
        isMem = await isMemStream;
        emit(state.copyWith(
            calls: event.calls,
            isMember: isMem,
            kingCords: event.kcs,
            postDisplay: event.posts,
            status: CommuintyStatus.loaded,
            ));
      });

    // checking for perks
    

    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: failed, code: e.toString())));
    }
    //yield CommuinityLoaded(calls: event.calls, kingCords: event.kcs, postDisplay: event.posts, isMember: isMem);
  }

  // ============== funcs =======================

  Future<void> onLeaveCommuinity({required Church commuinity}) async {
    final userrId = _authBloc.state.user!.uid;
    _churchRepository.leaveCommuinity(commuinity: commuinity, leavingUserId: userrId);
    emit(state.copyWith(isMember: false));
  }

  Future<void> onJoinCommuinity({required Church commuinity}) async {
    final userrId = _authBloc.state.user!.uid;
    final user = await _userrRepository.getUserrWithId(userrId: userrId);
    _churchRepository.onJoinCommuinity(commuinity: commuinity, user: user);
    emit(state.copyWith(isMember: true));
  }

  void onBoostCm({required String cmId}) {
    _churchRepository.onBoostCm(cmId: cmId);
    emit(state.copyWith(boosted: 1));
  }

  void setTheme({required String cmId, required String theme}) {
    _churchRepository.setTheme(cmId: cmId, theme: theme);
  }

  Future<void> delKc(
      {required KingsCord cord, required Church commuinity}) async {
    await _churchRepository.delCord(cmmuinity: commuinity, cord: cord);
  }

  Future<void> makeNewKc(
      {required Church commuinity,
      required String cordName,
      required BuildContext ctx,}) async {

      Userr currUser = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);
      KingsCord? kc = await _churchRepository.newKingsCord2(ch: commuinity, cordName: formatCordName(cordName), currUser: currUser);
      // WE DO NOT EMIT TO STATE BECAUSE THERE IS ALREDY A STREAM LISTENING FOR KC'S AND THE STREAM EMITS TO STATE
      // ANY ATTEMPT TO EMIT FROM HERE WHILE THE STREAM IS ACTIVE WILL CAUSE SOME OUT OF RANGE ERRORS.
    
  }

  String formatCordName(String cordName) {
    String newName = "";
    for (int i = 0; i < cordName.length; i++) {
      if (cordName[i] == " ") {
        newName += "-";
      } else {
        newName += cordName[i];
      }
    }
    return newName;
  }


  dispose() {
    state.copyWith(calls: [], failure: Failure(), isMember: false, kingCords: [], postDisplay: [], status: CommuintyStatus.inital);
  }

  void onCollapsedCord() {
    if (state.collapseCordColumn)
      emit(state.copyWith(collapseCordColumn: false));
    else
      emit(state.copyWith(collapseCordColumn: true));
  }

  void onCollapsedVvrColumn() {
    if (state.collapseVvrColumn)
      emit(state.copyWith(collapseVvrColumn: false));
    else 
      emit(state.copyWith(collapseVvrColumn: true));
  }

}
