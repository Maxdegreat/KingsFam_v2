import 'package:kingsfam/models/models.dart';

abstract class BaseNotificationRepository {
  Stream<List<Future<NotificationKF?>>> getUserNotifications({required String userId});
}
