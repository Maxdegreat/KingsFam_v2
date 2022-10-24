part of 'says_bloc.dart';

enum SaysStatus { success, failure, loading, inital }

class SaysState extends Equatable {
  final SaysStatus status;
  final Failure failure;
  final Set<String> likedPosts;
  final List<Says?> says;
  SaysState({
    required this.failure,
    required this.likedPosts,
    required this.status,
    required this.says,
  });
  factory SaysState.inital() {
    return SaysState(
        failure: Failure(), likedPosts: {}, status: SaysStatus.inital, says: []);
  }

  @override
  List<Object> get props => [status, failure, likedPosts, says];

  SaysState copyWith({
    SaysStatus? status,
    Failure? failure,
    Set<String>? likedPosts,
    List<Says?>? says,
  }) {
    return SaysState(
        failure: failure ?? this.failure,
        likedPosts: likedPosts ?? this.likedPosts,
        status: status ?? this.status,
        says: says ?? this.says);
  }
}
