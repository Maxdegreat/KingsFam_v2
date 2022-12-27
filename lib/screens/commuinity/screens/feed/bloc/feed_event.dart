part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedFetchPosts extends FeedEvent {}

class FeedCommuinityFetchPosts extends FeedEvent {
  final String commuinityId;
  final String? lastPostId;
  final List<Post>? passedPost;
  FeedCommuinityFetchPosts(
      {required this.commuinityId, required this.lastPostId, required this.passedPost});
}

class CommunityFeedPaginatePost extends FeedEvent {
  final String commuinityId;
  CommunityFeedPaginatePost({required this.commuinityId});
}

class FeedPaginatePosts extends FeedEvent {}
