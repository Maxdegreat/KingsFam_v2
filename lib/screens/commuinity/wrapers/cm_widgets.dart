import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/camera/bloc/camera_screen.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/cm_perm_handler.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/commuinity_feed.dart';
import 'package:kingsfam/screens/commuinity/screens/vc/vc_screen.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';

import '../screens/says_room/says_room.dart';

Widget cmContainerImage(Church cm) {
  return Container(
    height: 50,
    width: 50,
    decoration: BoxDecoration(
      image: DecorationImage(image: CachedNetworkImageProvider(cm.imageUrl)),
      borderRadius: BorderRadius.circular(7),
    ),
  );
}

Widget cmTopColumn(Church cm, BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        cm.name,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      SizedBox(
        height: 4,
      ),
      cmTopColumnHomeInvite(cm, () {}, context),
    ],
  );
}

Widget cmTopColumnHomeInvite(Church cm, VoidCallback k, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
          height: 20,
          // width: MediaQuery.of(context).size.width / 7,
          child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                  CommunityHome.routeName,
                  arguments: CommunityHomeArgs(
                      cm: cm, cmB: context.read<CommuinityBloc>())),
              child: Text(
                "Home",
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white, fontSize: 15),
              ))),
              SizedBox(
        width: 4,
      ),
      Container(
          height: 20,
          width: MediaQuery.of(context).size.width / 8,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                List<CameraDescription> cameras = await availableCameras();
               Navigator.of(context).pushNamed(CameraScreen.routeName, arguments: CameraScreenArgs(cameras: cameras));
              },
              child: Center(
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).iconTheme.color,
                  size: 15,
                ),
              ))),
      SizedBox(
        width: 4,
      ),
      Container(
          height: 20,
          width: MediaQuery.of(context).size.width / 8,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary),
              onPressed: () async {
                String generatedDeepLink =
                    await FirebaseDynamicLinkService.createDynamicLink(
                        cm, true);
                communityInvitePopUp(context, generatedDeepLink);
              },
              child: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.share,
                  color: Theme.of(context).iconTheme.color,
                  size: 15,
                ),
              )))
    ],
  );
}

Widget postList({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
  required Widget? ad,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: Container(
      height: MediaQuery.of(context).size.height / 15,
      width: double.infinity,
      child: cmBloc.state.postDisplay.length > 0
          ? ListView.builder(
              itemCount: 2,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                Post? post = cmBloc.state.postDisplay[0];
                if (post != null && index == 0) {
                  return contentPreview(cm: cm, context: context, post: post);
                } else {
                  return ad != null ? ad : SizedBox.shrink();
                }
              })
          : Center(
              child: cmBloc.state.status == CommuintyStatus.loading
                  ? Text("One Second ...")
                  : SizedBox.shrink()),
    ),
  );
}

Widget cmPostDisplay(Post? p, BuildContext context, Church cm) {
  if (p == null) return SizedBox.shrink();

  return GestureDetector(
    onTap: () => Navigator.of(context)
        .pushNamed(CommuinityFeedScreen.routeName,
            arguments:
                CommuinityFeedScreenArgs(commuinity: cm, passedPost: null))
        .then((_) => context.read<BottomnavbarCubit>().showBottomNav(true)),
    child: Container(
      width: MediaQuery.of(context).size.width / 5,
      child: Column(
        children: [
          PostCircle(p, context),
          SizedBox(height: 10),
          Text(
            p.author.username,
            style: Theme.of(context).textTheme.caption,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    ),
  );
}

Widget PostCircle(Post p, context) {
  String? url;
  var size = MediaQuery.of(context).size;
  if (p.imageUrl != null)
    url = p.imageUrl!;
  else if (p.thumbnailUrl != null) url = p.thumbnailUrl!;
  if (url == null) return SizedBox.shrink();

  return Container(
    height: size.height / 12.5,
    width: size.width / 4,
    child: CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(url),
    ),
    decoration: BoxDecoration(
        border: Border.all(
            width: 2,
            color: Colors.white), // hc.hexcolorCode(p.author.colorPref)),
        color: Colors.transparent,
        shape: BoxShape.circle),
  );
}

Widget showRooms(BuildContext context, Church cm) {
  CommuinityState state = context.read<CommuinityBloc>().state;
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Chat Rooms", // ----------------------------------------------------------------- Rooms
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
            collapseOrExpand(context.read<CommuinityBloc>(), 'cord'),
            CmPermHandler.canMakeRoom(context.read<CommuinityBloc>())
                ? new_kingscord(
                    cmBloc: context.read<CommuinityBloc>(),
                    cm: cm,
                    context: context)
                : SizedBox.shrink(),
          ],
        ),
        // _showVc(state, context, cm),
        if (context.read<CommuinityBloc>().state.collapseCordColumn) ...[
          Text("...", style: Theme.of(context).textTheme.bodyText1)
        ] else
          ...state.kingCords.map((cord) {
            // log("cord: " + cord!.toString());
            if (cord != null) {
              return GestureDetector(
                  onTap: () {
                    if (cmPrivacySet.contains(state.status)) {
                      snackBar(
                          snackMessage: "You must be a member to view",
                          context: context);
                      return null;
                    }
                    if (cord.mode == "chat") {
                      NavtoKcFromRooms(context, state, cm, cord);
                    } else if (cord.mode == "welcome") {
                      NavtoKcFromRooms(context, state, cm, cord);
                    } else if (cord.mode == "says") {
                      Navigator.of(context).pushNamed(SaysRoom.routeName,
                          arguments: SaysRoomArgs(
                              currUsr: state.currUserr,
                              cm: cm,
                              kcName: cord.cordName,
                              kcId: cord.id!));
                    }
                  },
                  onLongPress: () {
                    onLongPressCord(context, cord, cm);
                  },
                  child: showCordAsCmRoom(context, cord, cm));
            } else {
              return SizedBox.shrink();
            }
          })
      ]);
}

Widget showMentions(BuildContext context, Church cm) {
  CommuinityState state = context.read<CommuinityBloc>().state;
  return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        state.mentionedCords.isNotEmpty
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                  "Mentions", // ---------------------------------------------- MENTIONS
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.fade,
                ),
            )
            : SizedBox.shrink(),
        if (state.mentionedCords.isNotEmpty)
          ...state.mentionedCords.map((cord) {
            if (cord != null) {
              return GestureDetector(
                  onTap: () {
                    if (cmPrivacySet.contains(state.status)) {
                      snackBar(
                          snackMessage: "You must be a member to view",
                          context: context);
                      return null;
                    }
                    if (cord.mode == "chat") {
                      // handels the navigation to the kingscord screen and also handels the
                      // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.
                      NavtoKcFromRooms(context, state, cm, cord);

                      // Future.delayed(Duration(seconds: 1)).then((value) {
                      //   log("setting the state");
                      //   setStateCallBack();
                      // });

                      // del the @ notification (del the mention)
                      String currId = context.read<AuthBloc>().state.user!.uid;
                      FirebaseFirestore.instance
                          .collection(Paths.mention)
                          .doc(currId)
                          .collection(cm.id!)
                          .doc(cord.id)
                          .delete();
                    } else if (cord.mode == "welcome") {
                      NavtoKcFromRooms(context, state, cm, cord);
                    } else {
                      log("pushing to a says");
                      Navigator.of(context).pushNamed(SaysRoom.routeName,
                          arguments: SaysRoomArgs(
                              currUsr: state.currUserr,
                              cm: cm,
                              kcName: cord.cordName,
                              kcId: cord.id!));
                    }
                  },
                  onLongPress: () {
                    onLongPressCord(context, cord, cm);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (cord.mode == "chat") ...[
                              Icon(
                                Icons.numbers,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              SizedBox(width: 5),
                              Text(
                                cord.cordName,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.w900),
                              ),
                              SizedBox(width: 2),
                              cord.readStatus != null && !cord.readStatus!
                                  ? SizedBox.shrink()
                                  : CircleAvatar(
                                      backgroundColor: Colors.amber,
                                      radius: 5,
                                    ),
                            ] else if (cord.mode == "welcome") ...[
                              Text("Welcome")
                            ] else ...[
                              Icon(Icons.auto_awesome_motion_rounded),
                              SizedBox(width: 3),
                              Container(
                                height: 30,
                                //width: MediaQuery.of(context).size.width -
                                // 50,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 7),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        cord.cordName,
                                        overflow: TextOverflow.fade,
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ));
            } else {
              return SizedBox.shrink();
            }
          }).toList(),
      ]);
}

Widget showVoice(BuildContext context, Church cm) {
  CommuinityState state = context.read<CommuinityBloc>().state;
  return Padding(
    padding: const EdgeInsets.only(right: 4.0, bottom: 4),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.vc.length > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "V/C Rooms",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.fade,
              ),
            ),
          ...state.vc.map((kc) {
            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.0),
                child: GestureDetector(
                  onTap: () {
                    if (kc != null)
                      Navigator.of(context).pushNamed(VcScreen.routeName,
                          arguments: VcScreenArgs(
                              kc: kc, currUserr: state.currUserr, cm: cm));
                    else
                      snackBar(snackMessage: "No VC", context: context);
                  },
                  child: showCordAsCmRoom(context, kc!, cm),
                ));
          }).toList()
        ]),
  );
}
// Widget makePost() {
//    Container(
//                                 height: MediaQuery.of(context).size.height / 27,
//                                 width: MediaQuery.of(context).size.width /
//                                     (2.3 * 2.25),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(7),
//                                 ),
//                                 child: ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                       primary: Theme.of(context)
//                                           .colorScheme
//                                           .primary),
//                                   onPressed: () async {
//                                     List<CameraDescription> _cameras =
//                                         <CameraDescription>[];
//                                     _cameras = await availableCameras();
//                                     Navigator.of(context).pushNamed(
//                                         CameraScreen.routeName,
//                                         arguments: CameraScreenArgs(
//                                             cameras: _cameras));
//                                     // createMediaPopUpSheet(context: context),
//                                   },
//                                   child: Icon(
//                                     Icons.add,
//                                     color: Theme.of(context).iconTheme.color,
//                                   ),
//                                 ),
//                               ),
// }