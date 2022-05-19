import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'chatroom_state.dart';

class ChatroomCubit extends Cubit<ChatroomState> {
  //class data
  final StorageRepository _storageRepository;
  final ChatRepository _chatRepository;
  final AuthBloc _authBloc;
  ChatroomCubit({
    required StorageRepository storageRepository,
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
  })  : _storageRepository = storageRepository,
        _chatRepository = chatRepository,
        _authBloc = authBloc,
        super(ChatroomState.initial());
  //methods
  void onUploadImage(File image) {
    emit(state.copyWith(chatImage: image, status: ChatRoomStatus.inital));
  }

  void onIsTyping(bool boolien) {
    emit(state.copyWith(isTyping: boolien));
  }

  //void onTextMessage(String message) {
  //  emit(state.copyWith(textMessage: message));
  //}

  void sendImage(Chat chatId) async {
    emit(state.copyWith(status: ChatRoomStatus.loading));
    final chatImageUrl =
        await _storageRepository.uploadChatImage(image: state.chatImage!);
    final message = Message(
      text: null,
      imageUrl: chatImageUrl,
      date: Timestamp.now(),
    );
    _chatRepository.sendChatMessage(chat: chatId, message: message, senderId: _authBloc.state.user!.uid);
  }

  void sendTextMesage({required Chat chatId, required String textMessage}) {
    final message = Message(
      text: textMessage,
      imageUrl: null,
      date: Timestamp.now(),
    );
    _chatRepository.sendChatMessage(chat: chatId, message: message, senderId: _authBloc.state.user!.uid);
  }
}
