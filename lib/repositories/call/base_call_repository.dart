import 'package:kingsfam/models/call_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';

abstract class BaseCallRepository {
  void createCall({required String doc, required CallModel call});
  Future<bool> deleateCall({required String commuinityId, required CallModel call, required String currId});
  Future<bool> isactiveInCall({required Church commuinity, required CallModel call, required String id});
  void joinCall({required Userr user, required CallModel joinedCall, required CallModel call, required Church commuinity});
  Future<bool> isAllMemberIdsNotEmpty ({required String commuinityId, required String callId});
}
