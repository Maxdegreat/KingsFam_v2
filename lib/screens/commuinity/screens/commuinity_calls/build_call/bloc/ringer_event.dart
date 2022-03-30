part of 'ringer_bloc.dart';

abstract class RingerEvent extends Equatable {
  const RingerEvent();

  @override
  List<Object?> get props => [];
}

class RingerUpdateRings extends RingerEvent {
  final List<CallModel> rings;

  const RingerUpdateRings({required this.rings});

  @override
  List<Object?> get props => [rings];
}
