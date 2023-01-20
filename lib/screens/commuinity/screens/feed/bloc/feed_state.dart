part of 'feed_bloc.dart';
enum FeedStatus {inital, loading, success, paginating, error}
class FeedState extends Equatable {
  final List<Post?> posts;
  final List<Widget?> postContainer;
  final FeedStatus status;
  final Failure failure;
  final Set<String?> likedPostIds;
  final BuildContext? currContext;
  const FeedState({
    required this.posts,
    required this.postContainer,
    required this.status,
    required this.failure,
    required this.likedPostIds,
    required this.currContext,
  });

  factory FeedState.inital() =>
    FeedState(posts: [], likedPostIds: {}, postContainer: [], status: FeedStatus.inital, currContext: null, failure: Failure());

  @override
  List<Object?> get props => [posts, likedPostIds, postContainer, currContext, status, failure];

  FeedState copyWith({
    List<Post?>? posts,
    List<Widget?>? postContainer,
    Set<String?>? likedPostIds,
    FeedStatus? status,
    Failure? failure,
    BuildContext? currContext,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      postContainer: postContainer ?? this.postContainer,
      status: status ?? this.status,
      failure: failure ?? this.failure,
      likedPostIds: likedPostIds ?? this.likedPostIds,
      currContext: currContext ?? this.currContext,
    );
  }
}
