part of 'event_cubit.dart';

enum EventStatus {error, inital, loading, done}
class EventState extends Equatable {

  final String eventTitle;
  final String? eventDecription;
  final String authorId;
  final DateTime date;
  final Church fromCommuinity;
  final EventStatus status;
  final Failure failure;

  EventState({
    required this.eventTitle,
    this.eventDecription,
    required this.authorId,
    required this.date, 
    required this.fromCommuinity,
    required this.status,
    required this.failure
  });

  @override
  List<Object?> get props => [eventTitle, eventDecription, authorId, date, fromCommuinity, status, failure];

  

  EventState copyWith({
    String? eventTitle,
    String? eventDecription,
    String? authorId,
    DateTime? date,
    Church? fromCommuinity,
    EventStatus? status,
    Failure? failure,
  }) {
    return EventState(
      eventTitle: eventTitle ?? this.eventTitle,
      eventDecription: eventDecription ?? this.eventDecription,
      authorId: authorId ?? this.authorId,
      date: date ?? this.date,
      fromCommuinity: fromCommuinity ?? this.fromCommuinity,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }

  factory EventState.inital() {
    return EventState(
      eventTitle: '', 
      authorId: '', 
      date: DateTime.now(), 
      fromCommuinity: Church.empty,
      status: EventStatus.inital,
      failure: Failure()
      );
  }
}

