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
  print("This is a notification taped from the background");
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print( 'notification action tapped with input: ${notificationResponse.input}');
  }
}



class NotificationHelper {

  

  // inatialization method.
  static Future initalize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
        
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    log("about to initalize local notifs");
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
          log("recieved a notification via the onDidRecieveNotification");
          // selectNotificationStream.add(notificationResponse.payload);
    },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    log("local notifs are now initalized");
  }

  // show notification
  static Future<void> showNotification(RemoteMessage remoteMessage) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('channelId2', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, 'KingsFam example title', 'so this is an ex body. it will most often contain text', notificationDetails,
        payload: 'item x');
  }
}
