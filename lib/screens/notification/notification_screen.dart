import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/notification/bloc/noty_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';

import '../commuinity/community_home/home.dart';

class NotificationsScreen extends StatelessWidget {
  static const String routeName = '/notification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.bodyText1,
        )),
        body: BlocBuilder<NotyBloc, NotyState>(builder: (context, state) {
          switch (state.status) {
            case NotyStatus.error:
              return ErrorDialog(content: state.failure.message);
            case NotyStatus.initial:
              return SizedBox.shrink();
            case NotyStatus.loading:
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.red[400],
                  ),
                ),
              );
            case NotyStatus.loaded:
              if (state.notifications.length == 0) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Container(
                      child: Text(
                        "Hmm, you have no notifications to view here fam",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                );
              } else {
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
                        Divider(
                            height: 10,
                            thickness: 1,
                            indent: 10,
                            endIndent: 5,
                            color: Theme.of(context).colorScheme.background),
                        //child 4
                        SizedBox(height: 10)
                      ]);
                    });
              }
          }
        }));
  }
}

class NotyTile extends StatelessWidget {
  final NotificationKF notifications;
  const NotyTile({required this.notifications});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _getOnTap(context, notifications),
      child: ListTile(
        leading: ProfileImage(
            radius: 35, pfpUrl: notifications.fromUser.profileImageUrl),
        title: Text.rich(TextSpan(children: [
          TextSpan(text: notifications.msg, style: Theme.of(context).textTheme.bodyText1),
        ])),
      ),
    );
  }

  _getOnTap(BuildContext context, NotificationKF noty) async {
    //if from commuinity
    if (noty.fromCm != null) {
      final DocumentSnapshot cmSnap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(noty.fromCm)
          .get();
      final Church cm = await Church.fromDoc(cmSnap);
      return Navigator.of(context).pushNamed(CommunityHome.routeName,
          arguments: CommunityHomeArgs(cm: cm, cmB: null));
    } else
      return Navigator.of(context).pushNamed(ProfileScreen.routeName,
          arguments: ProfileScreenArgs(userId: noty.fromUser.id, initScreen: true));
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
