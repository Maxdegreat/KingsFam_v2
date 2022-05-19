import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/message_model.dart';

import 'package:kingsfam/repositories/chat/base_chat_repository.dart';

class ChatRepository extends BaseChatRepository {
  final FirebaseFirestore _firebaseFirestore;

  ChatRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createChat({required Chat chat}) async {
    _firebaseFirestore.collection(Paths.chats).add(chat.toDoc());
  }

  @override
  Stream<List<Future<Chat?>>> getUserChats({required String userId}) {
    return _firebaseFirestore
        .collection(Paths.chats)
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Chat.fromDocAsync(doc)).toList());
  }

  @override
  void sendChatMessage({required Chat chat, required Message message, required String senderId}) {
    _firebaseFirestore
        .collection(Paths.chats)
        .doc(chat.id)
        .collection(Paths.messages)
        .add(message.ToDoc(senderId: senderId));
  }

  @override
  Future<Chat> getChatWithId({required String chatId}) async {
    final doc =
        await _firebaseFirestore.collection(Paths.chats).doc(chatId).get();
    return doc.exists ? Chat.fromDoc(doc) : Chat.empty;
  }

  @override
  Future<void> updateChat({required Chat chat}) async {
    _firebaseFirestore
        .collection(Paths.chats)
        .doc(chat.id)
        .update(chat.toDoc());
  }
}
