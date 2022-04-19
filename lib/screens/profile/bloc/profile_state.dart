part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, paginating, error }

class ProfileState extends Equatable {
  // step 1  class data
  final Userr userr;
  final List<Post?> post;
  //final List<Chat> chat;
  final bool isCurrentUserr;
  final bool isGridView;
  final bool isFollowing;
  final ProfileStatus status;
  final Failure failure;
  // step 2 make the constructor
  ProfileState({
    required this.post,
    required this.isGridView,
    required this.userr,
    required this.isCurrentUserr,
    required this.isFollowing,
    required this.status,
    required this.failure,
  });

  //step 5 make the initial state
  factory ProfileState.initial() {
    return ProfileState(
        post: [],
        isGridView: true,
        userr: Userr.empty,
        isCurrentUserr: false,
        isFollowing: false,
        status: ProfileStatus.initial,
        failure: Failure());
  }
  // step 3 make the props
  @override
  List<Object?> get props =>
      [post, userr, isCurrentUserr, isFollowing, status, failure, isGridView];

  // step 4 make the copy with
  ProfileState copyWith({
    List<Post?>? post,
    bool? isGridView,
    Userr? userr,
    bool? isCurrentUserr,
    bool? isFollowing,
    ProfileStatus? status,
    Failure? failure,
  }) {
    return ProfileState(
      post: post ?? this.post,
      isGridView: isGridView ?? this.isGridView,
      userr: userr ?? this.userr,
      isCurrentUserr: isCurrentUserr ?? this.isCurrentUserr,
      isFollowing: isFollowing ?? this.isFollowing,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
