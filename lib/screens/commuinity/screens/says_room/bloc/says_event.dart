part of 'says_bloc.dart';

abstract class SaysEvent extends Equatable {
  const SaysEvent();

  @override
  List<Object> get props => [];
}

class SaysFetchSays extends SaysEvent {
  final String cmId;
  final String kcId;
  const SaysFetchSays({required this.cmId, required this.kcId});
  @override
  List<Object> get props => [cmId, kcId];
}
