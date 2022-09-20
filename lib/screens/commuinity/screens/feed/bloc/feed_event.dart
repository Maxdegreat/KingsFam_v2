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
  FeedCommuinityFetchPosts({required this.commuinityId, required this.lastPostId});
} 

class CommunityFeedPaginatePost extends FeedEvent {
  final String commuinityId;
  CommunityFeedPaginatePost({required this.commuinityId});
}

class FeedPaginatePosts extends FeedEvent{}

