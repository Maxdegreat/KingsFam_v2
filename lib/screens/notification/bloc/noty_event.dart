part of 'noty_bloc.dart';

abstract class NotyEvent extends Equatable {
  const NotyEvent();

  @override
  List<Object?> get props => [];
}

class NotyUpdateNotifications extends NotyEvent {
  final List<NotificationKF?> notifications;

  const NotyUpdateNotifications({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}