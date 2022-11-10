import 'package:kingsfam/models/models.dart';

abstract class BaseNotificationRepository {
  Stream<List<NotificationKF?>> getUserNotifications({required String userId});
}
