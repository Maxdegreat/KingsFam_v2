import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
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

  void onLoadInit(
      {required String cmId, required String kcId, required int limit}) async {
    int limit = 45;
    _msgStreamSubscription?.cancel();
    _msgStreamSubscription = _churchRepository
        .getMsgStream(cmId: cmId, kcId: kcId, limit: limit)
        .listen((msgs) async {
      final allMsgs = await Future.wait(msgs);
      emit(state.copyWith(msgs: allMsgs));
    });
  }
  // time for some methods babby

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
  }) {
    // This should tell the cloud that the mentioned id was mentioned through the cloud
    // I have added the function to send a noti to the users phone. the update for this to happen is in the
    // functions index.js file

    for (var id in mentionedInfo.keys) {
      if (txtMsgBodyWithSymbolsForParcing.length > 1 && txtMsgBodyWithSymbolsForParcing.length < 250) {
        FirebaseFirestore.instance
            .collection(Paths.mention)
            .doc(id)
            .collection(churchId)
            .doc(kingsCordId)
            .set({
          'communityName': mentionedInfo[id]['communityName'],
          'username': mentionedInfo[id]['username'],
          'token': mentionedInfo[id]['token'],
          'messageBody': txtMsgWithOutSymbolesForParcing,
          'type': 'kc_type',
          'type_id': kingsCordData.id!,
          'type_tag': kingsCordData.tag,
          'type_cordName': kingsCordData.cordName,
          'type_recentSender': kingsCordData.recentSender,
          'type_recentMessage': kingsCordData.recentMessage,
          'type_members': kingsCordData.members,
        });
      }
    }

    // the creation of the message
    final message = Message(
        text: txtMsgBodyWithSymbolsForParcing,
        date: Timestamp.fromDate(DateTime.now()),
        imageUrl: null);
    //uploading the message to cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId,
        kingsCordId: kingsCordId,
        message: message,
        senderId: _authBloc.state.user!.uid);
  }

  
  void onUploadVideo({required File videoFile, required String kcId, required String cmId}) async {
    emit(state.copyWith(status: KingsCordStatus.loading, fileShareStatus: FileShareStatus.imgSharing));
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
    state.filesToBePosted.addFirst(File(thumbnail!));
    // store the thumbnail
    final  thumbnailUrl = await _storageRepository.uploadThumbnailVideo(thumbnail: File(thumbnail));
    // pass vid to storage
    final videoUrl = await _storageRepository.uploadchatVideo(video: videoFile);
    // make message
    final message = Message(date: Timestamp.now(), thumbnailUrl: thumbnailUrl, videoUrl: videoUrl,);
    // send the message to the cloud:::::
    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: cmId,
        kingsCordId: kcId,
        message: message,
        senderId: _authBloc.state.user!.uid);
  state.filesToBePosted.removeLast();
  emit(state.copyWith(status: KingsCordStatus.loading, fileShareStatus: FileShareStatus.inital, filesToBePosted:  state.filesToBePosted));
  }

  void onUploadImage(File imageFile) {
    state.filesToBePosted.addFirst(imageFile);
    emit(state.copyWith(txtImgUrl: imageFile, status: KingsCordStatus.initial));
  }



  onSendTxtImg({required String churchId, required String kingsCordId}) async {
    //set to load bc we wait for image to be sent.
    emit(state.copyWith(status: KingsCordStatus.loading, fileShareStatus: FileShareStatus.imgSharing));

    final chatImageUrl = await _storageRepository.uploadKingsCordImage(imageFile: state.txtImgUrl!);
    
    //make the message
    final message = Message(
      date: Timestamp.now(),
      imageUrl: chatImageUrl,
      text: null,
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
}
