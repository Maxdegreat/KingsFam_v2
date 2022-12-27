part of 'comment_bloc.dart';

enum CommentStatus { inital, loading, success, paginating, error }

class CommentState extends Equatable {
  final CommentStatus status;
  final Failure failure;
  final bool isReplys;
  final Map<String, List<Comment?>> replys; // top comment id, reply comments
  final List<Comment?> comments;
  final Post post;

  CommentState(
      {required this.status,
      required this.failure,
      required this.isReplys,
      required this.replys,
      required this.comments,
      required this.post});

  @override
  // TODO: implement props
  List<Object?> get props => [
        status,
        failure,
        isReplys,
        replys,
        comments,
        post,

      ];

  factory CommentState.inital() => CommentState(
      status: CommentStatus.inital,
      failure: Failure(),
      isReplys: false,
      replys: {},
      comments: [],
      post: Post.empty);

  CommentState CopyWith({
    CommentStatus? status,
    Failure? failure,
    bool? isReplys,
    Map<String, List<Comment?>>? replys,
    List<Comment?>? comments,
    Post? post,
  }) {
    return CommentState(
        status: status ?? this.status,
        failure: failure ?? this.failure,
        isReplys: isReplys ?? this.isReplys,
        replys: replys ?? this.replys,
        comments: comments ?? this.comments,
        post: post ?? this.post);
  }
}
