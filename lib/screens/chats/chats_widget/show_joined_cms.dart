import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/widgets/says_container.dart';

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
        child: Column(
          children: [
            Flexible(
              //height: MediaQuery.of(context).size.height - 241,
              child: ListView.builder(
                itemCount: state.chs!.length,
                itemBuilder: (context, index) {
                  // check if the path userid, church, kc ezist if so flag with a @ symbole

                  Church? commuinity = state.chs![index];
                  bool isMentioned = false;
                  FirebaseFirestore.instance
                      .collection(Paths.mention)
                      .doc(currId)
                      .collection(commuinity!.id!)
                      .snapshots()
                      .isEmpty;

                  bool cmHasNotif = false;
                  try {
                    cmHasNotif = false;
                  } catch (e) {
                    print(e.toString());
                  }

                  return GestureDetector(
                    onLongPress: () => leaveCommuinity(commuinity: commuinity, context: context, userId: context.read<AuthBloc>().state.user!.uid),
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
                          width: 12.0,
                        )),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
