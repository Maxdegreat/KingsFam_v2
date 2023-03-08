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
import 'package:kingsfam/config/kc_meta_data.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
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
  FirebaseFirestore ff = FirebaseFirestore.instance;

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

  /*Future<List<Userr>>*/ void searchMentionedUsers(
      {required String username, required String cmId}) async {
    var snap = await fire
        .collection(Paths.communityMembers)
        .doc(cmId)
        .collection(Paths.members)
        .where("userNameCaseList", arrayContains: username)
        .limit(7)
        .get();
    List<Userr> users = [];
    for (var j in snap.docs) {
      Userr user = await UserrRepository().getUserrWithId(userrId: j.id);
      users.add(user);
    }
    if (username.isEmpty) {
      emit(state.copyWith(potentialMentions: []));
    } else {
      emit(state.copyWith(potentialMentions: users));
    }
  }

  Future<void> getInitPotentialMentions(String cmId) async {
    if (state.initPM.isEmpty) {
      CollectionReference colR = FirebaseFirestore.instance
          .collection(Paths.communityMembers)
          .doc(cmId)
          .collection(Paths.members);
      QuerySnapshot docSaps = await colR.limit(4).get();
      List<Userr> users = [];
      for (DocumentSnapshot s in docSaps.docs) {
        Userr u = await UserrRepository().getUserrWithId(userrId: s.id);
        users.add(u);
      }
      List<Userr> initPMs = List<Userr>.from(state.initPM)..addAll(users);
      emit(state.copyWith(initPM: initPMs));
    }

    emit(state.copyWith(potentialMentions: state.initPM));
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

  void onLoadInit(
      {required String cmId, required String kcId, required int limit}) async {
        
    emit(state.copyWith(status: KingsCordStatus.getInitmsgs));
    emit(state.copyWith(msgs: [], recentMsgIdToTokenMap: {}));

    paginateMsg(cmId: cmId, kcId: kcId, limit: limit);
  }

  Future<void> paginateMsg(
      {required String cmId, required String kcId, required int limit}) async {
    try {
      if (state.msgs.isEmpty) {
        // this is a temp set to be used for copywith. copy x num most recent users
        // into the recentnotif list (granted not all of them will get a noty bc opt options)
        Map<String, dynamic> recentMsgIdTokenForOpt = {};

        //int limit = 45;
        _msgStreamSubscription?.cancel();
        _msgStreamSubscription = _churchRepository
            .getMsgStream(
                cmId: cmId, kcId: kcId, limit: limit, lastPostDoc: null)
            .listen((msgs) async {
          // final allMsgs = await Future.wait(msgs);
          List<Message> allMsgs = [];
          for (int i = 0; i < msgs.length; i++) {
            Message? m = await msgs[i];
            if (m != null) {
              if (m.replyMsg != null) {
                m.copyWith(replyMsg: m);
              }
              allMsgs.add(m);
              // get the most recent ids
              int count = 0;
              for (var x in allMsgs) {
                count += 1;
                if (state.recentNotifLst.contains(x))
                  recentMsgIdTokenForOpt[x.sender!.id] = x.sender!.token;
                if (count == 15) {
                  break;
                }
              }
            }
          }

          emit(state.copyWith(
              msgs: allMsgs, recentMsgIdToTokenMap: recentMsgIdTokenForOpt));
          // log("recentMsgIds: " + state.recentMsgIdToTokenMap.toString());
          // log("roomSettings: " + state.recentNotifLst.toString() + " all now: " + state.allNotifLst.toString());
          emit(state.copyWith(status: KingsCordStatus.initial));
        });
      } else {
        emit(state.copyWith(status: KingsCordStatus.pagMsgs));
        log("okay we should now pag");

        if (state.msgs.isEmpty) return;
        String? lastDocId = state.msgs.last!.id;
        // paginate in repo and store lst in new lst.
        List<Message?> messages = await _churchRepository.paginateMsg(
            cmId: cmId, kcId: kcId, lastDocId: lastDocId, limit: limit);
        log(messages.length.toString());
        List<Message?> stateMsg = state.msgs;
        for (var msg in messages) {
          stateMsg.add(msg);
        }
        // pass that updated lst into kc.
        // log("value OF STATE.MSG IS (before) " + state.msgs.toString());

        emit(state.copyWith(msgs: stateMsg, status: KingsCordStatus.initial));
        // log("value OF STATE.MSG IS " + state.msgs.toString());
      }
    } catch (e) {
      log("There was an error in the kingscord cubit");
      log("error in method paginateMsg, code is: " + e.toString());
    }
  }

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
    required Message? reply,
    Map<String, dynamic>? metadata = const {},
  }) async {
    log("metadata is null: " + (metadata == null).toString());

    metadata!["kcName"] = kingsCordData.cordName;
    if (reply != null) {
      metadata["replyId"] = reply.id;
    }

    final message = Message(
      text: txtMsgBodyWithSymbolsForParcing,
      date: Timestamp.fromDate(DateTime.now()),
      imageUrl: null,
      senderUsername: currUserName,
      metadata: metadata,
      mentionedIds: mentionedInfo.keys.toSet().toList(),
    );

    _kingsCordRepository.sendMsgTxt(
        churchId: churchId,
        kingsCordId: kingsCordId,
        message: message,
        senderId: _authBloc.state.user!.uid);
  }

  Future<void> onSendGiphyMessage({
    required String giphyId,
    required String cmId,
    required String kcId,
    required String currUsername,
  }) async {
    // make message that sends Giphy
    Message m = Message(
      date: Timestamp.now(),
      giphyId: giphyId,
      senderUsername: currUsername,
    );
    try {
      // send msg via krepo
      await _kingsCordRepository.onSendGiphyMessage(
        cmId: cmId,
        giphyId: giphyId,
        kcId: kcId,
        msg: m,
        senderId: _authBloc.state.user!.uid,
      );
      // return bool value
      // return true;

    } catch (e) {
      log("error in kingsCordCubit");
      log("error in onSendGiphyMessage: " + e.toString());
    }
  }

  void onUploadVideo(
      {required File videoFile,
      required String kcId,
      required String cmId,
      required String senderUsername}) async {
    emit(state.copyWith(
      status: KingsCordStatus.loading,
    ));
    // make the thumbnail
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 70,
    );
    if (thumbnail == null)
      return
          // add thumbnail to queue
          log("abt to add $thumbnail into the queue");
    state.filesToBePosted.addFirst(File(thumbnail));
    print("added $thumbnail in the queue");
    FileShareStatus fileShareStatus = FileShareStatus.imgSharing;
    emit(state.copyWith(
        fileShareStatus: fileShareStatus,
        filesToBePosted: state.filesToBePosted));
    // store the thumbnail
    final thumbnailUrl = await _storageRepository.uploadThumbnailVideo(
        thumbnail: File(thumbnail));
    // pass vid to storage
    final videoUrl = await _storageRepository.uploadchatVideo(video: videoFile);
    // make message
    final message = Message(
        date: Timestamp.now(),
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        senderUsername: senderUsername);
    // send the message to the cloud:::::
    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: cmId,
        kingsCordId: kcId,
        message: message,
        senderId: _authBloc.state.user!.uid);
    if (state.filesToBePosted.isEmpty) {
      fileShareStatus = FileShareStatus.inital;
      emit(state.copyWith(
          status: KingsCordStatus.loading,
          fileShareStatus: fileShareStatus,
          filesToBePosted: state.filesToBePosted));
      return;
    } else {
      fileShareStatus = FileShareStatus.imgSharing;
      state.filesToBePosted.removeLast();
      if (state.filesToBePosted.isEmpty) {
        emit(state.copyWith(
            filesToBePosted: state.filesToBePosted,
            fileShareStatus: FileShareStatus.inital));
        return;
      } else
        emit(state.copyWith(
            filesToBePosted: state.filesToBePosted,
            fileShareStatus: fileShareStatus));
      log("did an else queue best not be empty");
    }
  }

  void onUploadImage(File imageFile) {
    state.filesToBePosted.addFirst(imageFile);
    emit(state.copyWith(txtImgUrl: imageFile, status: KingsCordStatus.initial));
  }

  onSendTxtImg(
      {required String churchId,
      required String kingsCordId,
      required String senderUsername}) async {
    //set to load bc we wait for image to be sent.
    emit(state.copyWith(
        status: KingsCordStatus.loading,
        fileShareStatus: FileShareStatus.imgSharing));

    final chatImageUrl = await _storageRepository.uploadKingsCordImage(
        imageFile: state.txtImgUrl!);

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

    emit(state.copyWith(
        status: KingsCordStatus.initial,
        fileShareStatus: fileShareStatus,
        filesToBePosted: state.filesToBePosted));
  }

  addReply(Message m) {
    emit(state.copyWith(replyMessage: m));
  }

  removeReply() {
    emit(state.copyWith(replyMessage: null));
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
