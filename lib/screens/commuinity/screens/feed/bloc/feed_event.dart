part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedFetchPosts extends FeedEvent {
  final BuildContext? context;
  final String? lastPostId;
  const FeedFetchPosts({required this.context, this.lastPostId});
}

class FeedPaginatePosts extends FeedEvent {}

class FeedCommuinityFetchPosts extends FeedEvent {
  final String commuinityId;
  final String? lastPostId;
  final List<Post>? passedPost;
  final BuildContext? context;
  FeedCommuinityFetchPosts(
      {required this.commuinityId,
      required this.lastPostId,
      required this.passedPost,
      this.context});
}

class CommunityFeedPaginatePost extends FeedEvent {
  final String commuinityId;
  CommunityFeedPaginatePost({required this.commuinityId});
}
