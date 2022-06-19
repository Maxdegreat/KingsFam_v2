import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
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

  StreamSubscription<List<Future<Chat?>>>? _chatsStreamSubscription;
  StreamSubscription<List<Future<Church?>>>? _churchStreamSubscription;


  ChatscreenBloc({
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
    required LikedPostCubit likedPostCubit,
    required PostsRepository postsRepository,
    required ChurchRepository churchRepository,
  })  : _chatRepository = chatRepository,
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
      yield* _mapLoadChatsToState(event);
    }
    else if (event is LoadCms) {
      yield* _mapLoadCmsToState();
    }
  }

  // This is the maping of commuinity to state

  Stream<ChatscreenState> _mapLoadCmsToState() async* {
    try {
      final Map<String, bool> mentionedMap = {};
      final List<Church> allChs = [];
      _churchStreamSubscription?.cancel();
      _churchStreamSubscription = _churchRepository
          .getCmsStream(currId: _authBloc.state.user!.uid)
          .listen((churchs) async {
        final allChs = await Future.wait(churchs);
        for (var ch in churchs) {
          var church = await ch;
          // if(church != null)
          //   allChs.add(church);
          var hasSnap = await FirebaseFirestore.instance.collection(Paths.mention).doc(_authBloc.state.user!.uid).collection(church!.id!).limit(1).get();
          var snaps = hasSnap.docs;
          if (snaps.length > 0)
            mentionedMap[church.id!] = true;
          else 
            mentionedMap[church.id!] = false;
        }
        emit(state.copyWith(chs: allChs));
        emit(state.copyWith(mentionedMap: mentionedMap));
      });
      yield state.copyWith(status: ChatStatus.sccuess);
    } catch (e) {}
  }

  // This is the maping of chats to state, (this is currently not being used, rather a streamblder in UI is
  // this needs to be addressed)

    //jesus
  Stream<ChatscreenState> _mapLoadChatsToState(event) async* {
    try {
      state.copyWith(status: ChatStatus.loading);

      _chatsStreamSubscription?.cancel();

      _chatsStreamSubscription = _chatRepository
          .getUserChats(userId: _authBloc.state.user!.uid)
          .listen((chat) async {
        final allChats = await Future.wait(chat);
        state.copyWith(chat: allChats);
      });
      add(LoadCms());
      // state.copyWith(status: ChatStatus.sccuess);
    } catch (e) {
      state.copyWith(
          failure: Failure(
              message: 'error loading your chats, check ur connection fam'));
    }
  }
}
