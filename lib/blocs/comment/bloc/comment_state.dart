part of 'comment_bloc.dart';
enum CommentStatus {inital, loading, loaded, submitting, error}
class CommentState extends Equatable {
  final Post post;
  final List<Comment?> comments;
  final CommentStatus status;
  final Failure failure;

  CommentState({
    required this.post, 
    required this.comments, 
    required this.failure, 
    required this.status,
  });

  factory CommentState.inital() {
    return  CommentState(post: Post.empty, comments: [], failure: Failure(), status: CommentStatus.inital);
  }

  @override
  List<Object> get props => [post, comments, status, failure];


  CommentState copyWith({
    Post? post,
    List<Comment?>? comments,
    CommentStatus? status,
    Failure? failure,
  }) {
    return CommentState(
      post: post ?? this.post,
      comments: comments ?? this.comments,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}


