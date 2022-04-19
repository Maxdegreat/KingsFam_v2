import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserrRepository _userrRepository;
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;
  final LikedPostCubit _likedPostCubit;

  StreamSubscription<List<Future<Post?>>>? _postStreamSubscription;

  ProfileBloc({
    required UserrRepository userrRepository,
    required AuthBloc authBloc,
    required PostsRepository postRepository,
    required LikedPostCubit likedPostCubit,
  })  : _userrRepository = userrRepository,
        _authBloc = authBloc,
        _postsRepository = postRepository,
        _likedPostCubit = likedPostCubit,
        super(ProfileState.initial());

  @override
  Future<void> close() {
    _postStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileLoadUserr) {
      yield* _mapProfileLoadUserToState(event);
    } else if (event is ProfilePaginatePosts) {
      yield* _mapProfilePaginatePosts();
    } else if (event is ProfileUpdatePost) {
      yield* _mapProfileUpdatePostsToState(event);
    } else if (event is ProfileFollowUserr) {
      yield* _mapProfileFollowUserToState();
    } else if (event is ProfileUnfollowUserr) {
      yield* _mapProfileUnfollowUserrToState();
    }
  }

  Stream<ProfileState> _mapProfilePaginatePosts() async* {
    print("the len of pots list is: ${state.post.length}");
    print("post have been updated");
    yield state.copyWith(status: ProfileStatus.paginating);
    try {
       // get last post id to start paginating from here
      String? lastPostId = state.post.isNotEmpty ? state.post.last!.id : null;
      // get the new batch
      print("len of last post is: $lastPostId");
      final posts = await _postsRepository.getUserFeed(userId: _authBloc.state.user!.uid, lastPostId: lastPostId);
      // add the new batch to the state.posts lists
      print("len of get user feed is: ${posts.length}");
      final updatedPosts = List<Post?>.from(state.post)..addAll(posts);

      // get the posts that we have liked
      final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: posts);
      // updates the liked posts from liked post cuit instance???
      _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
      
      yield state.copyWith(post: updatedPosts, status: ProfileStatus.loaded);
    } catch (e) {
       state.copyWith(status: ProfileStatus.error, failure: Failure(message: 'hmmm, check ur connection fam '));
    }
    print("the len of pots list is: ${state.post.length}");
  }

  Stream<ProfileState> _mapProfileLoadUserToState(
      ProfileLoadUserr event) async* {
    yield state.copyWith(status: ProfileStatus.loading);
    try {
      
      final userr = await _userrRepository.getUserrWithId(userrId: event.userId);
      
      final isCurrentUser = _authBloc.state.user!.uid == event.userId;

      final isFollowing = await _userrRepository.isFollowing(userrId: _authBloc.state.user!.uid, otherUserId: event.userId);

      // whenever a new post is posted it will update the home page post view
      _postStreamSubscription?.cancel();
      _postStreamSubscription = _postsRepository
          // HEY I LIMITED THIS TO 8 POSTS ============================================================== jk add this later
        .getUserPosts(userId: event.userId).listen((posts) async {
        final allPost = await Future.wait(posts);
        add(ProfileUpdatePost(post: allPost));
      });

      yield state.copyWith(
          userr: userr,
          isCurrentUserr: isCurrentUser,
          isFollowing: isFollowing,
          status: ProfileStatus.loaded);
    } /*on PlatformException*/ catch (e) {
      yield state.copyWith(
          status: ProfileStatus.error, failure: Failure( code: 'the error code is $e', message: e.toString()//'hmm, unable to load this profile. Check your connection.'
            ));
          print("The error is: $e ");
          print(state.failure.code);
    }
  }



  Stream<ProfileState> _mapProfileUpdatePostsToState( ProfileUpdatePost event) async* {
    yield state.copyWith(post: event.post);
    final likedPostIds = await _postsRepository.getLikedPostIds(userId: _authBloc.state.user!.uid, posts: event.post);
    _likedPostCubit.updateLikedPosts(postIds: likedPostIds);
  }


  Stream<ProfileState> _mapProfileFollowUserToState() async* {
    try {
      _userrRepository.followerUserr(userrId: _authBloc.state.user!.uid, followersId: state.userr.id);
      final updatedUserr = state.userr.copyWith(followers: state.userr.followers + 1);
      yield state.copyWith(userr: updatedUserr, isFollowing: true);
    } catch (error) {
      state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(message: 'hmmm, check ur connection fam '));
    }
  }

  Stream<ProfileState> _mapProfileUnfollowUserrToState() async* {
    try {
      _userrRepository.unFollowUserr(userrId: _authBloc.state.user!.uid, unFollowedUserr: state.userr.id);
      final updatedUserr = state.userr.copyWith(followers: state.userr.followers + -1);
      yield state.copyWith(userr: updatedUserr, isFollowing: false);
    } catch (error) {
      state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(message: 'hmmm, check ur connection fam '));
    }
  }
}
