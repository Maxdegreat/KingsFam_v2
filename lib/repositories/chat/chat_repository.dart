import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/repositories/chat/base_chat_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';

class ChatRepository extends BaseChatRepository {
  final FirebaseFirestore _firebaseFirestore;

  ChatRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Future<Chat?> createChat(
      {required Chat chat, bool? shouldPassBackChat, BuildContext? ctx}) async {
    if (shouldPassBackChat == true) {
      _firebaseFirestore
          .collection(Paths.chats)
          .add(chat.toDoc())
          .then((value) async {
        final chatdoc = await value.get();
        var newChat = await Chat.fromDoc(chatdoc);
        Navigator.pushNamed(ctx!, ChatRoom.routeName,
            arguments: ChatRoomArgs(chat: newChat));
        return;
      });
    } else {
      _firebaseFirestore.collection(Paths.chats).add(chat.toDoc());
    }
    return null;
  }

  Stream<List<Future<Message?>>> getChatMessages(
      {required String chatId, required int limit}) {
    return FirebaseFirestore.instance
        .collection(Paths.chats)
        .doc(chatId)
        .collection(Paths.messages)
        .limit(limit)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
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
        .where('memRefs',
            arrayContains:
                FirebaseFirestore.instance.collection(Paths.users).doc(userId))
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Chat.fromDoc(doc)).toList());
  }

  @override
  void sendChatMessage(
      {required Chat chat,
      required Message message,
      required String senderId}) {
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
    if (doc.exists) return Chat.fromDoc(doc);
    return null;
  }

  @override
  Future<void> updateChat({required Chat chat}) async {
    _firebaseFirestore
        .collection(Paths.chats)
        .doc(chat.id)
        .update(chat.toDoc());
  }

  Future<void> leaveChat(
      {required String chatId, required String userId}) async {
    final chatDocRef = _firebaseFirestore.collection(Paths.chats).doc(chatId);

    _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot chatSnap = await transaction.get(chatDocRef);

      if (!chatSnap.exists) {
        throw Exception("chatSnap does not exist! in chatRepo leavechat");
      }

      // make curr docRef to remove
      DocumentReference currDocRef =
          _firebaseFirestore.collection(Paths.users).doc(userId);

      Map<String, dynamic> data = chatSnap.data() as Map<String, dynamic>;
      List<DocumentReference> updatedMemRefs = List.from(data['memRefs']);
      updatedMemRefs.remove(currDocRef);

      if (updatedMemRefs.isEmpty) {
        transaction.delete(chatDocRef);
      }

      transaction.update(chatDocRef, {"memRefs": updatedMemRefs});
    });
  }

  Future<void> updateUserActivity({required String chatId, required String usrId, required bool isActive}) async {

    final chatDocRef = _firebaseFirestore.collection(Paths.chats).doc(chatId);

    if (isActive) {
      
    _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot chatSnap = await transaction.get(chatDocRef);

      if (!chatSnap.exists) {
        throw Exception("chatSnap does not exist! in chatRepo updateUserActivity");
      }

      // make curr docRef to remove
      DocumentReference currDocRef =
          _firebaseFirestore.collection(Paths.users).doc(usrId);

      Map<String, dynamic> data = chatSnap.data() as Map<String, dynamic>;
      List<String> activeMems = List.from(data['activeMems']);
      if (!activeMems.contains(usrId)) {
        activeMems.add(usrId);
      }

      transaction.update(chatDocRef, {"activeMems": activeMems});
    });
    } else {
      _firebaseFirestore.runTransaction((transaction) async {
      DocumentSnapshot chatSnap = await transaction.get(chatDocRef);

      if (!chatSnap.exists) {
        throw Exception("chatSnap does not exist! in chatRepo updateUserActivity");
      }

      // make curr docRef to remove
      DocumentReference currDocRef =
          _firebaseFirestore.collection(Paths.users).doc(usrId);

      Map<String, dynamic> data = chatSnap.data() as Map<String, dynamic>;
      List<String> activeMems = List.from(data['activeMems']);
      if (activeMems.contains(usrId)) {
        activeMems.remove(usrId);
      }

      transaction.update(chatDocRef, {"activeMems": activeMems});
    });
    }
  }
}
