part of 'comment_bloc.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class CommentFtechComments extends CommentEvent{
  final Post? post;
  CommentFtechComments({
    required this.post,
  });

  // @override
  
  // List<Object?> get props => [post]; 

}

class CommentUpdateComments extends CommentEvent {
  final List<Comment?> comments;
  final Post? post;
  CommentUpdateComments({
    required this.comments,
    required this.post,
  });

  // @override
 
  // List<Object?> get props => [comments];
}

class CommentPostComment extends CommentEvent {
  final String content;
  final Post? post;

  CommentPostComment({required this.content, required this.post});
  // List<Object?> get props => [content];
  
}
