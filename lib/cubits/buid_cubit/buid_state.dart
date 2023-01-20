part of 'buid_cubit.dart';

class BuidState extends Equatable {
  final Set<String> buids;

  const BuidState({required this.buids});

  @override
  List<Object> get props => [buids];

  BuidState copyWith({
    Set<String>? buids,
  }) {
    return BuidState(buids: buids ?? this.buids);
  }

  factory BuidState.inital() {
    return BuidState(buids: {});
  }

}
