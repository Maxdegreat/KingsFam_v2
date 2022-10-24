
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/event_model.dart';
import 'package:kingsfam/repositories/event/base_event_repo.dart';

class EventRepository extends BaseEventRepository {
  final _fb = FirebaseFirestore.instance.collection(Paths.events);

  @override
  void createEvent({required Event event, required String currId}) {
    _fb.doc(currId).set(event.toDoc());
  }

  @override
  void deleteEvent({required String currId}) {
    _fb.doc(currId).delete();
  }

  @override
  void updatEvent({required Event event, required String currId}) {
    _fb.doc(currId).update(event.toDoc());
  }
    
}