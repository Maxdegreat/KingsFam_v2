part of 'commuinity_bloc.dart';

abstract class CommuinityEvent extends Equatable {
  const CommuinityEvent();

  @override
  List<Object?> get props => [];
}

class CommuinityLoadCommuinity extends CommuinityEvent {
  final Church commuinity;
  final VideoPlayerController? vidCtrl;
  CommuinityLoadCommuinity({required this.commuinity, this.vidCtrl});
  @override

  List<Object?> get props => [commuinity, vidCtrl];
}

class ComuinityLoadingCords extends CommuinityEvent {
  final List<KingsCord?> cords;
  final Church commuinity;

  ComuinityLoadingCords({required this.cords, required this.commuinity});
  @override
  List<Object> get props => [cords]; 
}

class CommuinityLoadedEvent extends CommuinityEvent {
  final List<KingsCord?> kcs;
  final List<CallModel> calls;
  final List<Post?> posts;
  final Church commuinity;
  CommuinityLoadedEvent({
    required this.kcs,
    required this.calls,
    required this.posts,
    required this.commuinity
  });
  @override
  List<Object> get props => [kcs, calls, posts, commuinity];
}


