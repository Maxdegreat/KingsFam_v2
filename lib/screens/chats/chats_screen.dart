import 'dart:developer';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';
import 'package:kingsfam/helpers/firebase_notifs.dart';
import 'package:kingsfam/helpers/kingscord_path.dart';
import 'package:kingsfam/helpers/notification_helper.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

import 'package:kingsfam/widgets/widgets.dart';
import '../../widgets/chats_view_widgets/getting_started.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
  FlutterLocalNotificationsPlugin();

  Future<dynamic> onBackgroundMessage(RemoteMessage message) async {
    // NotificationHelper.showNotification(message);
  }

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
    // show the notification. then if ontaped handle the notification.
    if (initialMessage != null) {
      // NotificationHelper.showNotification(initialMessage);
      handleMessage(initialMessage, context);
    }
    FirebaseMessaging.onBackgroundMessage((onBackgroundMessage));
    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen( (r) => handleMessage(r, context));
    // listen if app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      //  NotificationHelper.showNotification(remoteMessage);

      // do not show a notif if alredy in that room.
      if (CurrentKingsCordRoomId.currentKingsCordRoomId != remoteMessage.data['kcId']) {
        notifSnackBar(remoteMessage: remoteMessage, context: context);
      }
    });
  }



  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    FirebaseDynamicLinkService.initDynamicLink(context);
    CurrentKingsCordRoomId();
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
            ErrorDialog( content: 'chat_screen e-code: ${state.failure.message}');
          }
        }, builder: (context, state) {
         var currentScreen ; 
          if (state.pSelectedCh != state.selectedCh) {
            currentScreen = null;//Container(child: Center(child: Text("KingsFam")),);
            currentScreen =  CommuinityScreen(commuinity: state.selectedCh, showDrawer: true);
          }

          return state.chs == null
              ? Center(child: Text("KingsFam"))
              : state.chs!.length == 0 || state.chs!.isEmpty
                  ? GettingStarted(
                      bloc: context.read<ChatscreenBloc>(),
                      state: state,
                    )
                  : currentScreen;
        }));
  }
}
