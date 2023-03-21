import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/prayer_modal.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:video_player/video_player.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserrRepository _userrRepository;
  final PostsRepository _postsRepository;
  final AuthBloc _authBloc;
  final LikedPostCubit _likedPostCubit;
  final ChurchRepository _churchRepository;
  final PrayerRepo _prayerRepo;

  // <List<Future<Post?>>>? _postStreamSubscription;

  ProfileBloc(
      {required UserrRepository userrRepository,
      required AuthBloc authBloc,
      required PostsRepository postRepository,
      required LikedPostCubit likedPostCubit,
      required ChurchRepository churchRepository,
      required PrayerRepo prayerRepo})
      : _userrRepository = userrRepository,
        _authBloc = authBloc,
        _postsRepository = postRepository,
        _likedPostCubit = likedPostCubit,
        _churchRepository = churchRepository,
        _prayerRepo = prayerRepo,
        super(ProfileState.initial());

  @override
  Future<void> close() {
    // _postStreamSubscription!.cancel();
    return super.close();
  }

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is ProfileLoadUserOnly) {
      yield* _loadUserOnlyToState(event);
    } else if (event is ProfileLoadUserr) {
      yield* _mapProfileLoadUserToState(event);
    }
    // else if (event is ProfilePaginatePosts) {
    //  yield* _mapProfilePaginatePosts();
    //}
    else if (event is ProfilePaginatePosts) {
      yield* _mapProfilePaginatePost(event);
    } else if (event is ProfileUpdatePost) {
      yield* _mapProfileUpdatePostsToState(event);
    } else if (event is ProfileFollowUserr) {
      yield* _mapProfileFollowUserToState();
    } else if (event is ProfileUnfollowUserr) {
      yield* _mapProfileUnfollowUserrToState();
    } else if (event is ProfileUpdateShowPost) {
      yield* _mapProfileShowPostsTosState();
    } else if (event is ProfileLikePost) {
      yield* _mapLikePostToState(event);
    }
    // else if (event is ProfileDm) {
    //   yield* _mapProfileDmToState(event);
    // }
    else if (event is ProfileLoadFollowersUsers) {
      yield* _mapProfileLoadFollowersUsersToState(event);
    } else if (event is ProfileLoadFollowingUsers) {
      yield* _mapProfileLoadFollowingUsersToState(event);
    } else if (event is ProfileUpdateUserr) {
      yield* _mapNewUserToState(event);
    }
  }

  // quick methods
  Stream<ProfileState> _mapNewUserToState(ProfileUpdateUserr event) async* {
    final userr = await _userrRepository.getUserrWithId(userrId: event.usrId);
    yield state.copyWith(userr: userr);
  }

  Stream<ProfileState> _mapLikePostToState(ProfileLikePost event) async* {
    try {
      _likedPostCubit.likePost(post: event.lkedPost);
      Set<String?> likeSet = Set<String?>.from(state.likedPostIds)
        ..add(event.lkedPost.id);
      yield state.copyWith(likedPostIds: likeSet);
    } catch (e) {
      print(
          "error in profilebloc _mapLikePostToState, ecode: ${e.toString()})");
    }
  }

  Stream<ProfileState> _mapProfileShowPostsTosState() async* {
    yield state.copyWith(showPost: true);
  }

  //TODO FOR OPTIMIZE YOU CAN MAKE A SET. IF LASTPOSTID HAS BEEN SEEN THEN DO NOT EVEN ENTER FUNCTIONS THAT WILL DO READS.
  Stream<ProfileState> _mapProfilePaginatePost(
      ProfilePaginatePosts event) async* {
    yield state.copyWith(status: ProfileStatus.paginating);
    try {
      
      final lastPostId = state.post.isNotEmpty ? state.post.last!.id : null;
      var lastPostDoc = await _postsRepository.getUserPostHelper(
          userId: event.userId, lastPostId: lastPostId);
      if (lastPostDoc != null && !lastPostDoc.exists) return;
      if (lastPostDoc != null && lastPostDoc.exists) {
        // we want to grab some 2 post and pass them onto the users post.
        List<Post?> lst = await _postsRepository.getUserPosts(
            userId: event.userId, limit: 2, lastPostDoc: lastPostDoc);

        add(ProfileUpdatePost(post: lst));

        print("got new posts");
      }
      yield state.copyWith(status: ProfileStatus.loaded);
    } catch (e) {
      print(
          "There was an error. location ProfileBloc paginatePosts. code: ${e.toString()}");
    }
  }

  Stream<ProfileState> _loadUserOnlyToState(ProfileLoadUserOnly event) async* {
    log("we in");
    Userr userr = await _userrRepository.getUserrWithId(userrId: event.userId);
    yield state.copyWith(userr: userr);
    log("user is: " + state.userr.toString());
  }

  Stream<ProfileState> _mapProfileLoadUserToState(
      ProfileLoadUserr event) async* {
    yield ProfileState.initial();
    yield state.copyWith(status: ProfileStatus.loading, loadingPost: true);

    try {
      final userr = await _userrRepository.getUserrWithId(userrId: event.userId);
      yield state.copyWith(userr: userr);

      // grab any potential prayers

      List<PrayerModal> pm = await _prayerRepo.getUsrsPrayers(usrId: event.userId, limit: 1);

      if (pm.isNotEmpty) {
        yield (state.copyWith(prayer: pm[0].prayer));
      }

      final isCurrentUser = _authBloc.state.user!.uid == event.userId;

      final isFollowing = await _userrRepository.isFollowing(
          userrId: _authBloc.state.user!.uid, otherUserId: event.userId);

      final cms = await _churchRepository.getCommuinitysUserIn(
          userrId: event.userId, limit: 2);
      Set<String> seen = state.seen;
      var beenSeen = state.post.length > 0 ? state.post.last : null;
      // log("seen id's: $seen");
      // whenever a new post is posted it will update the home page post view
      yield state.copyWith(post: []);
      List<Post?> lst = await _postsRepository.getUserPosts(
        userId: event.userId,
        limit: 3,
        lastPostDoc: null,
      );
      add(ProfileUpdatePost(post: lst));

      yield state.copyWith(
          seen: seen,
          userr: userr,
          isCurrentUserr: isCurrentUser,
          isFollowing: isFollowing,
          cms: cms,
          status: ProfileStatus.loaded,
          loadingPost: false);
    } /*on PlatformException*/ catch (e) {
      yield state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(
              code: 'the error code is $e',
              message: e
                  .toString() //'hmm, unable to load this profile. Check your connection.'
              ));
      print("The error is: $e ");
      print(state.failure.code);
    }
  }

  Stream<ProfileState> _mapProfileUpdatePostsToState(
      ProfileUpdatePost event) async* {
    yield state.copyWith(status: ProfileStatus.loadingSingleView);
    print("IN the update posts repo");
    final likedPostIds = await _postsRepository.getLikedPostIds(
        userId: _authBloc.state.user!.uid, posts: event.post);
    List<Post?> posts;
    posts = List<Post?>.from(state.post)..addAll(event.post);
    //_likedPostCubit.updateLikedPosts(postIds: likedPostIds);
    yield state.copyWith(
        post: posts, status: ProfileStatus.loaded, likedPostIds: likedPostIds);
    print(
        "____________________________________________________________________________________________________");
  }

  Stream<ProfileState> _mapProfileFollowUserToState() async* {
    try {
      _userrRepository.followerUserr(
          userr: state.userr, followersId: _authBloc.state.user!.uid);
      final updatedUserr =
          state.userr.copyWith(followers: state.userr.followers + 1);
      yield state.copyWith(userr: updatedUserr, isFollowing: true);
    } catch (error) {
      state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(message: 'hmmm, check ur connection fam '));
    }
  }

  Stream<ProfileState> _mapProfileUnfollowUserrToState() async* {
    try {
      _userrRepository.unFollowUserr(
          userrId: state.userr.id, unFollowingUser: _authBloc.state.user!.uid);
      final updatedUserr =
          state.userr.copyWith(followers: state.userr.followers + -1);
      yield state.copyWith(userr: updatedUserr, isFollowing: false);
    } catch (error) {
      yield state.copyWith(
          status: ProfileStatus.error,
          failure: Failure(message: 'hmmm, check ur connection fam '));
    }
  }

  

  Stream<ProfileState> _mapProfileLoadFollowersUsersToState(
      ProfileLoadFollowersUsers event) async* {
    // query into curr users followers grab first 10. make to users, then yield to state
    var followersAsUsers = await _userrRepository.followerList(
        currUserId: state.userr.id, lastStringId: event.lastStringId);
    yield state.copyWith(followersUserList: followersAsUsers);
  }

  Stream<ProfileState> _mapProfileLoadFollowingUsersToState(
      ProfileLoadFollowingUsers event) async* {
    var id = state.userr.id == null ? event.id : state.userr.id;
    log("The id is: " + id.toString());
    var followingAsUsers = await _userrRepository.followingList(
        currUserId: state.userr.id, lastStringId: event.lastStringId);
    log("The len of the list is now " + followingAsUsers.length.toString());
    yield state.copyWith(followingUserList: followingAsUsers);
  }
}
