import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/mock_post_data.dart';
import 'package:kingsfam/widgets/post_single_view.dart';

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


  bool ISMOCKTESTING = false;

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    // if (event is FeedFetchPosts) {
    //   yield* _mapFeedFetchPostToState();
    // } else if (event is FeedCommuinityFetchPosts) {
    if (event is FeedCommuinityFetchPosts) {
      yield* _mapFeedCommuinityFetchPostToState(event);
    // } else if (event is FeedPaginatePosts) {
    //   yield* _mapFeedPaginatePosts();
    } else if (event is CommunityFeedPaginatePost) {
      yield* _mapCommunityFeedPaginatePosts(event);
    }
  }

  static const int PAGIATIONLIMIT = 4;

  Stream<FeedState> _mapFeedCommuinityFetchPostToState(
      FeedCommuinityFetchPosts event) async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      if (!ISMOCKTESTING) {
        List<Post?> posts = [];
        List<Widget?> postContainers = [];
        if (event.passedPost != null) {
          posts = event.passedPost!;
        } else {
          posts = await _postsRepository.getCommuinityFeed(commuinityId: event.commuinityId, lastPostId: event.lastPostId);
        }

        if (posts.length >= 2) {
          posts.add(Post.empty.copyWith(id: posts.last!.id));
          // posts.insert( 2, Post.empty );
        }
          postContainers = _makePostContainers(posts);
        _likedPostCubit.clearAllLikedPosts();

        final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        yield state.copyWith(posts: posts, postContainer: postContainers, status: FeedStatus.success, likedPostIds: likedPostIds);
      } else {
        List<Post?> posts = MockPostData.getMockPosts2;
        posts.add(Post.empty);
        List<Widget?> postContainers = MockPostData.getMock2PostContainers();
        yield state.copyWith(posts: posts, postContainer: postContainers, status: FeedStatus.success);
      }
    } catch (e) {}
  }


  Stream<FeedState> _mapCommunityFeedPaginatePosts(
      CommunityFeedPaginatePost event) async* {
    yield state.copyWith(status: FeedStatus.paginating);
    
    if (!ISMOCKTESTING) {

      try {
      final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;

      final posts = await _postsRepository.getCommuinityFeed(commuinityId: event.commuinityId, lastPostId: lastPostId);

      final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);
      updatedPosts.add(Post.empty.copyWith(id: posts.last!.id));
      final postContainers = _makePostContainers(updatedPosts);
      final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
      yield state.copyWith(posts: updatedPosts, postContainer: postContainers, status: FeedStatus.success);
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
    } catch (e) {
      yield state.copyWith(
          failure: Failure(
              message: "dang, max messed up you're pagination code...",
              code: e.toString()),
          status: FeedStatus.error);
    }

    } else {

       List<Post?> posts = MockPostData.getMockPosts4;
       posts.add(Post.empty);
       var updatedPosts = List<Post?>.from(state.posts)..addAll(posts);
        List<Widget?> postContainers = MockPostData.getMock4PostContainers();
        yield state.copyWith(posts: updatedPosts, postContainer: postContainers, status: FeedStatus.success);

    }
  }



  List<Widget> _makePostContainers(List<Post?> ps) {
    log("in the make post containers");
    List<Widget> lst = [];
    for (Post? p in ps) {
      var container = null;
  
      if (p!.author != Userr.empty) {
        var isLiked = _likedPostCubit.state.likedPostsIds.contains(p.id);
        var recentlyLiked = _likedPostCubit.state.recentlyLikedPostIds.contains(p.id);
      container = PostSingleView(
        isLiked: isLiked,
        post: p,
        // adWidget: AdWidget(ad: _bannerAd),
        recentlyLiked: recentlyLiked,
        onLike: () {
          if (isLiked) {
            _likedPostCubit.unLikePost(post: p);
          } else {
            _likedPostCubit.likePost(post: p);
          }
        },
      );
      } else {
        container = SizedBox.shrink();
      }

      // else -> container is already init as null

      lst.add(container);
    }
    log(state.posts.length.toString());
    log(")))))))))");
    log(lst.length.toString());
    return lst;
  }
}



  // Stream<FeedState> _mapFeedFetchPostToState() async* {
  //   yield state.copyWith(posts: [], status: FeedStatus.loading);
  //   try {
  //     log("geting the user feed");
  //     final postsGot = await _postsRepository.getUserFeed(
  //         userId: _authBloc.state.user!.uid, limit: PAGIATIONLIMIT);

  //     // log(posts.toString());
  //     _likedPostCubit.clearAllLikedPosts();

  //     final likedPostIds = await _postsRepository.getLikedPostIds(
  //         userId: _authBloc.state.user!.uid, posts: postsGot);
  //     _likedPostCubit.updateLikedPosts(postIds: likedPostIds);

  //     List<Post?> posts = List<Post?>.from(state.posts)..addAll(postsGot);
  //     List<Widget?> postContainers = _makePostContainers(posts);
  //     // posts.add(Post.empty.copyWith(id: posts.last!.id));
  //     // posts.insert(2, Post.empty.copyWith(id: null));

  //     yield state.copyWith(posts: posts, postContainer: postContainers, status: FeedStatus.success);
  //   } catch (err) {
  //     yield state.copyWith(
  //         status: FeedStatus.error,
  //         failure: Failure(
  //             message: "Um, something went wrong when loading the feed???"));
  //   }
  // }

  // Stream<FeedState> _mapFeedPaginatePosts() async* {
  //   yield state.copyWith(status: FeedStatus.paginating);
  //   try {
  //     final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
  //     final posts = await _postsRepository.getUserFeed(
  //         userId: _authBloc.state.user!.uid, lastPostId: lastPostId, limit: 2);

  //     final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);
  //     updatedPosts.add(Post.empty.copyWith(id: posts.last!.id));
      
  //     final likedPostIds = await _postsRepository.getLikedPostIds(
  //         userId: _authBloc.state.user!.uid, posts: posts);
  //     yield state.copyWith(posts: updatedPosts, status: FeedStatus.success);
  //     _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
  //   } catch (e) {
  //     yield state.copyWith(
  //         failure: Failure(
  //             message: "dang, max messed up you're pagination code...",
  //             code: e.toString()),
  //         status: FeedStatus.error);
  //   }
  // }