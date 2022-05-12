part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class CommentFetchComments extends CommentEvent {
  final Post? post;
  List<Object?> get props => [post];
  CommentFetchComments({required this.post});
}

class CommentUpdateComments extends CommentEvent {
  final List<Comment?> comments;
  CommentUpdateComments({required this.comments});
  @override
  List<Object?> get props => [comments];
}

class CommentPostComment extends CommentEvent {
  final String content;
  CommentPostComment({required this.content});
  @override
  List<Object?> get props => [content];
}

