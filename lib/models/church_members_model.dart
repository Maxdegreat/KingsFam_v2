
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChurchMembers extends Equatable {
  final String? id;
  final List<String> ids;

  ChurchMembers({
    this.id,
    required this.ids,
  });

  @override
  List<Object?> get props => [id, ids];

  ChurchMembers copyWith({
    String? id,
    List<String>? ids,
  }) {
    return ChurchMembers(
      id: id ?? this.id,
      ids: ids ?? this.ids,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'memberIds' : ids
    };
  }

  static ChurchMembers fromDoc(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return ChurchMembers(
      id: doc.id,
      ids: List<String>.from(data['ids'] ?? [])
    );
  }
  static empty() {
    return {
      'memberIds' : []
    };
  }
}
