// why we use recently liked post ids
// initially when a user likes a post we will incrment and add 
// user id to to recently liked posts ids and liked posts ids
// i actually still dont get it...


part of 'liked_post_cubit.dart';




class LikedPostState extends Equatable {
  final Set<String> likedPostsIds;
  final Set<String> recentlyLikedPostIds;
  const LikedPostState(
      {required this.likedPostsIds, required this.recentlyLikedPostIds});

  @override
  List<Object> get props => [likedPostsIds, recentlyLikedPostIds];

  LikedPostState copyWith({
    Set<String>? likedPostsIds,
    Set<String>? recentlyLikedPostIds,
  }) {
    return LikedPostState(
      likedPostsIds: likedPostsIds ?? this.likedPostsIds,
      recentlyLikedPostIds: recentlyLikedPostIds ?? this.recentlyLikedPostIds,
    );
  }

  factory LikedPostState.initial() {
    return LikedPostState(
      likedPostsIds: {}, recentlyLikedPostIds: {});
  }
}


