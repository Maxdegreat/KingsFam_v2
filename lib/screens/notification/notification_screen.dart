
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/enums/enums.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/notification/bloc/noty_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notification';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('noty ganag')),
      body:BlocBuilder<NotyBloc, NotyState>(
        builder: (context, state) {
          switch (state.status) {
            case NotyStatus.error:
              return ErrorDialog(content: state.failure.message);
            case NotyStatus.initial:
              return SizedBox.shrink();
            case NotyStatus.loading:
              return Container(
                child: Center(child: CircularProgressIndicator(color: Colors.red[400],),),
              );
            case NotyStatus.loaded:
              return ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (BuildContext context, int index) {
                  final noty = state.notifications[index]!;
                  return Column(children: [
                    //child 1 is a row
                    NotyTile(notifications: noty),
                    //child 2
                    SizedBox(height: 10),
                    //child 3 is a divider
                    Divider( height: 10, thickness: 1, indent: 10, endIndent: 5, color: Colors.white),
                    //child 4
                    SizedBox(height: 10)
                  ]);
                },
              );
          }
        }
      )
    );
  }
}

class NotyTile extends StatelessWidget {
  final NotificationKF notifications;
  const NotyTile({ required this.notifications});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _getOnTap(context, notifications),
      child: ListTile(
        leading: ProfileImage(radius: 35, pfpUrl: notifications.fromUser.profileImageUrl),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: notifications.fromUser.username,
                style: Theme.of(context).textTheme.bodyText1
              ),
              const TextSpan(text: ' '),
              TextSpan(text: _getText(notifications)),
            ]
          )
        ),
      ),
    );
  }

  String _getText(NotificationKF notifications) {
    switch (notifications.notificationType) {
      case Notification_type.friend_request:
        return " sent you a friend request ";
      case Notification_type.invite_to_commuinity: {
        if (notifications.fromCommuinity != null) 
          return " invited you to a commuinity ${notifications.fromCommuinity!.name}";
        else 
          return " invited you to a commuinity";
      }
      case Notification_type.new_follower:
        return " started following you";
      case Notification_type.invite_to_call:
        return " invited you to a call";
      case Notification_type.direct_message:
        return " sent you a direct message  ";
    }
  }

  _getOnTap(BuildContext context, NotificationKF noty)  {
   //if from commuinity 
   if (notifications.notificationType == Notification_type.invite_to_commuinity) 
     return  Navigator.of(context).pushNamed(CommuinityScreen.routeName, arguments: CommuinityScreenArgs(commuinity: notifications.fromCommuinity!));
     //if drom direct messages
   else if (notifications.notificationType == Notification_type.direct_message)
       return Navigator.of(context).pushNamed(ChatRoom.routeName, arguments: ChatRoomArgs(chat: notifications.fromDirectMessage!));
    // if from new follower
    else 
       return Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: notifications.fromUser.id));
 }
}































// Container(
//         width: double.infinity,
//         height: size.height,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(fit: BoxFit.cover, image: CachedNetworkImageProvider('https://firebasestorage.googleapis.com/v0/b/kingsfam-bloc.appspot.com/o/images%2Fchats%2FchatAvatar_23853528-431e-4346-ac73-293f47a6592e.jpg?alt=media&token=56bb10ae-9c25-4e3f-8b55-acdd31926729'))
//               ),
//             ),
//             Container(color: Colors.black87),
            
            
//           ],
//         ),
//       )