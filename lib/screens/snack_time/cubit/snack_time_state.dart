part of 'snack_time_cubit.dart';

class SnackTimeState extends Equatable {
  final Snack snackCart;
  final double price;


  const SnackTimeState({
    required this.price,
    required this.snackCart,
  });

  @override
  List<Object> get props => [price, snackCart];

  

  SnackTimeState copyWith({
    Snack? snackCart,
    double? price,
  }) {
    return SnackTimeState(
      snackCart: snackCart ?? this.snackCart,
      price: price ?? this.price,
    );
  }

  factory SnackTimeState.initial() {
    return SnackTimeState(price: 0.00, snackCart: Snack.empty());
  }
}
