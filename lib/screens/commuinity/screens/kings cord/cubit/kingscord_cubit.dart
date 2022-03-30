import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/kingscord_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'kingscord_state.dart';

class KingscordCubit extends Cubit<KingscordState> {
  // the class data
  final StorageRepository _storageRepository;
  final AuthBloc _authBloc;
  final KingsCordRepository _kingsCordRepository;
  //gen the constructor
  KingscordCubit(
      {required StorageRepository storageRepository,
      required AuthBloc authBloc,
      required KingsCordRepository kingsCordRepository})
      : _storageRepository = storageRepository,
        _authBloc = authBloc,
        _kingsCordRepository = kingsCordRepository,
        super(KingscordState.initial());
  // time for some methods babby

  // is typing
  void onIsTyping(bool isTyping) {
    emit(state.copyWith(isTyping: isTyping, status: KingsCordStatus.initial));
  }

  //send a txt Messagse
  void onSendTxtMsg(
      {required String churchId,
      required String kingsCordId,
      required String txtMsgBody}) {
    // the creation of the message
    final message = Message(
        senderId: _authBloc.state.user!.uid,
        text: txtMsgBody,
        date: Timestamp.fromDate(DateTime.now()),
        imageUrl: null);
    //uploading the message to cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId, kingsCordId: kingsCordId, message: message);
  }



  //getter for image
  void onUploadImage(File imageFile) {
    emit(state.copyWith(txtImgUrl: imageFile, status: KingsCordStatus.initial));
  }

  void onSendTxtImg(
      {required String churchId, required String kingsCordId,}) async {
    //set to load bc we wait for image to be sent.
    emit(state.copyWith(status: KingsCordStatus.loading));
    final chatImageUrl = await
      _storageRepository.uploadKingsCordImage(imageFile: state.txtImgUrl!);
    //make the message
    final message = Message(
      senderId: _authBloc.state.user!.uid,
      date: Timestamp.now(),
      imageUrl: chatImageUrl,
      text: null,
    );
    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId, kingsCordId: kingsCordId, message: message);
    //set state back to initial
    emit(state.copyWith(status: KingsCordStatus.initial));
  }

  

   Future<void> updateUserMap({required String userId, required Church commuinity, required KingsCord kingsCord}) async {
    // get the user
    Userr user = await UserrRepository().getUserrWithId(userrId: userId);
    
    // make the new map
    Map<String, dynamic> userMap = {
      'isAdmin' : commuinity.memberInfo[userId]["isAdmin"],
      'username': user.username,
      'pfpImageUrl': user.profileImageUrl,
      'colorPref' : user.colorPref,
      'email': user.email,
      'token': user.token,
    };

    // replace key value of old map with new map
    commuinity.memberInfo[userId] = userMap;
    // grab path to commuinit
    var path = FirebaseFirestore.instance.collection(Paths.church).doc(commuinity.id).collection(Paths.kingsCord).doc(kingsCord.id);
    // update the usermap in commuinity
    path.update({"memberInfo":commuinity.memberInfo});
  }

}
