part of 'feedpersonal_bloc.dart';
enum FeedPersonalStatus {inital, loading, paginating, success, error}
class FeedpersonalState extends Equatable {
  final List<Post?> posts;
  final int? startingIdx;
  final Failure failure;
  final FeedPersonalStatus status;

  FeedpersonalState({ required this.posts, required this.startingIdx, required this.failure, required this.status});

  factory FeedpersonalState.inital() =>
    FeedpersonalState(posts: [], failure: Failure(), status: FeedPersonalStatus.inital, startingIdx: null);
  
  @override
  List<Object> get props => [posts, failure, status];

  FeedpersonalState copyWith({
    List<Post?>? posts,
    Failure? failure,
    FeedPersonalStatus? status,
    int? startingIdx,
  }) {
    return FeedpersonalState(
      posts: posts ?? this.posts,
      failure: failure ?? this.failure,
      status: status ?? this.status, 
      startingIdx: startingIdx ?? this.startingIdx,
    );
  }
}
