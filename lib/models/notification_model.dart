import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';

import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';

class NotificationKF extends Equatable {
  final String? id;
  final Userr fromUser;
  final String? fromCm;
  final String? fromDm;
  final String msg;
  final Timestamp date;

  NotificationKF({
    this.id,
    required this.msg,
    required this.fromUser,
    this.fromCm,
    this.fromDm,
    required this.date,
  });

  static NotificationKF empty() => NotificationKF(
      msg:"Someting went wrong",
      date: Timestamp.now(),
      fromUser: Userr.empty,
    );

  @override
  List<Object?> get props =>
      [id, fromUser, fromCm, fromDm, date, msg];

  Map<String, dynamic> toDoc() {
    return {
      'fromUser': fromUser,
      'fromCm': fromCm,
      'fromDm': fromDm,
      'msg' : msg,
      'date': Timestamp.fromDate(DateTime.now()),
    };
  }

  static NotificationKF? fromDoc(DocumentSnapshot? doc) {
    try {
      //=====================
      //if (doc == null ) return null;
      final data = doc!.data() as Map<String, dynamic>;


        return NotificationKF(
            fromUser: data['fromUser'],
            msg: data['msg'],
            fromCm: data['fromCm'],
            fromDm: data['fromDm'],
            date: data['date']);

    }
    //=====================
    catch (e) {
      print("When in the notificationKF model the error thrown is: $e");
    }
    return null;
  }
}
