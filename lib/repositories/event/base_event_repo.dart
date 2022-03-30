import 'package:kingsfam/models/models.dart';

abstract class BaseEventRepository {
  void createEvent({required Event event, required String currId});
  void deleteEvent({required String currId});
  void updatEvent({required Event event, required String currId});
}