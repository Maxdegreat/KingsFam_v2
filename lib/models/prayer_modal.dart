import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PrayerModal extends Equatable {
  final String prayer;
  final String userId;
  final Timestamp timestamp;

  PrayerModal({required this.prayer, required this.userId, required this.timestamp});

   Map<String, dynamic> toDoc() {
    return {
      "prayer" : prayer,
      "userId" : userId,
      "timestamp" : timestamp
    };
  }
  @override
  List<Object?> get props => throw [prayer, userId, timestamp];

  static PrayerModal fromDoc(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return PrayerModal(
        prayer: data["prayer"] ?? "",
        userId: data["userId"] ?? "",
        timestamp: data["timestamp"] ?? Timestamp.now());
  }
}
