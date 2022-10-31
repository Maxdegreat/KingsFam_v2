// import 'dart:async';
// import 'dart:developer';

// import 'package:bloc/bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:kingsfam/blocs/auth/auth_bloc.dart';
// import 'package:kingsfam/config/cm_privacy.dart';
// import 'package:kingsfam/config/paths.dart';
// import 'package:kingsfam/models/mentioned_model.dart';
// import 'package:kingsfam/models/models.dart';
// import 'package:kingsfam/repositories/repositories.dart';
// import 'package:kingsfam/widgets/snackbar.dart';
// import 'package:video_player/video_player.dart';

// import '../../../roles/role_types.dart';

// part 'commuinity_event.dart';
// part 'commuinity_state.dart';

// // FOR NAVIGATION OF THIS FILE READ BELOW
// // new kingscord info: KINGSCORD METHODS

// class CommuinityBloc extends Bloc<CommuinityEvent, CommuinityState> {
//   final ChurchRepository _churchRepository;
//   final StorageRepository _storageRepository;
//   final AuthBloc _authBloc;
//   final UserrRepository _userrRepository;
//   final CallRepository _callRepository;

//   // three stream subscriptions used for listening to new values of each
//   // respectivly
//   StreamSubscription<List<Future<KingsCord?>>>? _streamSubscriptionKingsCord;
//   StreamSubscription<bool>? _streamSubscriptionIsMember;

//   CommuinityBloc({
//     required ChurchRepository churchRepository,
//     required StorageRepository storageRepository,
//     required AuthBloc authBloc,
//     required CallRepository callRepository,
//     required UserrRepository userrRepository,
//   })  : _churchRepository = churchRepository,
//         _storageRepository = storageRepository,
//         _authBloc = authBloc,
//         _userrRepository = userrRepository,
//         _callRepository = callRepository,
//         super(CommuinityState.inital());

//   @override
//   Future<void> close() {
//     _streamSubscriptionKingsCord!.cancel();
//     _streamSubscriptionIsMember!.cancel();
//     return super.close();
//   }

//   @override
//   Stream<CommuinityState> mapEventToState(CommuinityEvent event) async* {
//     if (event is CommunityInitalEvent) {
//       yield* _mapCommunityInitalEventToState(event);
//     } else if (event is CommunityLoadingCords) {
//       yield* _mapCommuinityLoadingCordsToState(event);
//     } else if (event is CommunityLoadingPosts) {
//       yield* _mapCommunityLoadingPostToState(event);
//     } else if (event is CommunityLoadingEvents) {
//       yield* _mapCommunityLoadingEventsToState(event);
//     }
//   }


//   String failed = 'failed to load commuinty screen';

//   Stream<CommuinityState> _mapCommunityInitalEventToState(CommunityInitalEvent event) async* {
//     emit(state.copyWith(status: CommuintyStatus.loading));
//     try {
//       // load if member and handel as the cm requires
//       late bool isMem;

//       var ism = await _churchRepository.streamIsCmMember(
//           cm: event.commuinity, 
//           authorId: _authBloc.state.user!.uid
//       );

//       _streamSubscriptionIsMember = ism.listen((isMemStream) async {
        
//         isMem = isMemStream; // I took off an await incase mem is now broken
//         if (!isMem) {
//           log("not a member");
//           // read privacy to see if cm is private or not
//           DocumentSnapshot privacySnap = await FirebaseFirestore.instance.collection(Paths.cmPrivacy).doc(event.commuinity.id).get();
//           if (privacySnap.exists) {
//             log("The Privacy snap exist");
//             Map<String, dynamic> data = privacySnap.data() as Map<String, dynamic>;
//             log("about to do the from data[] thing");
//             String? cmPrivacy = data['privacy'] ?? null;
//             log("The cmPrivacy is: ");
//             log(" $cmPrivacy");
//             // check to see if there is any pending request to join
//             DocumentSnapshot requestSnap = await FirebaseFirestore.instance.collection(Paths.requestToJoinCm).doc(event.commuinity.id)
//               .collection(Paths.request).doc(_authBloc.state.user!.uid).get();

//             if (requestSnap.exists) {
//               log("a request snap exist");
//               // show cms but set status to requestPending
//               if (cmPrivacy == CmPrivacy.armored) {
//                 log("requested: this is a armored cm");
//               // say request to join. if requested please wait for approval
//               emitWhenCmIsArmored(isMem, CommuintyStatus.armormed, RequestStatus.pending);
//             } else if (cmPrivacy == CmPrivacy.shielded) {
//                 log("requested: this is a shielded cm");
//               // show cm HIDE ALL cords DO NOT ALLOW TO OPEN CORDS AND EVENTS
//               // has to request access to join
//               emitWhenCmIsShielded(isMem, [], [], CommuintyStatus.shielded, RequestStatus.pending);
//               add(CommunityLoadingPosts(cmId: event.commuinity.id!));
//             } 

//             } else {
//               // allow users to request if it is required
//               if (cmPrivacy == CmPrivacy.armored) {
//                 log("make a request to this armored cm");
//               // say request to join. if requested please wait for approval
//               emitWhenCmIsArmored(isMem, CommuintyStatus.armormed, RequestStatus.none);
//             } else if (cmPrivacy == CmPrivacy.shielded) {
//               log("make a request to this shielded cm");
//               // show cm HIDE ALL DO NOT ALLOW TO OPEN CORDS
//               // has to request access to join
//               emitWhenCmIsShielded(isMem, [], [], CommuintyStatus.shielded, RequestStatus.none);
//             } else {
//               log("no request needed to join this cm");
//               // allow to join and read cords. all is chill
//               emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
//             }
            
//             }
          
//           } else {
//             // else there is no privacy setting. this is kinda a bug ngl. older versions require this check
//             // because they do not have a cm privacy setting
//             emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
//           }
//         } else {
//           log("This is a open cm. join at will");
//           // when the member is apart of the community
//           emitWhenCmIsOpen(isMem, [], [], CommuintyStatus.loaded);
//         }
       
//       }
//     );

      

//       // emit(state.copyWith(
//       //     themePack: event.commuinity.themePack,
//       //     boosted: event.commuinity.boosted));

//       // update the usr timestamp for the cm when they open the cm
//       Church cm = Church.empty.copyWith(
//         id: event.commuinity.id,
//         members: event.commuinity.members,
//       );

//       _churchRepository.updateUserTimestampOnOpenCm(cm, _authBloc.state.user!.uid);

//       add(CommunityLoadingCords(commuinity: cm));

//     } catch (e) {
//       emit(state.copyWith(
//           status: CommuintyStatus.error,
//           failure: Failure(message: failed, code: e.toString())));
//     }
//   }

//   Stream<CommuinityState> _mapCommuinityLoadingCordsToState(CommunityLoadingCords event) async* {
//     // make calls sream
//     // add calls to loaded then yield
//     // also add this.event to loaded yield ... now has both list (this event has the cord and cm)
//     // STILL LOAFDING SO NO YIELD YET
//     try {

      
//       // ignore: unused_local_variable
//       final List<KingsCord> allCords = [];
//       final Map<String, bool> mentionedMap = {};
//       final Userr userr = await _userrRepository.getUserrWithId(userrId: _authBloc.state.user!.uid);

//       // stream subscription for community cords
//       _streamSubscriptionKingsCord?.cancel();
//       _streamSubscriptionKingsCord = _churchRepository
//           .getCommuinityCordsStream(commuinity: event.commuinity, limit: 100)
//           .listen((kcords) async {
//         final allCords = await Future.wait(kcords);
//         for (var kcAwait in kcords) {
//           final kc = await kcAwait;
//           if (kc != null) {
//             //allCords.add(kc);
//             var docRef = await FirebaseFirestore.instance
//                 .collection(Paths.mention)
//                 .doc(_authBloc.state.user!.uid)
//                 .collection(event.commuinity.id!)
//                 .doc(kc.id);
//             docRef.get().then((value) => {
//                   if (value.exists)
//                     {
//                       mentionedMap[kc.id!] = true,
//                     }
//                   else
//                     {mentionedMap[kc.id!] = false},
//                   emit(state.copyWith(
//                       mentionedMap: mentionedMap,
//                       currUserr: userr,
//                       kingCords: allCords))
//                 });
//           }
//         }

//         add(CommunityLoadingEvents(cm: event.commuinity));
//       });

























//       List<Post?> posts =
//           await _churchRepository.getCommuinityPosts(cm: event.commuinity);

//       add(CommunityLoadingPosts(
//           kcs: event.cords, posts: posts, commuinity: event.commuinity));
//     } catch (e) {
//       emit(state.copyWith(
//           failure: Failure(message: failed, code: e.toString())));
//     }
//   }

//   Stream<CommuinityState> _mapCommunityLoadingEventsToState(CommunityLoadingEvents event) async* {
//     try {
//       QuerySnapshot eventSnaps = await FirebaseFirestore.instance.collection(Paths.church).doc(event.cm.id).collection(Paths.events).limit(5).get();
//         List<Event?> initEvents = [];
//         for (var doc in eventSnaps.docs) {
//           Event? e = Event.formDoc(doc);
//           if (e != null) {
//             // make a date time to check if its a past date. if so del event
//             DateTime endTimeForDel = DateTime.fromMicrosecondsSinceEpoch(e.endDate!.microsecondsSinceEpoch);
//             if (DateTime.now().isAfter(endTimeForDel)) {
//               FirebaseFirestore.instance.collection(Paths.church).doc(event.cm.id).collection(Paths.events).doc(e.id!).delete();
//             } else {
//               initEvents.add(e);
//             }
//           }
//         }
        
//         log("The events that were picked up from the event snap is len: " + initEvents.length.toString());
//         emit(state.copyWith(events: initEvents));
//         log("the state events has a len of: " + state.events.length.toString());

//         add(CommunityLoadingPosts(cmId: event.cm.id!));

//     } catch (e) {
//       log("There was an error in the cmBloc communityLoadingEvents: " + e.toString());
//       emit(state.copyWith(failure: Failure(message: "Ops something went wrong")));
//     }
//   }

//   Stream<CommuinityState> _mapCommunityLoadingPostToState(CommunityLoadingPosts event) async* {
//     try {
//       List<Post?> posts = await _churchRepository.getCommuinityPosts(cm: event.cm);
//       emit(state.copyWith(postDisplay: posts));
//     } catch (e) {
//       emit(state.copyWith(failure: Failure(message: "Ops, something went wrong when getting the cm post")));
//     }
//   }


//   // ================== emit methods =======================
//   emitWhenCmIsArmored(bool isMem, CommuintyStatus status, RequestStatus requestStatus) {
//      emit(state.copyWith(
//           isMember: isMem,
//           kingCords: [],
//           postDisplay: [],
//           status: status,
//           requestStatus: requestStatus
//         ));
//   }

//   emitWhenCmIsShielded(bool isMem, List<KingsCord?>? kcs, List<Post?> posts, CommuintyStatus status, RequestStatus requestStatus) {
//     emit(state.copyWith(
//           isMember: isMem,
//           kingCords: kcs,
//           postDisplay: posts,
//           status: status,
//           requestStatus: requestStatus,
//         ));
//   }


//   emitWhenCmIsOpen(bool isMem, List<KingsCord?>? kcs, List<Post?> posts, CommuintyStatus status) {
//     emit(state.copyWith(
//           isMember: isMem,
//           kingCords: kcs,
//           postDisplay: posts,
//           status: status,
//           requestStatus: RequestStatus.none,
//         ));
//   }

//   // ============== funcs =======================

//   Future<void> onLeaveCommuinity({required Church commuinity}) async {
//     final userrId = _authBloc.state.user!.uid;
//     _churchRepository.leaveCommuinity(
//         commuinity: commuinity, leavingUserId: userrId);
//     emit(state.copyWith(isMember: false));
//   }

//   Future<void> onJoinCommuinity(
//       {required Church commuinity, required BuildContext context}) async {
//     bool isBan = await _churchRepository.isBaned(
//         usrId: _authBloc.state.user!.uid, cmId: commuinity.id!);
//     log("the val of is ban: " + isBan.toString());
//     emit(state.copyWith(isBaned: isBan));
//     await Future.delayed(Duration(seconds: 1));

//     if (isBan == false) {
//       log("we are in the conditional, is ban is false");
//       final userrId = _authBloc.state.user!.uid;
//       final user = await _userrRepository.getUserrWithId(userrId: userrId);
//       _churchRepository.onJoinCommuinity(commuinity: commuinity, user: user);
//       commuinity.members[state.currUserr] = {
//         'role': Roles.Member,
//         'timestamp': Timestamp.now(),
//         'userReference': '...'
//       };
//       add(CommunityInitalEvent(commuinity: commuinity));
//       emit(state.copyWith(isMember: true));
//     } else {
//       log("we are in the true, is ban is true");
//       showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               content: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.cancel_outlined,
//                     color: Colors.red,
//                   ),
//                   FittedBox(
//                     child: Text("You Are not allowed"),
//                   ),
//                   FittedBox(
//                     child: Text("to join this community"),
//                   ),
//                   FittedBox(child: Text("at this moment.")),
//                   FittedBox(
//                     child: Text("Possibly due to a ban"),
//                   )
//                 ],
//               ),
//             );
//           });
//     }
//   }

//   Future<void> requestToJoin(Church cm, String usrId) async {
//     FirebaseFirestore.instance.collection(Paths.requestToJoinCm).doc(cm.id).collection(Paths.request).doc(usrId).set({});
//     emit(state.copyWith(requestStatus: RequestStatus.pending));
//   }

//   Future<void> banedUsers({required String communityId}) async {
//     String? lastDocId =
//         state.banedUsers.length > 0 ? state.banedUsers.last.id : null;
//     if (state.banedUsers.length > 0 && lastDocId == null) {
//       return;
//     }
//     log("Getting band users");
//     List<Userr> banedUsers = await _churchRepository.getBanedUsers(
//         cmId: communityId, lastDocId: lastDocId);
//     log("len of get ban users: " + banedUsers.length.toString());
//     List<Userr> updatedBanedUsers = List<Userr>.from(state.banedUsers)
//       ..addAll(banedUsers);
//     log("val of baned users is: " + updatedBanedUsers.length.toString());
//     emit(state.copyWith(banedUsers: updatedBanedUsers));
//   }

//   void unBan({required String cmId, required Userr usr}) {
//     _churchRepository.unBan(cmId: cmId, usrId: usr.id);
//     var x = state.banedUsers;
//     x.remove(usr);
//     emit(state.copyWith(banedUsers: x));
//   }

//   void onBoostCm({required String cmId}) {
//     if (state.boosted != 1) {
//       _churchRepository.onBoostCm(cmId: cmId);
//     }
//     emit(state.copyWith(boosted: 1));
//   }

//   void setTheme({required String cmId, required String theme}) {
//     _churchRepository.setTheme(cmId: cmId, theme: theme);
//     emit(state.copyWith(themePack: theme));
//   }

//   Future<void> delKc(
//       {required KingsCord cord, required Church commuinity}) async {
//     // gives unexpected behavior
//     // should not del kc if only on kc.
//     await _churchRepository.delCord(cmmuinity: commuinity, cord: cord);
//     log("del complete");
//   }

//   Future<void> makeNewKc({
//     required Church commuinity,
//     required String cordName,
//     required BuildContext ctx,
//     required String mode,
//     String? rolesAllowed,
//   }) async {
//     Userr currUser = await _userrRepository.getUserrWithId(
//         userrId: _authBloc.state.user!.uid);
//     log("awaiting ch msg");
//     await _churchRepository.newKingsCord2(
//       ch: commuinity,
//       cordName: formatCordName(cordName),
//       currUser: currUser,
//       mode: mode,
//       rolesAllowed: rolesAllowed,
//     );
//     // WE DO NOT EMIT TO STATE BECAUSE THERE IS ALREDY A STREAM LISTENING FOR KC'S AND THE STREAM EMITS TO STATE
//     // ANY ATTEMPT TO EMIT FROM HERE WHILE THE STREAM IS ACTIVE WILL CAUSE SOME OUT OF RANGE ERRORS.
//   }

//   String formatCordName(String cordName) {
//     String newName = "";
//     for (int i = 0; i < cordName.length; i++) {
//       if (cordName[i] == " ") {
//         newName += "-";
//       } else {
//         newName += cordName[i];
//       }
//     }
//     return newName;
//   }

//   dispose() {
//     state.copyWith(
//         failure: Failure(),
//         isMember: false,
//         kingCords: [],
//         postDisplay: [],
//         status: CommuintyStatus.inital);
//   }

//   void onCollapsedCord() {
//     if (state.collapseCordColumn)
//       emit(state.copyWith(collapseCordColumn: false));
//     else
//       emit(state.copyWith(collapseCordColumn: true));
//   }

//   void onCollapsedVvrColumn() {
//     if (state.collapseVvrColumn)
//       emit(state.copyWith(collapseVvrColumn: false));
//     else
//       emit(state.copyWith(collapseVvrColumn: true));
//   }

//   void onAddEvent({required Event event}) {
//     List<Event?> events = state.events;
//     events.add(event);
//     emit(state.copyWith(events: events));
//   }

//   // KINGSCORD METHODS

// }
