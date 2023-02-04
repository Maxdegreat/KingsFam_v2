  import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';

Future<void> handleMessage(RemoteMessage message, BuildContext context) async {
    log("MESSAGE.DATA['TYPE'] IS OF VAL: " + message.data['type'].toString());
    log("MESSAGE.DATA: " +  message.data.toString());
    
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
      } else log("snap exists");

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
        if (kc != null) {
          context.read<ChatscreenBloc>()..add(ChatScreenUpdateSelectedCm(cm: cm));
          context.read<ChatscreenBloc>()..add(ChatScreenUpdateSelectedKc(kc: kc));
          context.read<BottomnavbarCubit>().updateSelectedItem(BottomNavItem.chats);
        }

        return;
      }
      return;
    } 
  }