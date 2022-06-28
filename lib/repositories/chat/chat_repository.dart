import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/repositories/chat/base_chat_repository.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';

class ChatRepository extends BaseChatRepository {
  final FirebaseFirestore _firebaseFirestore;

  ChatRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;


  @override
  Future<Chat?> createChat({required Chat chat, bool? shouldPassBackChat, BuildContext? ctx}) async {
  
    if (shouldPassBackChat == true) {
      log("77777777777777777777777777777");
      _firebaseFirestore.collection(Paths.chats).add(chat.toDoc()).then((value) async {
        final chatdoc = await value.get();
        var newChat = await Chat.fromDoc(chatdoc);
        Navigator.pushNamed(ctx!, ChatRoom.routeName, arguments: ChatRoomArgs(chat: newChat));
        return ;
      });
    } else {
      _firebaseFirestore.collection(Paths.chats).add(chat.toDoc());
    }
    return null;
  }

  Stream<List<Future<Message?>>> getChatMessages({required String chatId, required int limit}) {
    return FirebaseFirestore.instance.collection(Paths.chats)
      .doc(chatId).collection(Paths.messages).limit(limit).orderBy('date', descending: true).snapshots().map((snap) {
         List<Future<Message?>> bucket = [];
         snap.docs.forEach((doc) { 
           Future<Message?> msg = Message.fromDoc(doc);
           bucket.add(msg);
        });
        return bucket;
      });
      
  }

  @override
  Stream<List<Future<Chat?>>> getUserChats({required String userId}) {
    return _firebaseFirestore
        .collection(Paths.chats)
        .where('memRefs', arrayContains: FirebaseFirestore.instance.collection(Paths.users).doc(userId))
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Chat.fromDoc(doc)).toList());
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
  Future<Chat?> getChatWithId({required String chatId}) async {
    final doc =
        await _firebaseFirestore.collection(Paths.chats).doc(chatId).get();
    if (doc.exists)
      return Chat.fromDoc(doc);
    return null;
  }

  @override
  Future<void> updateChat({required Chat chat}) async {
    _firebaseFirestore
        .collection(Paths.chats)
        .doc(chat.id)
        .update(chat.toDoc());
  }

  Future<void> grabChatWithUserIds(String user1Id, String user2Id) async {
    //_firebaseFirestore.collection(Paths.chats).where(field)
    //TODO MAKE THIS WORK. FIRST I WANT TO ADD SOME THINGS TO THE CM CHAT AS EX
  }
}
