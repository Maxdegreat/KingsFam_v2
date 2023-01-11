import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kingsfam/screens/chats/chats_screen.dart';

final List<DarwinNotificationCategory> darwinNotificationCategories =
    <DarwinNotificationCategory>[
  DarwinNotificationCategory(
    "textCategory",
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.text(
        'text_1',
        'Action 1',
        buttonTitle: 'Send',
        placeholder: 'Placeholder',
      ),
    ],
  ),
];

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?>  selectNotificationStream =
    StreamController<String?>.broadcast();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

/// Defines a iOS/MacOS notification category for text input actions.
String darwinNotificationCategoryText = 'textCategory';

// initialization settings:
AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher');

/// Note: permissions aren't requested here just to demonstrate that can be
/// done later
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  requestAlertPermission: false,
  requestBadgePermission: false,
  requestSoundPermission: false,
  notificationCategories: darwinNotificationCategories,
  onDidReceiveLocalNotification:
      (int id, String? title, String? body, String? payload) async {
    didReceiveLocalNotificationStream.add(ReceivedNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    ));
  },
);

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  log("This is a notification taped from the background");
  log('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {

  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.', // description
  importance: Importance.max,
  enableVibration: true,

);

class NotificationHelper {

  

  // inatialization method.
  static Future initalize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin
  ) async {

    AndroidFlutterLocalNotificationsPlugin? fl = 
      flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      fl?.createNotificationChannel(channel).then((value) => log("notif channel has been created"));
      fl?.requestPermission();
  
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,               
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    
  }

  // show notification
  static Future<void> showNotification(RemoteMessage remoteMessage) async {

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, 
        remoteMessage.notification!.title, 
        remoteMessage.notification!.body, 
        notificationDetails,
        payload: 'item x'
      );
  }

  static Future<void> showNotificationNonRemote(Map<String, dynamic> info) async {

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('high_importance_channel', 'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        777, 
        info["title"], 
        info["body"], 
        notificationDetails,
        payload: 'item x'
      );
  }
}
