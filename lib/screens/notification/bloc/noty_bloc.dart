import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/notification/noty_repository.dart';

part 'noty_event.dart';
part 'noty_state.dart';

class NotyBloc extends Bloc<NotyEvent, NotyState> {
  final NotificationRepository _notificationRepository;
  final AuthBloc _authBloc;

  StreamSubscription<List<Future<NotificationKF?>>>? _notificationSubscription;

  NotyBloc({
    required NotificationRepository notificationRepository,
    required AuthBloc authBloc,
  }) : _notificationRepository = notificationRepository, _authBloc = authBloc, super(NotyState.initial()) {
    try {
      _notificationSubscription?.cancel();
    _notificationSubscription = _notificationRepository
    .getUserNotifications(userId: _authBloc.state.user!.uid)
    .listen((value) async {
      final allNotys = await Future.wait(value);
      add(NotyUpdateNotifications(notifications: allNotys));
    });
    } catch (e) {
      print("The error when in noty stream sub is $e");
       emit(state.copyWith(status: NotyStatus.error));
    }
  }

  Future<void> close() {
    _notificationSubscription!.cancel();
    return super.close();
  }

  Stream<NotyState> mapEventToState(NotyEvent event) async* {
    if (event is NotyUpdateNotifications) {
      yield* _mapNotyUpdateNotificationsToState(event);
    }
  }

  Stream<NotyState> _mapNotyUpdateNotificationsToState(NotyUpdateNotifications event) async* {
    yield state.copyWith(notifications: event.notifications, status: NotyStatus.loaded);
  }
}
