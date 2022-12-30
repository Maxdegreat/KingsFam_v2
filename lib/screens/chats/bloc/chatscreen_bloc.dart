// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/mock_flag.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'chatscreen_event.dart';
part 'chatscreen_state.dart';

class ChatscreenBloc extends Bloc<ChatscreenEvent, ChatscreenState> {
  final ChatRepository _chatRepository;
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;
  final LikedPostCubit _likedPostCubit;
  final ChurchRepository _churchRepository;
  final UserrRepository _userrRepository;

  StreamSubscription<List<Future<Chat?>>>? _chatsStreamSubscription;
  StreamSubscription<List<Future<Church?>>>? _churchStreamSubscription;
  // StreamSubscription<List<Church?>>? _churchStreamSubscription; // a stream form shared preerences

  ChatscreenBloc({
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
    required LikedPostCubit likedPostCubit,
    required PostsRepository postsRepository,
    required ChurchRepository churchRepository,
    required UserrRepository userrRepository,
  })  : _chatRepository = chatRepository,
        _userrRepository = userrRepository,
        _authBloc = authBloc,
        _likedPostCubit = likedPostCubit,
        _postsRepository = postsRepository,
        _churchRepository = churchRepository,
        super(ChatscreenState.initial());

  @override
  Future<void> close() {
    _chatsStreamSubscription!.cancel();
    _churchStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<ChatscreenState> mapEventToState(
    ChatscreenEvent event,
  ) async* {
    if (event is LoadChats) {
      //yield* _mapLoadChatsToState(event);
    } else if (event is LoadCms) {
      yield* _mapLoadCmsToState();
    } else if (event is ChatScreenUpdateSelectedCm) {
      yield* _updateSelectedItem(event);
    }
  }

  // This is the maping of commuinity to state

  Stream<ChatscreenState> _mapLoadCmsToState() async* {
    try {
      String? lastVisitedCmId = await UserPreferences.getLastVisitedCm();
      if (lastVisitedCmId != null) {
        bool isInCm_ = await _churchRepository.isInCmById(
            cmId: lastVisitedCmId, userId: _authBloc.state.user!.uid);
        if (isInCm_) {
          Church c = await Church.fromId(lastVisitedCmId);
          yield state.copyWith(selectedCh: c);
        }
      }

      // geting the currUserr for later use
      final Userr currUserr = await _userrRepository.getUserrWithId(
          userrId: _authBloc.state.user!.uid);
      // ignore: unused_local_variable
      List<Church> chsToJoin = [];

      bool isInCm = await _churchRepository.isInCm(
          _authBloc.state.user!.uid, _authBloc.state.user!.uid);

      if (!isInCm) {
        int limit = MockFlag.ISMOCKTESTING ? 1 : 15;
        chsToJoin = await _churchRepository.grabChurchs(limit: limit);
        emit(state.copyWith(chsToJoin: chsToJoin, chs: []));
      }

      _churchStreamSubscription?.cancel();
      _churchStreamSubscription = _churchRepository
          .getCmsStream(currId: currUserr.id)
          .listen((churchs) async {
        // var allChs = await Future.wait(churchs);
        emit ( state.copyWith(chs: null, status: ChatStatus.loading ) );

        Map<String, dynamic> chsAndMentionedMap =
            await _churchRepository.FutureChurchsAndMentioned(
                c: churchs, uid: _authBloc.state.user!.uid);
        for (var i in chsAndMentionedMap["c"]) {
          log(i.id! + "len of joinedCms: " + churchs.length.toString() + "\n" + " ----------------------------------------------"  );
        }
        if (chsAndMentionedMap["c"].isEmpty) 
          emit(state.copyWith(selectedCh: null));
         else if (state.selectedCh == null)
          emit( state.copyWith(selectedCh: chsAndMentionedMap["c"].first) );
        emit( state.copyWith(chs: chsAndMentionedMap["c"], mentionedMap: chsAndMentionedMap["m"], status: ChatStatus.setState));
        emit(state.copyWith(status: ChatStatus.sccuess));
      });

      yield state.copyWith(status: ChatStatus.sccuess, currUserr: currUserr);
    } catch (e) {
      log("!!!!!!!!!!!!!!!!ERROR: " + e.toString());
      yield state.copyWith(
          status: ChatStatus.error,
          failure: Failure(
              message:
                  "mmm, there was an error when loading your community's"));
    }
  }

  Future<void> removeCmFromJoinedCms({required String leftCmId}) async {
    
    if (state.chs != null) {
      
      for (var i in state.chs!) {
        if (i!.id == leftCmId) {
          state.chs!.remove(i);
          emit(state.copyWith(chs: state.chs));
          break;
        } 
      } 

    }

    if (state.selectedCh == null || state.selectedCh == leftCmId) {
      
      if (state.chs!.length > 0)
        emit(state.copyWith(selectedCh: state.chs!.first));
        emit(state.copyWith(chs: state.chs));
    }
  }

  Stream<ChatscreenState> _updateSelectedItem(
      ChatScreenUpdateSelectedCm event) async* {
    try {
      // yield state.copyWith(selectedCh: event.cm);
      emit(state.copyWith(selectedCh: event.cm));
    } catch (e) {
      log("Failure in chatScreenBloc when attempting to update selected cm. error log is e: ${e.toString()}");
    }
  }

  void leftCm({required String id}) {
    log("in left cm");
    var lst = state.chs;
    for (var c in lst!) {
      if (c!.id == id) {
        lst.remove(c);
        emit(state.copyWith(chs: lst));
      }
    }
  }

  // This is the maping of chats to state, (this is currently not being used, rather a streamblder in UI is
  // this needs to be addressed)

  //jesus
  // Stream<ChatscreenState> _mapLoadChatsToState(event) async* {
  //   try {
  //     bool unreadChats = false;
  //     Set<String> seen = {};
  //     var currId = _authBloc.state.user!.uid;
  //     List<Chat> allChats = [];
  //     state.copyWith(status: ChatStatus.loading);
  //     _chatsStreamSubscription?.cancel();
  //     _chatsStreamSubscription = _chatRepository
  //         .getUserChats(userId: _authBloc.state.user!.uid)
  //         .listen((chat) async {
  //           for (var c in chat) {
  //             Chat? ch = await c;
  //             if (ch != null) {
  //               if (ch.readStatus.containsKey(currId)) {
  //                 if (ch.readStatus[currId] == false) {
  //                   unreadChats = true;
  //                 }
  //               }
  //               if (!seen.contains(ch.id)) {
  //                 allChats.add(ch);
  //                 seen.add(ch.id!);
  //               }
  //             }
  //           }
  //         emit(state.copyWith(chat: allChats, unreadChats: unreadChats));
  //     });
  //     add(LoadCms());
  //     // state.copyWith(status: ChatStatus.sccuess);
  //   } catch (e) {
  //     state.copyWith(
  //         failure: Failure(
  //             message: 'error loading your chats, check ur connection fam'));
  //   }
  // }
}
