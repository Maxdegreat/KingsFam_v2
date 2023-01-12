part of 'vc_bloc.dart';

abstract class VcEvent extends Equatable {
  const VcEvent();

  @override
  List<Object> get props => [];
}

class VcInit extends VcEvent {
  final String cmId;
  final String kcId;
  const VcInit({required this.cmId, required this.kcId});
}

class VcEventUserJoined extends VcEvent {
  final Userr userr;
  final String cmId;
  final String kcId;
  const VcEventUserJoined({required this.cmId, required this.kcId, required this.userr});
}

class VcEventUserLeft extends VcEvent {
  final Userr userr;
  final String cmId;
  final String kcId;
  const VcEventUserLeft({required this.cmId, required this.kcId, required this.userr});
}