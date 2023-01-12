part of 'vc_bloc.dart';

class VcState extends Equatable {
  final List<Userr> participants;

  const VcState({
    required this.participants,
  });

  static VcState inital() => 
    VcState(participants: []);
  
  @override
  List<Object> get props => [participants];

  VcState copyWith({
    List<Userr>? participants,
  }) => VcState(participants: participants ?? this.participants);
}

