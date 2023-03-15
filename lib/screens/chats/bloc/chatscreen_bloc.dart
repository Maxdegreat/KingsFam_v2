// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/config/mock_flag.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'chatscreen_event.dart';
part 'chatscreen_state.dart';

class ChatscreenBloc extends Bloc<ChatscreenEvent, ChatscreenState> {
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;
  final LikedPostCubit _likedPostCubit;
  final ChurchRepository _churchRepository;
  final UserrRepository _userrRepository;

  StreamSubscription<List<Future<Chat?>>>? _chatsStreamSubscription;
  StreamSubscription<List<Future<Church?>>>? _churchStreamSubscription;
  // StreamSubscription<List<Church?>>? _churchStreamSubscription; // a stream form shared preerences

  ChatscreenBloc({
    required AuthBloc authBloc,
    required LikedPostCubit likedPostCubit,
    required PostsRepository postsRepository,
    required ChurchRepository churchRepository,
    required UserrRepository userrRepository,
  })  : 
        _userrRepository = userrRepository,
        _authBloc = authBloc,
        _likedPostCubit = likedPostCubit,
        _postsRepository = postsRepository,
        _churchRepository = churchRepository,
        super(ChatscreenState.initial());

  // @override
  // Future<void> close() {
  //   _chatsStreamSubscription!.cancel();
  //   _churchStreamSubscription!.cancel();
  //   return super.close();
  // }

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
    } else if (event is ChatScreenUpdateSelectedKc) {
      yield* _updateSelectedItemKc(event);
    }
  }

  // This is the maping of commuinity to state

  void updateSelectedCm(Church cm) {
    emit(state.copyWith(selectedCh: cm));
  }

  Stream<ChatscreenState> _mapLoadCmsToState() async* {
    try {
      
      if (!kIsWeb) {
             // update the user token. Ios has an issue of loosing tokens over time.
      FirebaseMessaging.instance.getToken().then((token) {
        // log("token is: " + token.toString());
        _saveTokenToDatabase(token!).then((_) {
          FirebaseMessaging.instance.onTokenRefresh
              .listen(_saveTokenToDatabase);
          // log("saved the token: Done");
        });
      });
      }

      String? lastVisitedCmId = await UserPreferences.getLastVisitedCm();
      if (lastVisitedCmId != null && !kIsWeb) {
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

      bool isInCm = await _churchRepository.isInCm(_authBloc.state.user!.uid);

      await getChsToJoinIfNeeded(isInCm, chsToJoin);
      _churchStreamSubscription?.cancel();
      _churchStreamSubscription = _churchRepository
          .getCmsStream(currId: currUserr.id)
          .listen((churchs) async {
        // var allChs = await Future.wait(churchs);
        // emit ( state.copyWith(chs: null, status: ChatStatus.loading ) );

        _churchRepository.FutureChurchsAndMentioned(
                c: churchs, uid: _authBloc.state.user!.uid)
            .then((chs) {
    
          if (chs["c"].isEmpty) {
            emit(state.copyWith(selectedCh: null));
            getChsToJoinIfNeeded(false, chsToJoin);
          } else if (state.selectedCh == null) {
            emit(state.copyWith(selectedCh: chs["c"].first));
          }

          emit(state.copyWith(
              chs: chs["c"],
              mentionedMap: chs["m"],
              status: ChatStatus.setState));
          emit(state.copyWith(status: ChatStatus.sccuess));
          
          UserPreferences.getLastVisitedKc().then((lastVisitedKc) {
            log("lastVisitedKc: " + lastVisitedKc.toString());
            if (lastVisitedKc == null) {
              KingsCordRepository().getKcFirstCm(state.selectedCh!.id!).then((kc) {
              if (kc != null)
                add(ChatScreenUpdateSelectedKc(kc: kc));
              });
            } else {
              if (state.selectedCh != null) {
                KingsCordRepository().getKcWithId(lastVisitedKc, state.selectedCh!.id!).then((kc) {
                  if (kc != null)
                    add(ChatScreenUpdateSelectedKc(kc: kc));
                });
              }
            }
          });
        });
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

  Future<void> getChsToJoinIfNeeded(bool isInCm, List<Church> chsToJoin) async {
    if (!isInCm && state.chsToJoin.isEmpty) {
      int limit = MockFlag.ISMOCKTESTING ? 1 : 15;
      chsToJoin = await _churchRepository.grabChurchs(limit: limit);
      emit(state.copyWith(chsToJoin: chsToJoin, chs: []));
    }
  }

  Future<void> removeCmFromJoinedCms({required String leftCmId}) async {

    emit(ChatscreenState.initial());
    add(LoadCms());
    scaffoldKey.currentState!.closeDrawer();

    // if (state.chs != null) {
    //   for (var i in state.chs!) {
    //     if (i!.id == leftCmId) {
    //       state.chs!.remove(i);
    //       emit(state.copyWith(chs: state.chs));
    //       break;
    //     }
    //   }
    // }

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
      emit(state.copyWith(status: ChatStatus.setState));
      emit(state.copyWith(status: ChatStatus.initial));

    } catch (e) {
      log("Failure in chatScreenBloc when attempting to update selected cm. error log is e: ${e.toString()}");
    }
  }

  Stream<ChatscreenState> _updateSelectedItemKc(ChatScreenUpdateSelectedKc event) async* {
    try {
      emit(state.copyWith(selectedKc: event.kc));
      emit(state.copyWith(status: ChatStatus.setStateKc));
      emit(state.copyWith(status: ChatStatus.initial));
    } catch (e) {
      log("Failure in chatScreenBloc when attempting to update selected kc. error log is e: ${e.toString()}");

    }
  }

  void leftCm({required String id}) {
    var lst = state.chs;
    for (var c in lst!) {
      if (c!.id == id) {
        lst.remove(c);
        emit(state.copyWith(chs: lst));
      }
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    String userId = _authBloc.state.user!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'token': [token] //FieldValue.arrayUnion([token])
    });
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
