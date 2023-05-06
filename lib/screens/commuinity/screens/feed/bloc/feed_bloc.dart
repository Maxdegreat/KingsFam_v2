import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/mock_flag.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/mock_post_data.dart';
import 'package:kingsfam/widgets/hide_content/hide_content_full_screen_post.dart';
import 'package:kingsfam/widgets/post_single_view.dart';
import 'package:kingsfam/widgets/post_widgets/post_img_screen.dart';
import 'package:kingsfam/widgets/post_widgets/post_vid_screen.dart';
import 'package:video_player/video_player.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final LikedPostCubit _likedPostCubit;
  final AuthBloc _authBloc;
  final PostsRepository _postsRepository;
  final BuidCubit _buidCubit;
  FeedBloc({
    required PostsRepository postsRepository,
    required AuthBloc authBloc,
    required LikedPostCubit likedPostCubit,
    required BuidCubit buidCubit,
  })  : _likedPostCubit = likedPostCubit,
        _authBloc = authBloc,
        _postsRepository = postsRepository,
        _buidCubit = buidCubit,
        super(FeedState.inital());

  @override
  Stream<FeedState> mapEventToState(FeedEvent event) async* {
    if (event is FeedFetchPosts) {
      yield* _mapFeedFetchPostToState(event);
    } else if (event is FeedCommuinityFetchPosts) {
      yield* _mapFeedCommuinityFetchPostToState(event);
    } else if (event is FeedPaginatePosts) {
      yield* _mapFeedPaginatePosts(event);
    } else if (event is CommunityFeedPaginatePost) {
      yield* _mapCommunityFeedPaginatePosts(event);
    }
  }

  static const int PAGIATIONLIMIT = 2;

  Stream<FeedState> _mapFeedFetchPostToState(FeedFetchPosts event) async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);
    try {
      if (!MockFlag.ISMOCKTESTING) {
        List<Post?> posts = [];
        List<Widget?> postContainers = [];

        posts = await _postsRepository.getUserFeed(lastPostId: null, limit: 2);

        if (posts.length >= 2) {
          posts.add(Post.empty.copyWith(id: posts.last!.id));
          // posts.insert( 2, Post.empty );
        }

        log("context in feed state is:  " + event.context.toString());
        postContainers = _makePostContainers(posts, event.context!);
        log("made post containers");
        _likedPostCubit.clearAllLikedPosts();

        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: posts);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        yield state.copyWith(
            posts: posts,
            postContainer: postContainers,
            status: FeedStatus.success,
            likedPostIds: likedPostIds,
            currContext: event.context);
      } else {
        List<Post?> posts = MockPostData.getMockPosts2;
        // posts.add(Post.empty);
        List<Widget?> postContainers =
            _makePostContainers(posts, event.context!);
        yield state.copyWith(
            currContext: event.context,
            posts: posts,
            postContainer: postContainers,
            status: FeedStatus.success);
      }
    } catch (e) {}
  }

  Stream<FeedState> _mapFeedPaginatePosts(FeedPaginatePosts event) async* {
    yield state.copyWith(status: FeedStatus.paginating);

    if (!MockFlag.ISMOCKTESTING) {
      try {
        final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;
        final posts = await _postsRepository.getUserFeed(
            limit: 7, lastPostId: lastPostId);
        final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);
        updatedPosts.add(Post.empty.copyWith(id: posts.last!.id));
        final postContainers =
            _makePostContainers(updatedPosts, state.currContext!);

        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: posts);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        yield state.copyWith(
            posts: updatedPosts,
            postContainer: postContainers,
            status: FeedStatus.success);
      } catch (e) {
        yield state.copyWith(
            failure: Failure(
                message: "Aw man, something went wrong", code: e.toString()),
            status: FeedStatus.error);
      }
    } else {
      List<Post?> posts = MockPostData.getMockPosts4;
      // posts.add(Post.empty);

      List<Widget?> postContainers =
          _makePostContainers(posts, state.currContext!);

      yield state.copyWith(
          posts: posts,
          postContainer: postContainers,
          status: FeedStatus.success);
    }
  }

  Stream<FeedState> _mapFeedCommuinityFetchPostToState(
      FeedCommuinityFetchPosts event) async* {
    yield state.copyWith(posts: [], status: FeedStatus.loading);

    try {
      if (!MockFlag.ISMOCKTESTING) {
        List<Post?> posts = [];
        List<Widget?> postContainers = [];
        if (event.passedPost != null) {
          posts = event.passedPost!;
        } else {
          posts = await _postsRepository.getCommuinityFeed(
              commuinityId: event.commuinityId, lastPostId: event.lastPostId);
        }

        if (posts.length >= 2) {
          posts.add(Post.empty.copyWith(id: posts.last!.id));
          // posts.insert( 2, Post.empty );
        }
        log("context in feed state is:  " + event.context.toString());
        postContainers = _makePostContainers(posts, event.context!);
        _likedPostCubit.clearAllLikedPosts();

        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: posts);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        yield state.copyWith(
            posts: posts,
            postContainer: postContainers,
            status: FeedStatus.success,
            likedPostIds: likedPostIds,
            currContext: event.context);
      } else {
        List<Post?> posts = MockPostData.getMockPosts2;
        // posts.add(Post.empty);
        List<Widget?> postContainers =
            _makePostContainers(posts, event.context!);
        yield state.copyWith(
            currContext: event.context,
            posts: posts,
            postContainer: postContainers,
            status: FeedStatus.success);
      }
    } catch (e) {}
  }

  Stream<FeedState> _mapCommunityFeedPaginatePosts(
      CommunityFeedPaginatePost event) async* {
    yield state.copyWith(status: FeedStatus.paginating);

    if (!MockFlag.ISMOCKTESTING) {
      try {
        final lastPostId = state.posts.isNotEmpty ? state.posts.last!.id : null;

        final posts = await _postsRepository.getCommuinityFeed(
            commuinityId: event.commuinityId, lastPostId: lastPostId);
        final updatedPosts = List<Post?>.from(state.posts)..addAll(posts);
        updatedPosts.add(Post.empty.copyWith(id: posts.last!.id));
        final postContainers =
            _makePostContainers(updatedPosts, state.currContext!);

        final likedPostIds = await _postsRepository.getLikedPostIds(
            userId: _authBloc.state.user!.uid, posts: posts);
        _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
        yield state.copyWith(
            posts: updatedPosts,
            postContainer: postContainers,
            status: FeedStatus.success);
      } catch (e) {
        yield state.copyWith(
            failure: Failure(
                message: "Aw man, something went wrong", code: e.toString()),
            status: FeedStatus.error);
      }
    } else {
      List<Post?> posts = MockPostData.getMockPosts4;
      // posts.add(Post.empty);

      List<Widget?> postContainers =
          _makePostContainers(posts, state.currContext!);

      yield state.copyWith(
          posts: posts,
          postContainer: postContainers,
          status: FeedStatus.success);
    }
  }

  List<Widget> _makePostContainers(List<Post?> ps, BuildContext ctx) {
    log("we are in method");
    List<Widget> lst = [];
    var container = null;

    log("abt to start for loop");
    for (Post? p in ps) {
      if (p!.author == Userr.empty)
        container = SizedBox.shrink();
      else {
        // log("Buids " + _buidCubit.state.buids.toString());

        if (!_buidCubit.state.buids.contains(p.author.id)) {
          if (p.imageUrl != null)
            container = ImgPost1_1(post: p);
          else if (p.videoUrl != null) {
            VideoPlayerController? videoPlayerController;
            videoPlayerController =
                new VideoPlayerController.network(p.videoUrl!)
                  ..addListener(() {})
                  ..setLooping(true)
                  ..initialize().then((_) {
                    videoPlayerController!.pause();
                  });
            log("vid controller from the feed_bloc: " + videoPlayerController.toString());
            container = PostFullVideoView16_9(post: p);
          }
        } else {
          container = HideContent.postFullScreen(() {
            _buidCubit.onBlockUser(p.author.id);
            Navigator.of(ctx).pop();
          });
        }
      }
        lst.add(container);
    }
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