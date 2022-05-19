
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';

import 'church_model.dart';

class Event extends Equatable {
  final String? id;
  final String eventTitle;
  final String? eventDecription;
  final String authorId;
  final DateTime date;
  final Church fromCommuinity;

  Event({
    this.id,
    required this.eventTitle,
    this.eventDecription,
    required this.authorId,
    required this.date,
    required this.fromCommuinity
  });

  List<Object?> get props => [id, eventTitle, eventDecription, authorId, date, fromCommuinity];

  

  Event copyWith({
    String? id,
    String? eventTitle,
    String? eventDecription,
    String? authorId,
    DateTime? date,
    Church? fromCommuinity,
  }) {
    return Event(
      id: id ?? this.id,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDecription: eventDecription ?? this.eventDecription,
      authorId: authorId ?? this.authorId,
      date: date ?? this.date,
      fromCommuinity: fromCommuinity ?? this.fromCommuinity,
    );
  }

  Map<String, dynamic> toDoc () {
    return {
      'eventTitle' : eventTitle,
      'eventDecription' : eventDecription,
      'authorId' : authorId,
      'date' : date,
      'fromCommuinity' : 
        FirebaseFirestore.instance.collection(Paths.church).doc(fromCommuinity.id),
    };
  }

  static Future<Event?> formDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final commuinityRef = data['formCommuinity'] as DocumentReference?;
    if (commuinityRef != null) {
      final commuinityDoc = await commuinityRef.get();
      var ch = await Church.fromDoc(commuinityDoc);
      if (commuinityDoc.exists) {
        return Event(
          eventTitle: data['eventTitle'], 
          authorId: data['authorId'], 
          date: (data['date'] as Timestamp).toDate(), 
          fromCommuinity: ch
        );
      }
    }
  }
}
