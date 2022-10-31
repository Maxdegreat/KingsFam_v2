part of 'commuinity_bloc.dart';

abstract class CommuinityEvent extends Equatable {
  const CommuinityEvent();

  @override
  List<Object?> get props => [];
}

class CommunityInitalEvent extends CommuinityEvent {
  final Church commuinity;
  CommunityInitalEvent({required this.commuinity});
  @override

  List<Object?> get props => [commuinity];
}

class CommunityLoadingPosts extends CommuinityEvent {
  final Church cm;
  const CommunityLoadingPosts({required this.cm});
  @override
  // TODO: implement props
  List<Object?> get props => [cm];
}

class CommunityLoadingEvents extends CommuinityEvent {
  final Church cm;
  const CommunityLoadingEvents({required this.cm});
  @override
  // TODO: implement props
  List<Object?> get props => [cm];
}

class CommunityLoadingCords extends CommuinityEvent {
  final Church commuinity;

  CommunityLoadingCords({required this.commuinity});

  @override
  List<Object> get props => [commuinity]; 
}

class CommuinityLoadedEvent extends CommuinityEvent {
  final List<KingsCord?> kcs;
  final List<Post?> posts;
  final Church commuinity;
  CommuinityLoadedEvent({
    required this.kcs,
    required this.posts,
    required this.commuinity
  });
  @override
  List<Object> get props => [kcs, posts, commuinity];
}


