part of 'comment_bloc.dart';
enum CommentStatus {inital, loading, success, paginating, error}
abstract class CommentState extends Equatable {
  const CommentState();
}

class CommentInital extends CommentState {
  const CommentInital();
  @override
  List<Object?> get props => [];
}

class CommentLoading extends CommentState {
  const CommentLoading();

  @override
  List<Object?> get props => [];
  
}

class CommentLoaded extends CommentState {
  final Post? post;
  final List<Comment?> comments;
  const CommentLoaded({required this.post, required this.comments});
  @override
  List<Object?> get props => [post, comments];
}

class CommentError extends CommentState {
  final Failure failure;
  const CommentError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
