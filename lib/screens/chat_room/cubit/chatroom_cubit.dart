import 'dart:async';
import 'dart:developer';
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
  StreamSubscription<List<Future<Message?>>>? _msgStreamSubscription;
  ChatroomCubit({
    required StorageRepository storageRepository,
    required ChatRepository chatRepository,
    required AuthBloc authBloc,
  })  : _storageRepository = storageRepository,
        _chatRepository = chatRepository,
        _authBloc = authBloc,
        super(ChatroomState.initial());
  //methods

  @override
  Future<void> close() {
    _msgStreamSubscription!.cancel();
    return super.close();
  }

  void onLoadInit({required String chatId, required int limit}) async {
    int limit = 45;
    _msgStreamSubscription?.cancel();
    _msgStreamSubscription = _chatRepository
        .getChatMessages(chatId: chatId, limit: limit)
        .listen((messages) async {
      final msgs = await Future.wait(messages);
      log("The length of messages is ${messages.length}");
      emit(state.copyWith(msgs: msgs));
    });
  }

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
    _chatRepository.sendChatMessage(
        chat: chatId, message: message, senderId: _authBloc.state.user!.uid);
  }

  void sendTextMesage({required Chat chatId, required String textMessage, required String senderUsername}) {
    final message = Message(
      text: textMessage,
      imageUrl: null,
      date: Timestamp.now(),
      senderUsername: senderUsername,
    );
    _chatRepository.sendChatMessage(
        chat: chatId, message: message, senderId: _authBloc.state.user!.uid);
  }
}
