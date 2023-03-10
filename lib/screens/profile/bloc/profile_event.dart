part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadUserOnly extends ProfileEvent {
  final String userId;
  const ProfileLoadUserOnly({required this.userId});
}

class ProfileLoadUserr extends ProfileEvent {
  final String userId;
  final VideoPlayerController? vidCtrl;
  ProfileLoadUserr({
    required this.userId,
    this.vidCtrl,
  });

  @override
  List<Object?> get props => [userId, vidCtrl];
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

class ProfileListenForNewPost extends ProfileEvent {
  final String userId;
  ProfileListenForNewPost({required this.userId});
  @override
  // TODO: implement props
  List<Object?> get props => [userId];
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
  final String? id; // id of person whos followers are being loaded
  ProfileLoadFollowersUsers({required this.lastStringId, required this.id}) ;
  @override
  List<Object?> get props => [lastStringId, id];
}

class ProfileLoadFollowingUsers extends ProfileEvent {
    final String? lastStringId;
    final String? id; // id of person whos followers are being loaded
  ProfileLoadFollowingUsers({required this.lastStringId, required this.id}) ;
  @override
  List<Object?> get props => [lastStringId, id];
}

class ProfileUpdateUserr extends ProfileEvent {
  final String usrId;
  ProfileUpdateUserr({required this.usrId});
}
