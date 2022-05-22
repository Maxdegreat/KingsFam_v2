import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/data/ad_helper.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/chat/chat_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chats/chats_screen.dart';

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
    if (event is ChatScreenFetchPosts) {
      yield* _mapFetchPostToState();
    } else if (event is ChatScreenPaginatePosts) {
      yield* _mapPaginatePost();
    } else if (event is LoadCms) {
      yield* _mapLoadCmsToState();
    }
  }

  Stream<ChatscreenState> _mapLoadCmsToState() async* {
    try {
      _churchStreamSubscription?.cancel();
      _churchStreamSubscription = _churchRepository
          .getCmsStream(currId: _authBloc.state.user!.uid)
          .listen((churchs) async {
        final allChs = await Future.wait(churchs);
        emit(state.copyWith(chs: allChs));
      });
      yield state.copyWith(status: ChatStatus.sccuess);
    } catch (e) {}
  }

  Stream<ChatscreenState> _mapLoadChatsToState(event) async* {
    //jesus
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

  Stream<ChatscreenState> _mapFetchPostToState() async* {
    yield state.copyWith(posts: [], fstatus: FeedStatus_chats.loading);

      try {
        log("get user feed");
        final postsGot = await _postsRepository.getUserFeed(
            userId: _authBloc.state.user!.uid, limit: 8);

        // log(posts.toString());
        _likedPostCubit.clearAllLikedPosts();

        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: postsGot);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        List<Post?> posts = List<Post?>.from(state.posts)..addAll(postsGot);
        yield state.copyWith(posts: posts, fstatus: FeedStatus_chats.success);
      } catch (err) {
        yield state.copyWith(
            fstatus: FeedStatus_chats.error,
            failure: Failure(
                message: "Um, something went wrong when loading the feed???"));
      }
    }
  
  Stream<ChatscreenState> _mapPaginatePost() async* {
    yield state.copyWith(fstatus: FeedStatus_chats.paginating);
    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
      final posts = await _postsRepository.getUserFeed(
          userId: _authBloc.state.user!.uid, lastPostId: lastPostId, limit: 8);

      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

      final likedPostIds = await _postsRepository.getLikedPostIds(
          userId: _authBloc.state.user!.uid, posts: posts);
      yield state.copyWith(
          posts: updatedPosts, fstatus: FeedStatus_chats.success);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
    } catch (e) {
      yield state.copyWith(
          failure: Failure(
              message: "dang, max messed up you're pagination code...",
              code: e.toString()),
          fstatus: FeedStatus_chats.error);
    }
  }
}
