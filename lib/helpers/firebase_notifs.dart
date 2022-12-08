  import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';

import '../models/church_kingscord_model.dart';

Future<void> handleMessage(RemoteMessage message, BuildContext context) async {
    log("MESSAGE.DATA['TYPE'] IS OF VAL: " + message.data['type'].toString());
    if (message.data['type'] == 'kc_type') {
      // type: kc_type has a cmId and a kcId. see cloud functions onMentionedUser for reference
      // var snap = await FirebaseFirestore.instance.collection(Paths.church).doc(message.data['cmId']).collection(Paths.kingsCord).doc(message.data['kcId']).get();

      var snap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(message.data['cmId'])
          .get();

      if (!snap.exists) {
        log("SNAP DOES NOT EXIST OF TYPE kc_type -> RETURNING");
        return;
      }

      if (message.data['kcId'] != null) {
        var snapK = await FirebaseFirestore.instance
            .collection(Paths.church)
            .doc(message.data['cmId'])
            .collection(Paths.kingsCord)
            .doc(message.data['kcId'])
            .get();
        log("does snap k exist?");
        log("snapK: " + snapK.id);
        log(snapK.exists.toString());
        Church? cm = await Church.fromDoc(snap);
        KingsCord? kc = KingsCord.fromDoc(snapK);
        if (kc != null)
          Navigator.of(context).pushNamed(KingsCordScreen.routeName,
              arguments: KingsCordArgs(
                  commuinity: cm.copyWith(),
                  kingsCord: kc,
                  userInfo: {
                    "isMember": true,
                  },
                  usr: context.read<ChatscreenBloc>().state.currUserr));

        return;
      }

      // KingsCord? kc = KingsCord.fromDoc(snap);
      // ignore: unnecessary_null_comparison
      Church? cm = await Church.fromDoc(snap);
      if (cm != null) {

        // log ("PROOF U CAN GET THE KC STILL: " + kc.cordName);
        // update the selected ch of chatscreen bloc w/ ch that is pulled from the noty. or also nav to the message room.
        // Navigator.of(context).pushNamed(CommuinityScreen.routeName,
          //  arguments: CommuinityScreenArgs(commuinity: cm));
        return;
        
      }
      return;
    } else if (message.data['type'] == 'directMsg_type') {
      log("message type is ${message.data['type']}");
      var snap = await FirebaseFirestore.instance
          .collection(Paths.chats)
          .doc(message.data['chatId'])
          .get();

      if (!snap.exists) {
        log("SNAP DOES NOT EXIST OF TYPE directMsg_type -> RETURNING");
        return;
      }
      Chat? chat = await Chat.fromDoc(snap);
      // ignore: unnecessary_null_comparison
      if (chat != null) {
        log("The chat is not null");
        Navigator.of(context)
            .pushNamed(ChatRoom.routeName, arguments: ChatRoomArgs(chat: chat));
        return;
      } else {
        log(" The chat is def null Max");
      }
    } else {
      log("++++++++++++++++++++++++++++++");
      log("Message type did not get cought. see type: ");
      log(message.data['type']);
      log(message.data.toString());
      log("+++++++++++++++++++++++++++++++");
    }
    return;
  }