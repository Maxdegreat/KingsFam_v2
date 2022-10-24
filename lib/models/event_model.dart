import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String? id;
  final String eventTitle;
  final String eventDecription;
  final Timestamp startDate;
  final Timestamp endDate;

  Event(
      {this.id,
      required this.eventTitle,
      required this.eventDecription,
      required this.startDate,
      required this.endDate
    });

  List<Object?> get props =>
      [id, eventTitle, eventDecription, startDate, endDate];

  Event copyWith({
    String? id,
    String? eventTitle,
    String? eventDecription,
    Timestamp? startDate,
    Timestamp? endDate,
  }) {
    return Event(
      id: id ?? this.id,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDecription: eventDecription ?? this.eventDecription,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'eventTitle': eventTitle,
      'eventDecription': eventDecription,
      'startDate' : startDate,
      'endDate' : endDate,
    };
  }

  static Event? formDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
      
        return Event(
            eventTitle: data['eventTitle'],
            eventDecription: data['eventDecription'],
            startDate: data['startDate'],
            endDate: data['endDate'],
        );
  }
}
