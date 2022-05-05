part of 'feed_bloc.dart';
enum FeedStatus {inital, loading, success, paginating, error}
class FeedState extends Equatable {
  final List<Post?>? posts;
  final FeedStatus status;
  final Failure failure;
  final Set<String?> likedPostIds;
  const FeedState({
    required this.posts,
    required this.status,
    required this.failure,
    required this.likedPostIds
  });

  factory FeedState.inital() =>
    FeedState(posts: [], likedPostIds: {}, status: FeedStatus.inital, failure: Failure());

  @override
  List<Object?> get props => [posts, likedPostIds,  status, failure];

  FeedState copyWith({
    List<Post?>? posts,
    Set<String?>? likedPostIds,
    FeedStatus? status,
    Failure? failure,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      status: status ?? this.status,
      failure: failure ?? this.failure,
      likedPostIds: likedPostIds ?? this.likedPostIds
    );
  }
}
