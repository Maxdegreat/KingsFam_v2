import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PerkModal extends Equatable {
  final List<String> ownedTPs;
  final String? selectedTp;
  final Map<String, dynamic> walet;

  PerkModal(
      {required this.ownedTPs, required this.selectedTp, required this.walet});

  @override
  List<Object?> get props => [ownedTPs, null, walet];

  static PerkModal empty = PerkModal(ownedTPs: [], selectedTp: null, walet: {});

  PerkModal copyWith(
    List<String>? ownedTPs,
    String? selectedTp,
    Map<String, dynamic>? walet,
  ) {
    return PerkModal(
        ownedTPs: ownedTPs ?? this.ownedTPs,
        selectedTp: selectedTp ?? this.selectedTp,
        walet: walet ?? this.walet);
  }

  Map<String, dynamic> toDoc() {
    return {
      'ownedTPs': ownedTPs,
      'selectedTp': selectedTp,
      'walet': walet,
    };
  }

  static PerkModal fromDoc (DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PerkModal(
      ownedTPs: List<String>.from(data['ownedTPs']), 
      selectedTp: data['selectedTp'], 
      walet: Map<String, dynamic>.from(data['walet'])
    );
  }
}