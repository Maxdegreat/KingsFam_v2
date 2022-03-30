part of 'ringer_bloc.dart';

enum RingerStatus {initial, ringing, success, error }

class RingerState extends Equatable {
  
  final List<CallModel> call;
  final RingerStatus status;
  final Failure failure;

  const RingerState({
    required this.call,
    required this.failure,
    required this.status
  });
  
  @override
  List<Object> get props => [call, failure, status];

  factory RingerState.initial() => RingerState(call: [], failure: Failure(), status: RingerStatus.initial);

  RingerState copyWith({
    List<CallModel>? call,
    RingerStatus? status,
    Failure? failure,
  }) {
    return RingerState(
      call: call ?? this.call,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}

