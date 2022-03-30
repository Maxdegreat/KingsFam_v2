part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadUserr extends ProfileEvent {
  final String userId;
  ProfileLoadUserr({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class ProfileToggelGridView extends ProfileEvent {
  final bool isGridView;

  ProfileToggelGridView({
    required this.isGridView,
  });

  @override
  List<Object> get props => [isGridView]; //               ?
}

class ProfileUpdatePost extends ProfileEvent {
  final List<Post?> post;
  ProfileUpdatePost({
    required this.post,
  });

  @override
  List<Object?> get props => [post];
}

class ProfileFollowUserr extends ProfileEvent {}

class ProfileUnfollowUserr extends ProfileEvent {}
