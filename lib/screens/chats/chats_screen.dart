import 'dart:developer';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';
import 'package:kingsfam/helpers/firebase_notifs.dart';
import 'package:kingsfam/helpers/kingscord_path.dart';
import 'package:kingsfam/helpers/notification_helper.dart';
import 'package:kingsfam/helpers/user_preferences.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/says_room.dart';

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
    FirebaseMessaging.onMessageOpenedApp
        .listen((r) => handleMessage(r, context));
    // listen if app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      //  NotificationHelper.showNotification(remoteMessage);

      // do not show a notif if alredy in that room.
      if (CurrentKingsCordRoomId.currentKingsCordRoomId !=
          remoteMessage.data['kcId']) {
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
    context.read<BuidCubit>().init();
    //super.build(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool chatScreenStateUnReadChats = false;
  bool hasAskedForAgrement = false;

  var currentScreen;
  @override
  Widget build(BuildContext context) {
    // final userId = context.read<AuthBloc>().state.user!.uid;
    return Scaffold(
        appBar: null,
        body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
            listener: (context, state) {
          if (state.status == ChatStatus.setState) {
            log("we are updating the state of the chats screen ya dig");
            setState(() {});
            if (state.selectedCh != null) {
              context.read<CommuinityBloc>()
                ..add(CommunityInitalEvent(commuinity: state.selectedCh!));
            }
          }

          if (state.status == ChatStatus.setStateKc) {
            if (state.selectedKc != null) {
              if (state.selectedKc!.mode == Mode.chat ||
                  state.selectedKc!.mode == Mode.welcome) {
                currentScreen = KingsCordScreen(
                    commuinity: state.selectedCh!,
                    kingsCord: state.selectedKc!,
                    userInfo: {"isMember": true},
                    usr: context.read<CommuinityBloc>().state.currUserr,
                    role: context.read<CommuinityBloc>().state.role);
              } else if (state.selectedKc!.mode == Mode.says) {
                currentScreen = SaysRoom(
                    cm: state.selectedCh!,
                    kcName: state.selectedKc!.cordName,
                    kcId: state.selectedKc!.id!,
                    currUsr: context.read<CommuinityBloc>().state.currUserr);
              } else if (state.selectedKc!.mode == Mode.attendance) {
                currentScreen = null;
              }
            }
          }

          if (state.status == ChatStatus.error) {
            ErrorDialog(
                content: 'chat_screen e-code: ${state.failure.message}');
          }
        }, builder: (context, state) {
          // check userpreferences. if no data for has aggred to terms of use show a alert dialog
          if (!UserPreferences.getHasAggredToTermsOfService() && !hasAskedForAgrement) {
            hasAskedForAgrement = true;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Future.delayed(Duration(seconds: 2)).then((value) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Terms of Agreement'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                "Pleas read terms of use below and accept to continue."),
                            SizedBox(height: 10),
                            Text(
                                "1. Who is kingsFam: KingsFam is a christian social commuinication platform. KingsFam provides a unique way for churchs, fellowships and ministrys to connect with one another through an online platform."),
                            SizedBox(height: 5),
                            Text(
                                "2. What to expect from KingsFam: KingsFam is still new so many features are on the way this being said updates will be rolling out monthly. KingsFam is open to all user feedback, see complaints hotline community to leave feedback."),
                            SizedBox(height: 5),
                            Text(
                                "3. Account Deletion: At any time you can delete your account and KingsFam will remove your data from the apps database. KingsFam Does NOT sell or track user data."),
                            SizedBox(height: 5),
                            Text(
                                "4. Community Leads: If you start a community You are responsible for keeping your community safe. Upon your Community being reported it will be reviewed and and if found breaking guidelines it will be removed."),
                            SizedBox(height: 5),
                            Text(
                                "5. User Generated Content: Simular to the statment above, if you create any user generated content and it has been reported or is found to break KingsFams guidelines below it will be removed."),
                            SizedBox(height: 5),
                            Text(
                                "6. Account Removal: if you are regoginized to keep breaking guidelines your account will be removed."),
                            SizedBox(height: 5),
                            Text("7. KingsFam Guidelines below: "),
                            SizedBox(height: 5),
                            Text(
                                "7.1 KingsFam does not allow Deragourtory profile pictures, user posts, community posts"),
                            SizedBox(height: 5),
                            Text(
                                "7.2 KingsFam does not allow hate speach on person or group of persons"),
                            SizedBox(height: 5),
                            Text(
                                "7.3 As a content provider for our services, it is your duty to ensure that you have the necessary permissions and licenses in accordance with the terms. You must also make sure that your content follows all applicable laws. Keep in mind that we cannot be held responsible for any issues related to your content or how others use it.")
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: Text('Agree'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              });
            });
          }

          if (state.chs == null)
            return Center(
                child: Text(
              "KingsFam",
              style: Theme.of(context).textTheme.bodyText1,
            ));
          else if (state.chs!.isEmpty)
            return GettingStarted(
              bloc: context.read<ChatscreenBloc>(),
              state: state,
            );
          else if (currentScreen != null)
            return currentScreen;
          else {
            return Text("KingsFam...");
          }
        }));
  }
}
