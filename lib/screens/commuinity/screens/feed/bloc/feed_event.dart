part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class FeedFetchPosts extends FeedEvent {}

class FeedCommuinityFetchPosts extends FeedEvent {
  final String commuinityId;
  FeedCommuinityFetchPosts({required this.commuinityId});
}

class FeedPaginatePosts extends FeedEvent{}

class FeedLikePost extends FeedEvent{
  final Post lkedPost;
  const FeedLikePost({required this.lkedPost});
}