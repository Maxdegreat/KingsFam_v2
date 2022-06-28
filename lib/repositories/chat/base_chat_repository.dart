import 'package:flutter/cupertino.dart';
import 'package:kingsfam/models/models.dart';

abstract class BaseChatRepository {
  void sendChatMessage({required Chat chat, required Message message, required String senderId});
  Future<Chat?> createChat({required Chat chat, bool? shouldPassBackChat, BuildContext? ctx});
  Stream<List<Future<Chat?>>> getUserChats({required String userId});
  Future<Chat?> getChatWithId({required String chatId});
  Future<void> updateChat({required Chat chat});
}
