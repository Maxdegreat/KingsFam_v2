import 'package:equatable/equatable.dart';

class Snack extends Equatable {
    final int? snackBar;
    final int? chips;
    final int? fruitBowl;
    Snack(this.snackBar, this.chips, this.fruitBowl);

  @override
  List<Object?> get props => throw [snackBar, chips, fruitBowl];

      
}