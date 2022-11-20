import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String? id;
  final String eventTitle;
  final String eventDescription;
  final Timestamp? startDate;
  final Timestamp? endDate;
  final List<String>? startDateFrontEnd;
  final List<String>? endDateFrontEnd;

  Event(
      {this.id,
      required this.eventTitle,
      required this.eventDescription,
      this.startDate,
      this.endDate,
      this.startDateFrontEnd,
      this.endDateFrontEnd,
    });

  List<Object?> get props =>
      [id, eventTitle, eventDescription, startDate, endDate, startDateFrontEnd, endDateFrontEnd];

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
      eventDescription: eventDecription ?? this.eventDescription,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'eventTitle': eventTitle,
      'eventDecription': eventDescription,
      'startDate' : startDate,
      'endDate' : endDate,
    };
  }

  static Event? formDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
      
      // the start and end timestamp stored as utc in db
      String startTime = DateTime.fromMicrosecondsSinceEpoch(data['startDate'].microsecondsSinceEpoch).toString();
      String endTime = DateTime.fromMicrosecondsSinceEpoch(data['endDate'].microsecondsSinceEpoch).toString();

       //                  year                 month                day                    hour                   second
      // var timelstS = [endTime.substring(0, 4), endTime.substring(5,7), endTime.substring(8, 10), endTime.substring(11, 13), endTime.substring(14, 16)];
      
      List<String> startDateFrontEnd = [startTime.substring(0, 4), startTime.substring(5,7), startTime.substring(8, 10), startTime.substring(11, 13), startTime.substring(14, 16)];;
      List<String> endDateFrontEnd = [endTime.substring(0, 4), endTime.substring(5,7), endTime.substring(8, 10), endTime.substring(11, 13), endTime.substring(14, 16)];
      
        return Event(
            id: doc.id,
            eventTitle: data['eventTitle'],
            eventDescription: data['eventDecription'],
            startDateFrontEnd: startDateFrontEnd,
            endDateFrontEnd: endDateFrontEnd,
            // startDate: data['startDate'],

            // I pass this to from doc for eval to see if the event has passed. if so i del. 
            // see event repo or cmBloc for reference
            endDate: data['endDate'], 
        );
  }
}
