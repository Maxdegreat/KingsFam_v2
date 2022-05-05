// why we use recently liked post ids
// initially when a user likes a post we will incrment and add 
// user id to to recently liked posts ids and liked posts ids
// i actually still dont get it...


part of 'liked_post_cubit.dart';




class LikedPostState extends Equatable {
  final Set<String?> likedPostsIds;
  final bool isLiked;
  // final Set<String> recentlyLikedPostIds;
  const LikedPostState({required this.likedPostsIds, required this.isLiked});

  @override
  List<Object> get props => [likedPostsIds, isLiked];

  LikedPostState copyWith({
    Set<String?>? likedPostsIds,
    bool? isLiked,
  }) {
    return LikedPostState(
      likedPostsIds: likedPostsIds ?? this.likedPostsIds,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory LikedPostState.initial() {
    return LikedPostState(
      isLiked: false,
      likedPostsIds: {});
  }
}


