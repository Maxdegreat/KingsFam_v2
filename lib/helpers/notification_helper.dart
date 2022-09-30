// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:rxdart/subjects.dart';

// class NotificationHelper {
//   /// Create a [AndroidNotificationChannel] for heads up notifications
//   late AndroidNotificationChannel channel;

//   /// Initialize the [FlutterLocalNotificationsPlugin] package.

//   static androidNotifChannel({required RemoteMessage message}) =>
//       AndroidNotificationChannel('id', 'name', 'description',
//           importance: Importance.high);

//   /// Create an Android Notification Channel.
//   ///
//   /// We use this channel in the `AndroidManifest.xml` file to override the
//   /// default FCM channel to enable heads up notifications.
//   static configurexmlFCMToHeadsUp({required var channel}) async {
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     if (Platform.isAndroid) {
//       await flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);
//     } else {
//         /// Update the iOS foreground notification presentation options to allow
//     /// heads up notifications.
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     }


//   }

  
// }
