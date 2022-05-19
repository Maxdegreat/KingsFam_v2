part of 'profile_bloc.dart';

enum ProfileStatus { initial, loadingSingleView, loading,  loaded, paginating, error }

class ProfileState extends Equatable {
  // step 1  class data
  final Userr userr;
  final List<Post?> post;
  final Set<String?> likedPostIds;
  final Set<String> seen;
  final bool isCurrentUserr;
  final bool showPost;
  final bool isFollowing;
  final ProfileStatus status;
  final Failure failure;
  final List<Church?> cms;
  // step 2 make the constructor
  ProfileState({
    required this.post,
    required this.showPost,
    required this.seen,
    required this.likedPostIds,
    required this.userr,
    required this.isCurrentUserr,
    required this.isFollowing,
    required this.status,
    required this.failure,
    required this.cms
  });

  //step 5 make the initial state
  factory ProfileState.initial() {
    return ProfileState(
        post: [],
        showPost: false,
        userr: Userr.empty,
        seen: {},
        isCurrentUserr: false,
        isFollowing: false,
        status: ProfileStatus.initial,
        likedPostIds: {},
        failure: Failure(),
        cms: [],
      );
  }
  // step 3 make the props
  @override
  List<Object?> get props =>
      [post, userr, isCurrentUserr, seen, isFollowing, status, failure, showPost, cms];

  // step 4 make the copy with
  ProfileState copyWith({
    List<Post?>? post,
    bool? showPost,
    Userr? userr,
    bool? isCurrentUserr,
    bool? isFollowing,
    Set<String>? seen,
    ProfileStatus? status,
    Set<String?>? likedPostIds,
    Failure? failure,
    List<Church?>? cms,
  }) {
    return ProfileState(
      post: post ?? this.post,
      showPost: showPost ?? this.showPost,
      userr: userr ?? this.userr,
      seen: seen ?? this.seen,
      isCurrentUserr: isCurrentUserr ?? this.isCurrentUserr,
      isFollowing: isFollowing ?? this.isFollowing,
      status: status ?? this.status,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      failure: failure ?? this.failure,
      cms: cms ?? this.cms
    );
  }
}
