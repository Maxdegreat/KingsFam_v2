// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';                                                                                                    
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chat_room_settings/cubit/roomsettings_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

part 'kingscord_state.dart';

class KingscordCubit extends Cubit<KingscordState> {
  // the class data
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final KingsCordRepository _kingsCordRepository;
  final ChurchRepository _churchRepository;

  StreamSubscription<List<Future<Message?>>>? _msgStreamSubscription;

  //gen the constructor
  KingscordCubit({
    required StorageRepository storageRepository,
    required AuthBloc authBloc,
    required KingsCordRepository kingsCordRepository,
    required ChurchRepository churchRepository,
  })  : _storageRepository = storageRepository,
        _authBloc = authBloc,
        _kingsCordRepository = kingsCordRepository,
        _churchRepository = churchRepository,
        super(KingscordState.initial());

  @override
  Future<void> close() {
    _msgStreamSubscription!.cancel();
    return super.close();
  }
  
  var fire = FirebaseFirestore.instance; 

  /*Future<List<Userr>>*/ void searchMentionedUsers({required String username, required String cmId}) async {
    var snap = await fire.collection(Paths.communityMembers).doc(cmId).collection(Paths.members).where("userNameCaseList", arrayContains: username).limit(7).get();
    List<Userr> users = [];
    for (var j in snap.docs) {
      Userr user = await UserrRepository().getUserrWithId(userrId: j.id);
      users.add(user);
    }
    emit(state.copyWith(potentialMentions: users));
  }

  void selectMention({required Userr userr}) {
    // add to the mentioned list or whatever
    if (!state.mentions.contains(userr)) {
      List<Userr> m = List.from(state.mentions)..add(userr);
      emit(state.copyWith(mentions: m));
    }
   }

   void removeMention({required Userr userr}) {
     if (state.mentions.contains(userr)) {
      List<Userr> m = List.from(state.mentions)..remove(userr);
      emit(state.copyWith(mentions: m));
    }
   }

   void clearMention() {
    emit(state.copyWith(mentions: []));
   }

  void onLoadInit({required String cmId, required String kcId, required int limit}) async {
    // I need to load the all list and the recent list
    // then update the state with the users who are opt in

    await getNotifLst(cmId: cmId, kcId: kcId);

    // this is a temp set to be used for copywith. copy x num most recent users
    // into the recentnotif list (granted not all of them will get a noty bc opt options) 
    Map<String, dynamic> recentMsgIdTokenForOpt = {};

    //int limit = 45;
    _msgStreamSubscription?.cancel();
    _msgStreamSubscription = _churchRepository
        .getMsgStream(cmId: cmId, kcId: kcId, limit: limit)
        .listen((msgs) async {
      final allMsgs = await Future.wait(msgs);
      // get the most recent ids
      int count = 0;
      for (var x in allMsgs) {
        count += 1;
        if (state.recentNotifLst.contains(x))
          recentMsgIdTokenForOpt[x!.sender!.id] = x.sender!.token;
        if (count == 15) {
          break;
        }
      }
      emit(state.copyWith(msgs: allMsgs, recentMsgIdToTokenMap: recentMsgIdTokenForOpt));
      // log("recentMsgIds: " + state.recentMsgIdToTokenMap.toString());
      // log("roomSettings: " + state.recentNotifLst.toString() + " all now: " + state.allNotifLst.toString());
    });
  }
  // time for some methods babby

  // onReply
  // void onReplyMessage({required Message? replyingToMessage}) {
  //   if (replyingToMessage == null) {
  //     replyingToMessage = Message.empty();
  //   }
  //   log("val of replymsg is: " + replyingToMessage.toString());
  //   emit(state.copyWith(replyMessage: replyingToMessage, replying: replyingToMessage == Message.empty() ? false : true));
  // }
  // is typing
  void onIsTyping(bool isTyping) {
    emit(state.copyWith(isTyping: isTyping, status: KingsCordStatus.initial));
  }

  //send a txt Messagse
  void onSendTxtMsg({
    required String churchId,
    required String kingsCordId,
    required String txtMsgBodyWithSymbolsForParcing,
    required String txtMsgWithOutSymbolesForParcing,
    required Map<String, dynamic> mentionedInfo,
    required String cmTitle,
    required KingsCord kingsCordData,
    required String currUserName, // aka sender username
  }) async {
    log("recent: " + state.recentNotifLst.toString());
    log("all: " + state.allNotifLst.toString());
    // This should tell the cloud that the mentioned id was mentioned through the cloud
    // I have added the function to send a noti to the users phone. the update for this to happen is in the
    // functions index.js file
    for (var id in mentionedInfo.keys) {
      if (txtMsgBodyWithSymbolsForParcing.length > 1 && txtMsgBodyWithSymbolsForParcing.length < 450) {
        FirebaseFirestore.instance
            .collection(Paths.mention)
            .doc(id)
            .collection(churchId)
            .doc(kingsCordId).set({
          'communityName': mentionedInfo[id]['communityName'],
          'username': mentionedInfo[id]['username'],
          'token': mentionedInfo[id]['token'],
          'messageBody': txtMsgWithOutSymbolesForParcing,
          'type': 'kc_type',
          // 'type_id': kingsCordData.id!,
          // 'type_tag': kingsCordData.tag,
          // 'type_cordName': kingsCordData.cordName,
          // 'type_members': kingsCordData.members,
        });
      }
    }

    List<String> toSendNotifications = state.allNotifLst;
    List<dynamic> toSendNotificationsT = state.recentMsgIdToTokenMap.values.toList();
    for (var i in toSendNotifications) {
      if (state.recentMsgIdToTokenMap.containsKey(i)) 
        continue;
      else {
        Userr userr = await UserrRepository().getUserrWithId(userrId: i);
        // currently tokens are updated so each NEW user should only havb a  single token
        toSendNotificationsT.add(userr.token[0]); 
      }
    }

   
    log("the tokens in sendToDevicies: " + toSendNotificationsT.toString());

    FirebaseFirestore.instance
      .collection(Paths.kcMsgNotif)
      .doc(churchId)
      .collection(Paths.kingsCord).
      doc(kingsCordId).set({
        'communityName': cmTitle,
        'username': currUserName,
        'token' : toSendNotificationsT.toList(),
        'messageBody': txtMsgWithOutSymbolesForParcing,
        'type': 'kc_type',
      }).then((value) => log ("kcMsgNotif added"))
        .catchError((error) => log("Failed to add user: $error"));

    // the creation of the message
    final message = Message(
        text: txtMsgBodyWithSymbolsForParcing,
        date: Timestamp.fromDate(DateTime.now()),
        imageUrl: null,
        senderUsername: currUserName,
      );
    
    // uploading the message to cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId,
        kingsCordId: kingsCordId,
        message: message,
        senderId: _authBloc.state.user!.uid);
  }

  
  void onUploadVideo({required File videoFile, required String kcId, required String cmId, required String senderUsername}) async {
    emit(state.copyWith(status: KingsCordStatus.loading, ));
    // make the thumbnail
    final thumbnail = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
          quality: 100,
        );
    if (thumbnail == null)
      return
    // add thumbnail to queue
    print("abt to add $thumbnail into the queue");
    state.filesToBePosted.addFirst(File(thumbnail));
    print("added $thumbnail in the queue");
    FileShareStatus fileShareStatus = FileShareStatus.imgSharing;
    emit(state.copyWith(fileShareStatus: fileShareStatus, filesToBePosted: state.filesToBePosted));
    // store the thumbnail
    final  thumbnailUrl = await _storageRepository.uploadThumbnailVideo(thumbnail: File(thumbnail));
    // pass vid to storage
    final videoUrl = await _storageRepository.uploadchatVideo(video: videoFile);
    // make message
    final message = Message(date: Timestamp.now(), thumbnailUrl: thumbnailUrl, videoUrl: videoUrl, senderUsername: senderUsername);
    // send the message to the cloud:::::
    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: cmId,
        kingsCordId: kcId,
        message: message,
        senderId: _authBloc.state.user!.uid);
      if (state.filesToBePosted.isEmpty){
        fileShareStatus = FileShareStatus.inital;
        emit(state.copyWith(status: KingsCordStatus.loading, fileShareStatus: fileShareStatus, filesToBePosted:  state.filesToBePosted));
        return ;
      }
      else {
        fileShareStatus = FileShareStatus.imgSharing;
        state.filesToBePosted.removeLast();
        if (state.filesToBePosted.isEmpty) {
          emit(state.copyWith(filesToBePosted: state.filesToBePosted, fileShareStatus: FileShareStatus.inital));
          return ;
        } else emit(state.copyWith(filesToBePosted: state.filesToBePosted, fileShareStatus: fileShareStatus));
        log("did an else queue best not be empty");
      }
  }

  void onUploadImage(File imageFile) {
    state.filesToBePosted.addFirst(imageFile);
    emit(state.copyWith(txtImgUrl: imageFile, status: KingsCordStatus.initial));
  }



  onSendTxtImg({required String churchId, required String kingsCordId, required String senderUsername}) async {
    //set to load bc we wait for image to be sent.
    emit(state.copyWith(status: KingsCordStatus.loading, fileShareStatus: FileShareStatus.imgSharing));
    
    final chatImageUrl = await _storageRepository.uploadKingsCordImage(imageFile: state.txtImgUrl!);
    
    //make the message
    final message = Message(
      date: Timestamp.now(),
      imageUrl: chatImageUrl,
      text: null,
      senderUsername: senderUsername,
    );

    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId,
        kingsCordId: kingsCordId,
        message: message,
        senderId: _authBloc.state.user!.uid);

    // if you look in this.onUploadImage you will see where we add the file. now we remove it
    state.filesToBePosted.removeLast();
    var fileShareStatus = FileShareStatus.inital;
    if (state.filesToBePosted.length != 0)
      fileShareStatus = FileShareStatus.imgSharing;

    emit(state.copyWith(status: KingsCordStatus.initial, fileShareStatus: fileShareStatus, filesToBePosted: state.filesToBePosted));
  }


  Future<void> getNotifLst({required String cmId, required String kcId}) async {
    DocumentReference ref = FirebaseFirestore.instance.collection(Paths.church).doc(cmId)
      .collection(Paths.kingsCord).doc(kcId)
      .collection(Paths.roomSettings).doc(kcId);

    DocumentSnapshot snap = await ref.get();
    if (snap.exists) {
      // now I need to store the curr list in local state
      Map<String, dynamic> data = snap.data() as Map<String, dynamic>;


      List<String> r = List.from(data["recent"]);
      List<String> a = List.from(data["all"]);

      emit(state.copyWith(recentNotifLst: r, allNotifLst: a));
    } else {
      emit(state.copyWith(recentNotifLst: [], allNotifLst: []));
    }
    
  }



  // for upword pagination just go to the top and add the next 10 or so to the begining of the list.

  String getShortReply(String? txt) {
    if (txt == null) {
      return " Shared something ";
    } else if (txt.length > 16) {
      return txt.substring(0, 15);
    } else {
      return txt;
    }
  }
}
