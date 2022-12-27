part of 'perk_cubit.dart';

enum PerkStatus { init, loading, pag, error }

class PerkState extends Equatable {
  final PerkStatus status;
  final int kfcHoldings;

  const PerkState({required this.status, required this.kfcHoldings});

  factory PerkState.initial() =>
      PerkState(status: PerkStatus.init, kfcHoldings: 0);

  @override
  List<Object> get props => [status, kfcHoldings];

  PerkState copyWith({
    PerkStatus? status,
    int? kfcHoldings,
  }) {
    return PerkState(
        status: status ?? this.status,
        kfcHoldings: kfcHoldings ?? this.kfcHoldings);
  }
}
