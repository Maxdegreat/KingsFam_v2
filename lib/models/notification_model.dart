import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/paths.dart';

import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';


class NotificationKF extends Equatable {
  final String? id;
  final Userr fromUser;
  final Church? fromCommuinity;
  final Chat? fromDirectMessage;
  final CallModel? fromCall;
  
  final Notification_type notificationType;
  final Timestamp date;

  NotificationKF({
    this.id,
    required this.fromUser,
    this.fromCommuinity,
    this.fromDirectMessage,
    this.fromCall,
    required this.notificationType,
    required this.date,
  });


@override
List<Object?> get props => [id, fromUser, fromCommuinity, fromDirectMessage, notificationType, fromCall,  date];

Map<String, dynamic> toDoc () {
  final notificationTypeAsString = EnumToString.convertToString(notificationType);
  return {
    'fromUser': FirebaseFirestore.instance.collection(Paths.users).doc(fromUser.id),
    'fromCommuinity' : fromCommuinity != null ? FirebaseFirestore.instance.collection(Paths.church).doc(fromCommuinity!.id) : null,
    'fromDirectMessage' : fromDirectMessage != null ? FirebaseFirestore.instance.collection(Paths.chats).doc(fromDirectMessage!.id) : null,
    'fromCall' : fromCall != null ? FirebaseFirestore.instance.collection(Paths.church).doc(fromCommuinity!.id).collection(Paths.call).doc(fromCall!.id) : null,
    'notificationType' : notificationTypeAsString,
    'date' : Timestamp.fromDate(DateTime.now()),
  };
}
  static Future <NotificationKF?> fromDoc(DocumentSnapshot? doc) async {
    try {
      //=====================
      //if (doc == null ) return null;
    final data = doc!.data() as Map<String, dynamic>;

    final notificationTypeAsString = EnumToString.fromString( Notification_type.values, data['notificationType']);

    final userRef = data['fromUser'] as DocumentReference?;
    if (userRef != null) {
      
      // ok now we know userRef is not null so we can get the doc
      // we will also check our next case

      final userDoc = await userRef.get();

      //next case, if case is not null we will return in case. (may have may conditions in one case)
      final commuinityRef = data['fromCommuinity'] as DocumentReference?;
      final callRef = data['fromCall'] as DocumentReference?;

      // check a multi lear conditional in this case and return accordingly
      if (commuinityRef != null) {
        //check call ref
        if (callRef != null) {
          //if both exist return here
          final commuinityDoc = await commuinityRef.get();
          var ch = await Church.fromDoc(commuinityDoc);
          final callDoc = await callRef.get();
          return NotificationKF(fromUser: Userr.fromDoc(userDoc), fromCommuinity: ch, fromCall: CallModel.fromDoc(callDoc), fromDirectMessage: null, notificationType: notificationTypeAsString!, date: data['date'], );
        }
        final commuinityDoc = await commuinityRef.get();
        var ch = await Church.fromDoc(commuinityDoc);
        return NotificationKF(fromUser: Userr.fromDoc(userDoc), fromCommuinity: ch, fromCall: null, fromDirectMessage: null, notificationType: notificationTypeAsString!, date: data['date'], );
      }

      //in this case all if statments failed so we just will return with the user and required prams
      return NotificationKF(fromUser: Userr.fromDoc(userDoc), notificationType: notificationTypeAsString!, fromCall: null, fromCommuinity: null, fromDirectMessage: null, date: data['date']);
    }


  //   //from user
  //   final userRef = data['fromUser'] as DocumentReference?;
  //   if (userRef != null) {
  //     final userDoc = await userRef.get();
  //   //from commuinity while still in the user doc if true bloc at this point i will also start checking for the call
  //     final commuinityRef = data['fromCommuinity'] as DocumentReference?;
  //     if (commuinityRef != null)
  //       final commuintyDoc = commuinityRef.get();
      
  //     final callRef = data['fromCall'] as DocumentReference?;
  //     if (callRef != null) {
  //       final callDoc = await callRef.get();
  //       if (commuinityDoc.exists && callDoc.exists ) {
  //           return NotificationKF(fromUser: Userr.fromDoc(userDoc), notificationType: notificationTypeAsString!, fromCommuinity: Church.fromDoc(commuinityDoc), fromCall: CallModel.fromDoc(callDoc), fromDirectMessage: null, date: (data['date'] ));
  //       }

  //     //from direct message
  //       final dmRef = data['fromDirectMessage'] as DocumentReference?;
  //     if (dmRef != null ) {
  //       final dmDoc = await dmRef.get();
  //       if (dmDoc.exists) {
  //         return NotificationKF(fromUser: Userr.fromDoc(userDoc), notificationType: notificationTypeAsString!, fromDirectMessage: Chat.fromDoc(dmDoc), date: (data['date'] ));
  //       }
  //     }
  //   } else {
  //       return NotificationKF(fromUser: Userr.fromDoc(userDoc), notificationType: notificationTypeAsString!, date: (data['date'] ));
  //     }
  //   }
  //   return null;
    
  }
      //=====================
      catch (e) {
        print("When in the notificationKF model the error thrown is: $e");
    }
}
}
