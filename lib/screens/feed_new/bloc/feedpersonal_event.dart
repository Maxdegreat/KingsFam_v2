part of 'feedpersonal_bloc.dart';

abstract class FeedpersonalEvent extends Equatable {
  const FeedpersonalEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadPostsInit extends FeedpersonalEvent{
  final List<Post?> posts;
  final int currIdx;
  @override
  List<Object?> get props => [currIdx, posts];
  const FeedLoadPostsInit({required this.posts, required this.currIdx});
}

// only goal of class below is to set the state of jupto to true
class FeedJumpTo extends FeedpersonalEvent {}

class FeedPersonalPaginatePosts extends FeedpersonalEvent{}