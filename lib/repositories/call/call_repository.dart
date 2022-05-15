import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/call_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';

import 'package:kingsfam/repositories/call/base_call_repository.dart';
import 'package:uuid/uuid.dart';

class CallRepository extends BaseCallRepository {

  

  final firebase = FirebaseFirestore.instance.collection(Paths.church);

  Stream<List<Future<CallModel>>> getCommuinityCallsStream({required String commuinityId, required int limit}) {
    return firebase.doc(commuinityId).collection(Paths.call).where('tag', isEqualTo: commuinityId)
      .limit(limit).snapshots().map((snap) => snap.docs.map((doc) => CallModel.fromDocAsync(doc)).toList());
  }

  Future<List<CallModel>> getCommuinityCalls({required String commuinityId}) async {
    var fire = await firebase.doc(commuinityId).collection(Paths.call).where('tag', isEqualTo: commuinityId).limit(7).get();
    return fire.docs.map((e) => CallModel.fromDoc(e)).toList();
  }


  //CREATE A CALL COLLECTION
  Future<CallModel> createCall2({required Church commuinity, required String callName}) async {
    try {
      CallModel call = CallModel(tag: commuinity.id!, name: callName, memberInfo: {}, allMembersIds: [], channelId: Uuid().v4(), hasDilled: false);
      await firebase.doc(commuinity.id).collection(Paths.call).add(call.toDoc());
      return call;
    } catch (e) {
      print("error in call repo createCall2 code: $e" );
      return CallModel.empty;
    }
  }
  @override
  void createCall({required String doc, required CallModel call}) async {
    try {
      await firebase.doc(doc).collection(Paths.call).add(call.toDoc());

    } catch (e) {
      print("error in call repo code: $e" );
    }
  }

  //DELETE THE CALL DOC
  @override
  Future<bool> deleateCall({required String commuinityId, required CallModel call, required String currId}) async {
    try {
      await firebase.doc(commuinityId).collection(Paths.call).doc(call.id!).delete();
      for(String id in call.allMembersIds) 
        await firebase.doc(commuinityId).collection(Paths.call).doc(call.id!).collection(Paths.activeInCall).doc(id).delete();
      
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //DILLE INTO THE CALL
  @override

  //END CALL

  @override
  Future<bool> isactiveInCall(
      {required Church commuinity,
      required CallModel call,
      required String id}) async {
    //acess the call and check is the curr id within the allMembersIds. if it is return true else retunrn false
    final ref = firebase
        .doc(commuinity.id)
        .collection(Paths.call)
        .doc(call.id)
        .collection(Paths.activeInCall)
        .doc(id)
        .get();

    DocumentSnapshot doc = await ref;
    // doc.exists
    //     ? print("the doc in call repo is active does exist")
    //     : print("the doc in call repo is active does not exist");
    return doc.exists;
  }

  void joinCall({required Userr user, required CallModel joinedCall, required CallModel call, required Church commuinity}) async {
      print("This is the problem...");
      
        print("5) in the hoin call at the repo edition");
        //commuinity will have muptile calls in one place but
      //each call will link via caller id;
          firebase
          .doc(commuinity.id)
          .collection(Paths.call)
          .doc(call.id)
          .set(joinedCall.toDoc()); //  MIGHT BE UPDATE IF NOT SET
          print("6) joined the call via the repo");
      //I also need to write the user id to the collection active
      firebase
          .doc(commuinity.id)
          .collection(Paths.call)
          .doc(call.id)
          .collection(Paths.activeInCall)
          .doc(user.id)
          .set({});
          print("7) joined the active collection via the repo");

  }

    //a check if allmemberids collection is empty ig
  //I can do this using a querrysnap or docsnap 
  Future<bool> isAllMemberIdsNotEmpty ({required String commuinityId, required String callId}) async {
    try {
      final ref = 
      firebase
      .doc(commuinityId)
      .collection(Paths.call)
      .doc(callId)
      .collection(Paths.activeInCall)
      .get();

      QuerySnapshot doc = await ref;

     return doc.docs.isNotEmpty;

    } catch (error) {
      print("There was an error in the in the call_repository, error code: $error");
      return false;
    }
  }
}
