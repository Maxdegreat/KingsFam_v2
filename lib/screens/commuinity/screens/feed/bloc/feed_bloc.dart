import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final LikedPostCubit _likedPostCubit;
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;
  FeedBloc({
    required PostsRepository postsRepository,
    required AuthBloc authBloc,
    required LikedPostCubit likedPostCubit,
  })  : _likedPostCubit = likedPostCubit,
        _authBloc = authBloc,
        _postsRepository = postsRepository,
        super(FeedState.inital());

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is FeedFetchPosts) {
      yield* _mapFeedFetchPostToState();
    } else if (event is FeedCommuinityFetchPosts) {
      yield* _mapFeedCommuinityFetchPostToState(event);
    } else if (event is FeedPaginatePosts) {
      yield* _mapFeedPaginatePosts();
    } else if (event is CommunityFeedPaginatePost) {
      yield* _mapCommunityFeedPaginatePosts(event);
    }
  }

  static const int PAGIATIONLIMIT = 4;

  Stream<FeedState> _mapFeedCommuinityFetchPostToState(
      FeedCommuinityFetchPosts event) async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      final posts = await _postsRepository.getCommuinityFeed(commuinityId: event.commuinityId, lastPostId: event.lastPostId);

      posts.add(Post.empty.copyWith(id: posts.last!.id));

      posts.insert(2, Post.empty);

      _likedPostCubit.clearAllLikedPosts();

      final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
      yield state.copyWith(
          posts: posts,
          status: FeedStatus.success,
          likedPostIds: likedPostIds);
    } catch (e) {}
  }

  Stream<FeedState> _mapFeedFetchPostToState() async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      log("geting the user feed");
      final postsGot = await _postsRepository.getUserFeed(
          userId: _authBloc.state.user!.uid, limit: PAGIATIONLIMIT);

      // log(posts.toString());
      _likedPostCubit.clearAllLikedPosts();

      final likedPostIds = await _postsRepository.getLikedPostIds(
          userId: _authBloc.state.user!.uid, posts: postsGot);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
      List<Post?> posts = List<Post?>.from(state.posts)..addAll(postsGot);

      posts.add(Post.empty.copyWith(id: posts.last!.id));
      posts.insert(2, Post.empty.copyWith(id: null));
      
      yield state.copyWith(
          posts: posts,
          status: FeedStatus.success);
    } catch (err) {
      yield state.copyWith(
          status: FeedStatus.error,
          failure: Failure(
              message: "Um, something went wrong when loading the feed???"));
    }
  }

  Stream<FeedState> _mapFeedPaginatePosts() async* {
    yield state.copyWith(status: FeedStatus.paginating);
    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
      final posts = await _postsRepository.getUserFeed(
          userId: _authBloc.state.user!.uid, lastPostId: lastPostId, limit: 8);
                posts.add(Post.empty.copyWith(id: posts.last!.id));

      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

      final likedPostIds = await _postsRepository.getLikedPostIds(
          userId: _authBloc.state.user!.uid, posts: posts);
      yield state.copyWith(
          posts: updatedPosts,
          status: FeedStatus.success);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
    } catch (e) {
      yield state.copyWith(
          failure: Failure(
              message: "dang, max messed up you're pagination code...",
              code: e.toString()),
          status: FeedStatus.error);
    }
  }

   Stream<FeedState> _mapCommunityFeedPaginatePosts(CommunityFeedPaginatePost event) async* {
    yield state.copyWith(status: FeedStatus.paginating);
    try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;

      final posts = await _postsRepository.getCommuinityFeed(commuinityId: event.commuinityId, lastPostId: lastPostId);
      posts.add(Post.empty.copyWith(id: posts.last!.id));

      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);

      final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
      yield state.copyWith(
          posts: updatedPosts,
          status: FeedStatus.success);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
    } catch (e) {
      yield state.copyWith(
          failure: Failure(
              message: "dang, max messed up you're pagination code...",
              code: e.toString()),
          status: FeedStatus.error);
    }
  }

}
