import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension DateTimeExtension on Timestamp {
//timeFormat.format(message.timestamp.toDate())

  String timeAgo() {
    final currentDate = Timestamp.now();
    if (currentDate.compareTo(this) > 1) {
      return timeago.format(toDate(), locale: 'en_short') ;//DateFormat.yMMMd().format(toDate());
    }
    return timeago.format(toDate());
  }
}

// extension DateTimeExtension on DateTime {
//timeFormat.format(message.timestamp.toDate())
// 
  // String timeAgo() {
    // final currentDate = DateTime.now();
    // if (currentDate.difference(this).inDays > 1) {
      // return DateFormat.yMMMd().format(this);
    // }
    // return timeago.format(this);
  // }
// }
