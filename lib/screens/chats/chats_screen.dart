import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/notification_helper.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';

import 'package:kingsfam/widgets/widgets.dart';
import '../../widgets/chats_view_widgets/getting_started.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
  FlutterLocalNotificationsPlugin();

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/chatScreen';

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  //bool get wantKeepAlive => true;
  // handel permissions for notifications using FCM

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

    // Get any messages which caused the application to open from.
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(NotificationHelper.showNotification /*_handleMessage*/);

    // listen if app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      NotificationHelper.showNotification(remoteMessage);
      snackBar(
          snackMessage: "you recieved a notfication",
          context: context,
          bgColor: Colors.blueGrey);
      // log("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    });
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    // log("MESSAGE.DATA['TYPE'] IS OF VAL: " + message.data['type'].toString());
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
            .collection(Paths.kingsCord)
            .doc(message.data['kcId'])
            .get();

        Church? cm = await Church.fromDoc(snap);
        KingsCord? kc = KingsCord.fromDoc(snapK);
        if (kc != null)
          Navigator.of(context).pushNamed(KingsCordScreen.routeName,
              arguments: KingsCordArgs(
                  commuinity: cm,
                  kingsCord: kc,
                  userInfo: {},
                  usr: Userr.empty));

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

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    NotificationHelper.initalize(flutterLocalNotificationsPlugin);
    //super.build(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool chatScreenStateUnReadChats = false;


  @override
  Widget build(BuildContext context) {

    // final userId = context.read<AuthBloc>().state.user!.uid;
    return Scaffold(
        appBar: null,
        body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
            listener: (context, state) {
          if (state.status == ChatStatus.error) {
            ErrorDialog(
                content: 'chat_screen e-code: ${state.failure.message}');
          }
        }, builder: (context, state) {
         var currentScreen ; 
          if (state.pSelectedCh != state.selectedCh) {
            currentScreen = null;//Container(child: Center(child: Text("KingsFam")),);
            currentScreen =  CommuinityScreen(commuinity: state.selectedCh, showDrawer: true);
          }

          return state.chs == null
              ? Center(child: Text("KingsFam"))
              : state.chs!.length == 0
                  ? GettingStarted(
                      bloc: context.read<ChatscreenBloc>(),
                      state: state,
                    )
                  : currentScreen;
        }));
  }
}
