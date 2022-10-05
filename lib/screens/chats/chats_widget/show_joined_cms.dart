import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import '../../../config/paths.dart';
import '../../../models/church_model.dart';
import '../../../widgets/chats_view_widgets/chats_screen_widgets.dart';
import '../../../widgets/fancy_list_tile.dart';
import '../../commuinity/commuinity_screen.dart';
import '../bloc/chatscreen_bloc.dart';

class showJoinedCms extends StatelessWidget {
  const showJoinedCms({
    Key? key,
    required this.state,
    required this.currId,
  }) : super(key: key);

  final String currId;
  final ChatscreenState state;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: ListView.builder(
          itemCount: state.chs.length,
          itemBuilder: (context, index) {
            // check if the path userid, church, kc ezist if so flag with a @ symbole

            Church? commuinity = state.chs[index];
            bool isMentioned = false;
            FirebaseFirestore.instance
                .collection(Paths.mention)
                .doc(currId)
                .collection(commuinity!.id!)
                .snapshots()
                .isEmpty;

            bool cmHasNotif;
            try {
              var usersrecentTime = commuinity.members[state.currUserr];
              int? compraeTimes = commuinity.recentMsgTime
                  .compareTo(usersrecentTime['timestamp']);
              // ignore: unnecessary_null_comparison
              cmHasNotif = compraeTimes != null ? compraeTimes > 0 : false;
            } catch (e) {
              print(e.toString());
              var usersrecentTime = commuinity.members[state.currUserr];
              int? compraeTimes = commuinity.recentMsgTime
                  .compareTo(usersrecentTime['timestamp']);
              // ignore: unnecessary_null_comparison
              cmHasNotif = true;
            }

            return GestureDetector(
              onLongPress: () =>
                  leaveCommuinity(commuinity: commuinity, context: context),
              onTap: () => Navigator.of(context).pushNamed(
                  CommuinityScreen.routeName,
                  arguments: CommuinityScreenArgs(
                    commuinity: commuinity,
                  )), // ----------------------------------------------------------------------set state here
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  // see child of list view here below.
                  child: FancyListTile(
                      // ------------------------- update hee
                      isMentioned: state.mentionedMap[commuinity.id],
                      newNotification: cmHasNotif,
                      location: commuinity.location.length > 1
                          ? commuinity.location
                          : null,
                      username: commuinity.name,
                      imageUrl: commuinity.imageUrl,
                      onTap: () => Navigator.of(context).pushNamed(
                          CommuinityScreen.routeName,
                          arguments:
                              CommuinityScreenArgs(commuinity: commuinity)),
                      isBtn: false,
                      BR: 12.0,
                      height: 12.0,
                      width: 12.0,)),
            );
          },
        ));
  }
}
