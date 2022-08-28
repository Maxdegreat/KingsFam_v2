part of 'follow_cubit.dart';

class FollowState extends Equatable {
  List<Userr> following;
  List<Userr> followers;

  FollowState({required this.followers, required this.following});

  @override
  List<Object> get props => [followers, following];

  FollowState copyWith({
    List<Userr>? following,
    List<Userr>? followers,
  }) {
    return FollowState(
      following: following ?? this.following,
      followers: followers ?? this.followers,
    );
  }

  factory FollowState.inital() => FollowState(followers: [], following: []);
}
