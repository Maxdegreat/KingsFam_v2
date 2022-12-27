part of 'liked_says_cubit.dart';

class LikedSaysState extends Equatable {
  final Set<String?> likedSaysIds;
  final Set<String?> localLikedSaysIds;

  const LikedSaysState(
      {required this.likedSaysIds, required this.localLikedSaysIds});

  @override
  List<Object> get props => [likedSaysIds, localLikedSaysIds];

  LikedSaysState copyWith({
    Set<String?>? likedSaysIds,
    Set<String?>? localLikedSaysIds,
  }) {
    return LikedSaysState(
        likedSaysIds: likedSaysIds ?? this.likedSaysIds,
        localLikedSaysIds: localLikedSaysIds ?? this.localLikedSaysIds);
  }

  factory LikedSaysState.inital() {
    return LikedSaysState(
      likedSaysIds: {},
      localLikedSaysIds: {},
    );
  }
}
