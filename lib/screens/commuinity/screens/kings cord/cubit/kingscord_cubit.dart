import 'dart:async';
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
  final ChurchRepository _churchRepository;
  
 StreamSubscription<List<Future<Message?>>>? _msgStreamSubscription;  

  //gen the constructor
  KingscordCubit(
      {required StorageRepository storageRepository,
      required AuthBloc authBloc,
      required KingsCordRepository kingsCordRepository,
      required ChurchRepository churchRepository,
    })
      : _storageRepository = storageRepository,
        _authBloc = authBloc,
        _kingsCordRepository = kingsCordRepository,
        _churchRepository = churchRepository,
        super(KingscordState.initial());


    @override
    Future<void> close() {
      _msgStreamSubscription!.cancel();
      return super.close();
    }

    void onLoadInit({required String cmId, required String kcId, required int limit}) async {
    int limit = 45;
    _msgStreamSubscription?.cancel();
    _msgStreamSubscription = _churchRepository.
     getMsgStream(cmId: cmId, kcId: kcId, limit: limit)
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
  void onSendTxtMsg(
      {required String churchId,
      required String kingsCordId,
      required String txtMsgBody}) {
    // the creation of the message
    final message = Message(
        text: txtMsgBody,
        date: Timestamp.fromDate(DateTime.now()),
        imageUrl: null);
    //uploading the message to cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId, kingsCordId: kingsCordId, message: message, senderId: _authBloc.state.user!.uid);
  }



  //getter for image
  void onUploadImage(File imageFile) {
    emit(state.copyWith(txtImgUrl: imageFile, status: KingsCordStatus.initial));
  }

  void onSendTxtImg({required String churchId, required String kingsCordId}) async {
    //set to load bc we wait for image to be sent.
    emit(state.copyWith(status: KingsCordStatus.loading));
    final chatImageUrl = await _storageRepository.uploadKingsCordImage(imageFile: state.txtImgUrl!);
    //make the message
    final message = Message(
      date: Timestamp.now(),
      imageUrl: chatImageUrl,
      text: null,

    );
    //upload message to the cloud
    _kingsCordRepository.sendMsgTxt(
        churchId: churchId, kingsCordId: kingsCordId, message: message, senderId: _authBloc.state.user!.uid);
    
    emit(state.copyWith(status: KingsCordStatus.initial));
  }

  

   

}
