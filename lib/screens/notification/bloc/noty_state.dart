part of 'noty_bloc.dart';
enum NotyStatus {initial, loading, loaded, error}
class NotyState extends Equatable {
  final List<NotificationKF?> notifications;
  final NotyStatus status;
  final Failure failure;



  const NotyState({
    required this.notifications, 
    required this.status,
    required this.failure,
  });

  factory NotyState.initial() {
    return NotyState(notifications: [], status: NotyStatus.initial, failure: Failure());
  }
  
  @override
  List<Object> get props => [notifications, status, failure];

  NotyState copyWith({
    List<NotificationKF?>? notifications,
    NotyStatus? status,
    Failure? failure,
  }) {
    return NotyState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}

