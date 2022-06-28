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

class ProfilePaginatePosts extends ProfileEvent {
  final String userId;
  const ProfilePaginatePosts({required this.userId});
}



class ProfileUpdatePost extends ProfileEvent {
  final List<Post?> post;
  ProfileUpdatePost({
    required this.post,
  });

  @override
  List<Object?> get props => [post];
}

class ProfileLikePost extends ProfileEvent{
  final Post lkedPost;
  const ProfileLikePost({required this.lkedPost});
}

class ProfileFollowUserr extends ProfileEvent {}

class ProfileUnfollowUserr extends ProfileEvent {}

class ProfileUpdateShowPost extends ProfileEvent {}

class ProfileDm extends ProfileEvent {
  final String profileOwnersId;
  final BuildContext ctx;
  ProfileDm({required this.profileOwnersId, required this.ctx});
  @override
  // TODO: implement props
  List<Object?> get props => [ profileOwnersId, ctx];
}

class ProfileLoadFollowersUsers extends ProfileEvent {
  final String? lastStringId;
  ProfileLoadFollowersUsers({required this.lastStringId}) ;
  @override
  List<Object?> get props => [lastStringId];
}

class ProfileLoadFollowingUsers extends ProfileEvent {
    final String? lastStringId;
  ProfileLoadFollowingUsers({required this.lastStringId}) ;
  @override
  List<Object?> get props => [lastStringId];
}
