import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/call/call_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

part 'calls_home_state.dart';

class CallshomeCubit extends Cubit<CallshomeState> {

  final CallRepository _callRepository;
  final UserrRepository _userrRepository;
  final AuthBloc _authBloc;

  CallshomeCubit({
    required CallRepository callRepository,
    required UserrRepository userrRepository,
    required AuthBloc authBloc,
  }) : _callRepository = callRepository, 
      _userrRepository = userrRepository,
      _authBloc = authBloc,
      super(CallshomeState.initial());
  
  //a local var
  final firebase = FirebaseFirestore.instance.collection(Paths.church);

  final String ecode = "ERROR: calls_home_cubit, code is: ";

  void onNameCallChanged(String name) {
    emit(state.copyWith(callName: name, status: CallsHomeStatus.initial));
  }

  void onDeleteCall({required String CommuinityId, required CallModel call}) async {
    emit(state.copyWith(status: CallsHomeStatus.loading));
    //entering the try bloc
    try {
      _callRepository.deleateCall(commuinityId: CommuinityId, call: call, currId: _authBloc.state.user!.uid);
      emit(state.copyWith(status: CallsHomeStatus.done));
    } catch (error) {
      print(ecode + "$error");
      emit(state.copyWith(status: CallsHomeStatus.error));
    }
  }

  void submitNewCall({required Church commuinity}) async {
    emit(state.copyWith(status: CallsHomeStatus.loading));
    try {
      CallModel createCall = CallModel(
        callerId: null,
        name: state.callName,
        callerUsername: null,
        callerPicUrl: commuinity.imageUrl,
        allMembersIds: [],
        memberInfo: {},
        channelId: Uuid().v4(),
        hasDilled: false,
      );

      _callRepository.createCall(doc: commuinity.id!, call: createCall);
      emit(state.copyWith(status: CallsHomeStatus.initial));
    } catch (error) {
      print(ecode + "$error");
      emit(state.copyWith(status: CallsHomeStatus.error));
    }
  }

  void isActiveInCall({required Church commuinity, required CallModel call, required String currId}) async {
      //print("we are in the isActiveInCall method located in the commuinity / screens/ call/ cubit");
    try {
      final bool isActive = await _callRepository.isactiveInCall(commuinity: commuinity, call: call, id: currId);
      //print("In the call cubit isActive = $isActive");
      emit(state.copyWith(currActive: isActive, status: CallsHomeStatus.initial));
      emit(state.copyWith(currActive: isActive));
    } catch (error) {
      print(ecode + "$error");
    }
  }
  
 
  Future<bool> isActiveInCallReturn({required Church commuinity, required CallModel call, required String currId}) async {
      //print("we are in the isActiveInCall method located in the commuinity / screens/ call/ cubit");
    try {
      final bool isActive = await _callRepository.isactiveInCall(commuinity: commuinity, call: call, id: currId);
      //print("In the call cubit isActive = $isActive");
      emit(state.copyWith(currActive: isActive, status: CallsHomeStatus.initial));
      return isActive;
    } catch (error) {
      print(ecode + "$error");
      return false;
    }
  }

  void inviteToCall() async {
    emit(state.copyWith(status: CallsHomeStatus.loading));
    try {
      final userId = _authBloc.state.user!.uid;
      final currFollowingIds = await _userrRepository.listOfIdsCurrFollowing(uid: userId);
      final List<Userr> bucket = [];
      Future<void> grabFollowers() async {
        for (int i = 0; i < currFollowingIds.length; i++) {
          final user = await _userrRepository.getUserrWithId(userrId: currFollowingIds[i]);
          bucket.add(user);
        }
      }
      await grabFollowers();
      emit(state.copyWith(currFollowing: bucket, status: CallsHomeStatus.initial));
    } catch (error) {
      emit(state.copyWith(status: CallsHomeStatus.error, failure: Failure(message: "ummm, theres an error grabing your followers?", code: "error code is: $error")));
      print(ecode + '$error');
    }
  }

   Future<List<Userr>> inviteToCallReturn() async {
    emit(state.copyWith(status: CallsHomeStatus.loading));
    try {
      final userId = _authBloc.state.user!.uid;
      final currFollowingIds = await _userrRepository.listOfIdsCurrFollowing(uid: userId);
      final List<Userr> bucket = [];
      Future<void> grabFollowers() async {
        for (int i = 0; i < currFollowingIds.length; i++) {
          final user = await _userrRepository.getUserrWithId(userrId: currFollowingIds[i]);
          bucket.add(user);
        }
      }
      await grabFollowers();
      emit(state.copyWith(currFollowing: bucket, status: CallsHomeStatus.initial));
      return bucket;
    } catch (error) {
      emit(state.copyWith(status: CallsHomeStatus.error, failure: Failure(message: "ummm, theres an error grabing your followers?", code: "error code is: $error")));
      print(ecode + '$error');
      return [];
    }
  }

  void grabCurrInCall(List<String> allMemberIds) async {
    emit(state.copyWith(status: CallsHomeStatus.loading ));
    try {
      List<Userr> bucket = [];
      Future <void> func() async {
        for (int i = 0; i < allMemberIds.length; i++){
          final user = await _userrRepository.getUserrWithId(userrId: allMemberIds[i]);
          bucket.add(user);
        }
      }
      await func();
      emit(state.copyWith(status: CallsHomeStatus.initial, currInCall: bucket));
    } catch (error) {
      emit(state.copyWith(status: CallsHomeStatus.error, failure: Failure(message: "ummm, theres an error grabing your followers?", code: "error code is: $error")));
      print(ecode + "$error");
    }
  }

  void joinCall({required String currId, required CallModel call, required Church commuinity}) async {
    if (call.callerId == null && call.allMembersIds.length <= 0) {
      print("1) We are in the true bloc of joinCall cubit edition");
      final Userr caller = await _userrRepository.getUserrWithId(userrId: currId);
      call.allMembersIds.add(caller.id);
      Map<String, dynamic> userMap = {
        'username' : caller.username,
        'profileImageUrl':caller.profileImageUrl,
      };
      state.memberInfo[caller.id] = userMap;
      //if allmemberids is not empty then hasdiled is true add this later
      final bool hasDilled = await _callRepository.isAllMemberIdsNotEmpty(commuinityId: commuinity.id!, callId: call.id!);
      print("2) not hanging, has diled is $hasDilled");
      final CallModel joinedCall = CallModel(
        name: call.name,
        callerId: caller.id,
        callerUsername: caller.username,
        callerPicUrl: caller.profileImageUrl,
        memberInfo: state.memberInfo,
        allMembersIds: call.allMembersIds,
        channelId: call.channelId,
        hasDilled: hasDilled,
      );
      //basically what this joinCall repo func does is it places the joiner in the designeated section for them to join 
      //it also adds them into the activeincall collection, this is then used to know if the user is in a call at the given
      //moment
      print("3) moving into the joinCall located in the call repository");
      _callRepository.joinCall(user: caller, joinedCall: joinedCall, call: call, commuinity: commuinity);
      print("4) now loading in...");
    } else if (call.callerId != null && call.allMembersIds.length >= 1) {
      final Userr reciever = await _userrRepository.getUserrWithId(userrId: currId);
      final Map<String, dynamic> userMap = {
        'username': reciever.username,
        'profileImage' : reciever.profileImageUrl,
      };
      call.allMembersIds.add(reciever.id);
      state.memberInfo[currId] = userMap; //kinda wondering why i dont do state.allmemberIds...

      final bool hasDilled = await _callRepository.isAllMemberIdsNotEmpty(commuinityId: commuinity.id!, callId: call.id!);
      final CallModel joinedCall = CallModel(
        name: call.name, 
        callerId: call.callerId,
        callerUsername: call.callerUsername,
        allMembersIds: call.allMembersIds,
        channelId: call.channelId,
        memberInfo: state.memberInfo,
        callerPicUrl: call.callerPicUrl,
        hasDilled: hasDilled
      );
      _callRepository.joinCall(user: reciever, joinedCall: joinedCall, call: call, commuinity: commuinity);
    }
  }

  //for end call: if call.callerid leaves for simplicity the call will end

  //else for all else if they leave just remove form active in call, memberinfo, allmemberids

  //ontap end call extract the userid and chaeck to see who ended the call
  void leaveCall({required Church commuinity, required CallModel call, required String currId}) async {
    if (currId == call.callerId) {
      _callRepository.deleateCall(commuinityId: commuinity.id!, call: call, currId: currId);
    } else {
      firebase.doc(commuinity.id!).collection(Paths.call).doc(call.id).collection(Paths.activeInCall).doc(currId).delete();
      call.allMembersIds.remove(currId);
      call.memberInfo.remove(currId);
      firebase.doc(commuinity.id).collection(Paths.call).doc(call.id).update(call.toDoc());
    }

  }

  void sendRing({required CallModel call, required String invitedID, required Church commuinity}) async {
    final ringRef = FirebaseFirestore.instance.collection(Paths.ring);
    final caller = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);
    call.copyWith(callerUsername: caller.username);
    ringRef.doc(invitedID).set(call.toDoc()); 
    
    //now i want to add a stbuilder that listends and when heared pop up in app OVER ANYTHING and show whos calling
    //while adding a route for the user to join the call. only one person can be ringing at once so if there are two calls just 
    //kick the second call to the curb alsoooo add in the noty repo that someone was called... do that here tho
    final NotificationKF noty = NotificationKF(
      notificationType: Notification_type.invite_to_call,
      fromUser: Userr.empty.copyWith(id: caller.id),
      fromCommuinity: Church.empty.copyWith(id: commuinity.id),
      fromCall: CallModel.empty.copyWith(id: call.id),
      fromDirectMessage: null, 
      date: Timestamp.now(),
    );

    FirebaseFirestore.instance.collection(Paths.noty).doc(invitedID).collection(Paths.notifications).add(noty.toDoc());
  } 
  //the invited user declines the call removing the call doc. remember can only have one call at a time so if 
  void declineRIng({required String invitedId}) =>
    FirebaseFirestore.instance.collection(Paths.ring).doc(invitedId).delete();
  

}
