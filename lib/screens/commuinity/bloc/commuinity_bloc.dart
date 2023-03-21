// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/cm_privacy.dart';
import 'package:kingsfam/config/mock_flag.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/mock_post_data.dart';

part 'commuinity_event.dart';
part 'commuinity_state.dart';

// FOR NAVIGATION OF THIS FILE READ BELOW
// new kingscord info: KINGSCORD METHODS

class CommuinityBloc extends Bloc<CommuinityEvent, CommuinityState> {
  final ChurchRepository _churchRepository;
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final UserrRepository _userrRepository;

  // three stream subscriptions used for listening to new values of each
  // respectivly
  StreamSubscription<List<Future<KingsCord?>>>? _streamSubscriptionKingsCord;
  StreamSubscription<bool>? _streamSubscriptionIsMember;

  CommuinityBloc({
    required ChurchRepository churchRepository,
    required StorageRepository storageRepository,
    required AuthBloc authBloc,
    required UserrRepository userrRepository,
  })  : _churchRepository = churchRepository,
        _storageRepository = storageRepository,
        _authBloc = authBloc,
        _userrRepository = userrRepository,
        super(CommuinityState.inital());

  @override
  Future<void> close() {
    _streamSubscriptionKingsCord!.cancel();
    _streamSubscriptionIsMember!.cancel();
    return super.close();
  }

  @override
  Stream<CommuinityState> mapEventToState(CommuinityEvent event) async* {
    if (event is CommunityInitalEvent) {
      yield* _mapCommunityInitalEventToState(event);
    } else if (event is CommunityLoadingCords) {
      yield* _mapCommuinityLoadingCordsToState(event);
    } else if (event is CommunityLoadingPosts) {
      yield* _mapCommunityLoadingPostToState(event);
    }
  }

  String failed = 'failed to load commuinty screen';

  Stream<CommuinityState> _mapCommunityInitalEventToState(
      CommunityInitalEvent event) async* {
    emit(state.copyWith(
      // ADD ROOMS WITH INIT AS EMPTY IF THROWING ERRORS
      status: CommuintyStatus.loading,
    ));
    try {
      bool isBan = await _churchRepository.isBaned(
          usrId: _authBloc.state.user!.uid, cmId: event.commuinity.id!);

      emit(state.copyWith(isBaned: isBan));

      String uid = _authBloc.state.user!.uid;
      emit(state.copyWith(currUserr: event.currUserr));

      Church cm = Church.empty.copyWith(
        id: event.commuinity.id,
        members: event.commuinity.members,
      );

      // getting rid of this ??? why? i commented it for now. will look into later and approve.
      // _churchRepository.updateUserTimestampOnOpenCm(
      //     cm, _authBloc.state.user!.uid);

      // load if is member then handel as the cm requirments
      late bool isMem;

      var ism = await _churchRepository.streamIsCmMember(
          cm: event.commuinity, authorId: _authBloc.state.user!.uid);

      _streamSubscriptionIsMember = ism.listen((isMemStream) async {
        isMem = isMemStream; // I took off an await incase mem is now broken
        if (!isMem) {
          // read privacy to see if cm is private or not
          DocumentSnapshot privacySnap = await FirebaseFirestore.instance
              .collection(Paths.cmPrivacy)
              .doc(event.commuinity.id)
              .get();
          if (privacySnap.exists) {
            Map<String, dynamic> data =
                privacySnap.data() as Map<String, dynamic>;

            String? cmPrivacy = data['privacy'] ?? null;

            // check to see if there is any pending request to join
            DocumentSnapshot requestSnap = await FirebaseFirestore.instance
                .collection(Paths.requestToJoinCm)
                .doc(event.commuinity.id)
                .collection(Paths.request)
                .doc(_authBloc.state.user!.uid)
                .get();

            if (requestSnap.exists) {
              if (cmPrivacy == CmPrivacy.armored) {
                // pending bc request exits alredy
                emitWhenCmIsArmored(
                    isMem, CommuintyStatus.armormed, RequestStatus.pending);
              } else {
                // cm was made open:

              }
            } else {
              // allow users to request if it is required
              if (cmPrivacy == CmPrivacy.armored) {
                emitWhenCmIsArmored(
                    isMem, CommuintyStatus.armormed, RequestStatus.none);
              } else {
                // open cm
                emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
                add(CommunityLoadingCords(commuinity: event.commuinity));
              }
            }
          } else {
            // else there is no privacy setting. this is kinda a bug ngl. older versions require this check
            // because they do not have a cm privacy setting
            emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
            add(CommunityLoadingCords(commuinity: cm));
          }
        } else {
          UserPreferences.updateCmTimestamp(cmId: event.commuinity.id!);
          // UserPreferences.updateLastVisitedCm(cmId: event.commuinity.id!);
          // get the role of the user
          FirebaseFirestore.instance
              .collection(Paths.communityMembers)
              .doc(event.commuinity.id)
              .collection(Paths.members)
              .doc(uid)
              .get()
              .then((cmUserInfoDoc) {
                // TESTV2 THIS WAS AN AWAIT AND I MADE IT A .THEN IF NO WORK MOVE BACK
            if (cmUserInfoDoc.exists && cmUserInfoDoc.data() != null) {
              String? kfRole = cmUserInfoDoc.data()!["kfRole"] ?? "member";

              Map<String, dynamic> role = {
                "kfRole": kfRole,
              };

              emit(state.copyWith(role: role));
            }
          });

          // when the member is apart of the community
          emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
          add(CommunityLoadingCords(commuinity: cm));
        }
      });

      // emit(state.copyWith(
      //     themePack: event.commuinity.themePack,
      //     boosted: event.commuinity.boosted));

      // update the usr timestamp for the cm when they open the cm

    } catch (e) {
      emit(state.copyWith(
          status: CommuintyStatus.error,
          failure: Failure(message: failed, code: e.toString())));
    }
  }

  Stream<CommuinityState> _mapCommuinityLoadingCordsToState(CommunityLoadingCords event) async* {
    // make calls stream
    // add calls to loaded then yield
    // also add this.event to loaded yield ... now has both list (this event has the cord and cm)
    // STILL LOADING SO NO YIELD YET
    try {
      // ignore: unused_local_variable
      // final Userr userr = await _userrRepository.getUserrWithId(
      //     userrId: _authBloc.state.user!.uid);

      // stream subscription for community cords
      _streamSubscriptionKingsCord?.cancel();
      _streamSubscriptionKingsCord = _churchRepository
          .getCommuinityCordsStream(
              commuinity: event.commuinity,
              limit: MockFlag.ISMOCKTESTING ? 10 : 50)
          .listen((kcords) async {
        // if (MockFlag.ISMOCKTESTING) return;
        // final allCords = await Future.wait(kcords);

        await KingsCordRepository()
            .futureWaitCord(
                kcords, event.commuinity.id!, _authBloc.state.user!.uid)
            .then((kingsCords) {
          // The updated status in the emit is used in cm screen listener. if status is updated we setstate. thats it.
          emit(state.copyWith(
              yourRooms: kingsCords["kc"], status: CommuintyStatus.updated));
          emit(state.copyWith(status: CommuintyStatus.inital));
        });

        // add(CommunityLoadingEvents(cm: event.commuinity));
      });
      add(CommunityLoadingPosts(cm: event.commuinity));
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(message: failed, code: e.toString())));
    }
  }

  // this is the loaded for the community content. _____________

  Stream<CommuinityState> _mapCommunityLoadingPostToState(CommunityLoadingPosts event) async* {
    try {
      List<Post?> posts = [];
      if (!MockFlag.ISMOCKTESTING)
        posts = await _churchRepository.getCommuinityPosts(cm: event.cm);
      else
        posts = MockPostData.getMockPosts2;
      emit(state.copyWith(postDisplay: posts, status: CommuintyStatus.loaded));

      // check if any pending request in cm
      if (state.role["kfRole"] == "Lead" ||
          state.role["kfRole"] == "Admin" ||
          state.role["kfRole"] == "Mod") {
        var requestSnap = await FirebaseFirestore.instance
            .collection(Paths.requestToJoinCm)
            .doc(state.cmId)
            .collection(Paths.request)
            .limit(1)
            .get();
        emit(state.copyWith(cmHasRequest: requestSnap.docs.first.exists));
      }
    } catch (e) {
      emit(state.copyWith(
          failure: Failure(
              message: "Ops, something went wrong when getting the cm post")));
    }
  }

  // ================== emit methods =======================
  emitWhenCmIsArmored(bool isMem, CommuintyStatus status, RequestStatus requestStatus) {
    emit(state.copyWith(
        isMember: isMem,
        postDisplay: [],
        status: status,
        requestStatus: requestStatus));
  }

  emitWhenCmIsShielded(bool isMem, List<KingsCord?>? kcs, List<Post?> posts,CommuintyStatus status, RequestStatus requestStatus) {
    emit(state.copyWith(
      isMember: isMem,
      postDisplay: posts,
      status: status,
      requestStatus: requestStatus,
    ));
  }

  emitWhenCmIsOpen(bool isMem, List<KingsCord?>? kcs, List<Post?> posts, CommuintyStatus status) {
    emit(state.copyWith(
      isMember: isMem,
      postDisplay: posts,
      status: status,
      requestStatus: RequestStatus.none,
    ));
  }

  // ============== funcs =======================

  Future<void> onLeaveCommuinity({required Church commuinity, String? leavingUid}) async {
    if (leavingUid == null) leavingUid = _authBloc.state.user!.uid;
    // else we are using the id of the user that was passed in.
    _churchRepository.leaveCommuinity(
        commuinity: commuinity, leavingUserId: leavingUid);
    emit(state.copyWith(isMember: false));
  }

  Future<void> onJoinCommuinity( {required Church commuinity, required BuildContext context, }) async {
    bool isBan = await _churchRepository.isBaned(
        usrId: _authBloc.state.user!.uid, cmId: commuinity.id!);

    emit(state.copyWith(isBaned: isBan));

    await Future.delayed(Duration(seconds: 1));

    if (isBan == false) {
      final userrId = _authBloc.state.user!.uid;
      final user = await _userrRepository.getUserrWithId(userrId: userrId);
      emit(state.copyWith(isMember: true));
      _churchRepository.onJoinCommuinity(commuinity: commuinity, user: user);
      await Future.delayed(Duration(seconds: 1));
      add(CommunityInitalEvent(commuinity: commuinity, currUserr: user));
    } else {
      log("we are in the true, is ban is true");
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                  FittedBox(
                    child: Text("You Are not allowed"),
                  ),
                  FittedBox(
                    child: Text("to join this community"),
                  ),
                  FittedBox(child: Text("at this moment.")),
                  FittedBox(
                    child: Text("Possibly due to a ban"),
                  )
                ],
              ),
            );
          });
    }
  }

  Future<void> requestToJoin(Church cm, String usrId) async {
    FirebaseFirestore.instance
        .collection(Paths.requestToJoinCm)
        .doc(cm.id)
        .collection(Paths.request)
        .doc(usrId)
        .set({});
    emit(state.copyWith(requestStatus: RequestStatus.pending));
  }

  Future<void> banedUsers({required String communityId}) async {
    String? lastDocId =
        state.banedUsers.length > 0 ? state.banedUsers.last.id : null;
    if (state.banedUsers.length > 0 && lastDocId == null) {
      return;
    }
    log("Getting band users");
    List<Userr> banedUsers = await _churchRepository.getBanedUsers(
        cmId: communityId, lastDocId: lastDocId);
    log("len of get ban users: " + banedUsers.length.toString());
    List<Userr> updatedBanedUsers = List<Userr>.from(state.banedUsers)
      ..addAll(banedUsers);
    log("val of baned users is: " + updatedBanedUsers.length.toString());
    emit(state.copyWith(banedUsers: updatedBanedUsers));
  }

  void unBan({required String cmId, required Userr usr}) {
    _churchRepository.unBan(cmId: cmId, usrId: usr.id);
    var x = state.banedUsers;
    x.remove(usr);
    emit(state.copyWith(banedUsers: x));
  }

  void ban({required Church cm, required String uid}) {
    _churchRepository.banFromCommunity(community: cm, baningUserId: uid);
  }

  void onBoostCm({required String cmId}) {
    if (state.boosted != 1) {
      _churchRepository.onBoostCm(cmId: cmId);
    }
    emit(state.copyWith(boosted: 1));
  }

  Future<void> delKc({required KingsCord cord, required Church commuinity}) async {
    // gives unexpected behavior
    // should not del kc if only on kc.
    await _churchRepository.delCord(cmmuinity: commuinity, cord: cord);
    log("del complete");
  }

  Future<void> makeNewKc({
    required Church commuinity,
    required String cordName,
    required BuildContext ctx,
    required String mode,
    String? rolesAllowed,
    required BuildContext context,
  }) async {Userr currUser = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);
    log("awaiting ch msg");
    await _churchRepository.newKingsCord2(
      ch: commuinity,
      cordName: formatCordName(cordName),
      currUserId: currUser.id,
      mode: mode,
      rolesAllowed: rolesAllowed,
    );
    // WE DO NOT EMIT TO STATE BECAUSE THERE IS ALREDY A STREAM LISTENING FOR KC'S AND THE STREAM EMITS TO STATE
    // ANY ATTEMPT TO EMIT FROM HERE WHILE THE STREAM IS ACTIVE WILL CAUSE SOME OUT OF RANGE ERRORS.
  }

  String formatCordName(String cordName) {
    String newName = "";
    for (int i = 0; i < cordName.length; i++) {
      if (cordName[i] == " ") {
        newName += "-";
      } else {
        newName += cordName[i];
      }
    }
    return newName;
  }

  void updateCmId(String id, Church cm, Userr u) {
    emit(state.copyWith(cmId: id));
    add(CommunityInitalEvent(commuinity: cm, currUserr: u));
  }

  setReadStatusFalse({required String kcId}) {
    // seting the read status false for a given kc tracked by the KCid.
    // for (KingsCord? kc in state.kingCords) {
    //   if (kc != null && kc.id! == kcId) {
    //     state.kingCords.remove(kc);
    //     state.kingCords.add(kc.copyWith(readStatus: false));
    //     emit(state.copyWith(status: CommuintyStatus.updated));
    //   }
    // }
  }

  void getRooms(String id) async {
    log("len of Id" + id.length.toString());
    List<KingsCord> r = await _churchRepository.getRooms(id);
    log("r len: " + r.length.toString());
    emit(state.copyWith(otherRooms: r));
  }
}
