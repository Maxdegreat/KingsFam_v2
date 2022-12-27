import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Snack extends Equatable {
    final String? id;
    final int? snackBar;
    final int? chips;
    final int? fruitBowl;
    final int? milkPizza;
    Snack({this.id, this.snackBar, this.chips, this.fruitBowl, this.milkPizza});
    

  @override
  List<Object?> get props => throw [snackBar, chips, fruitBowl];

  factory Snack.empty() => Snack();

  Snack copyWith({
    String? id,
    int? snackBar,
    int? chips,
    int? fruitBowl,
    int? milkPizza,
  }) {
    return Snack(
      id: id ?? this.id,
      snackBar: snackBar ?? this.snackBar,
      chips: chips ?? this.chips,
      fruitBowl: fruitBowl ?? this.fruitBowl,
      milkPizza: milkPizza ?? this.milkPizza,
    );
  }
  
  Map<String, dynamic> toDoc() {
    return {
      "snacks" : {
        "snackBar" : snackBar ?? 0,
        "chips" : chips ?? 0,
        "fruitBowl" : fruitBowl ?? 0, 
        "milkPizza" : milkPizza  ?? 0
      }
    };
  }

  static Snack fromDoc(DocumentSnapshot docSnap) {
    final data = docSnap.data() as Map<String, dynamic>;
    return Snack(
      id: docSnap.id,
      snackBar: data["snackBar"] ?? 0,
      chips: docSnap["chips"] ?? 0,
      fruitBowl: docSnap["fruitBowl"] ?? 0,
      milkPizza: docSnap["milkPizza"] ?? 0,
    );

  }
}
