part of 'package:kingsfam/widgets/mainDrawer/main_drawer.dart';

Set<dynamic> cmPrivacySet = {
  CommuintyStatus.armormed,
  CommuintyStatus.shielded,
  RequestStatus.pending
};

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

Widget iconName(Icon i, Widget t) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [t, i],
  );
}

Widget singlePostDisplay({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
  required Widget? ad,
}) {
  List<Widget> items = [];
  items.insert(0, SizedBox(
    width: MediaQuery.of(context).size.width / 4,
    child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 2),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                radius: 25,
                child: IconButton(onPressed: () {
                  log("going to cam screen");
                availableCameras().then((cameras) {
                  Navigator.of(context).pushNamed(CameraScreen.routeName,
                      arguments: CameraScreenArgs(cameras: cameras, cmId: cm.id!));
                });
                }, icon: Icon(Icons.add)),
              ),
            SizedBox(height: 2),
          Flexible(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Text(
                 'Share',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
            ],
          ),
  ));
  for (var w in cmBloc.state.postDisplay) {
    items.add(contentPreview(post: w!, context: context, cm: cm));
  }
  return Container(
    height: 80,
    width: MediaQuery.of(context).size.width / 1.2,
    child: ListView(
      scrollDirection: Axis.horizontal,
      addAutomaticKeepAlives: true,
      children: items,   
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Rooms", // ----------------------------------------------------------------- Rooms
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.fade,
              ),
              //collapseOrExpand(context.read<CommuinityBloc>(), 'cord'),
              CmPermHandler.canMakeRoom(context.read<CommuinityBloc>())
                  ? new_kingscord(
                      cmBloc: context.read<CommuinityBloc>(),
                      cm: cm,
                      context: context)
                  : SizedBox.shrink(),
            ],
          ),
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
                    NavtoKcFromRooms(context, state, cm, cord);
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
                    color: Theme.of(context).brightness == ThemeMode.dark
                        ? Colors.grey
                        : Colors.black87,
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
                    } else {
                      NavtoKcFromRooms(context, state, cm, cord);
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
                  color: Theme.of(context).colorScheme.outline,
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
                  onLongPress: () {
                    if (!CmPermHandler.canMakeRoom(
                        context.read<CommuinityBloc>())) {
                      snackBar(
                          snackMessage: "You do not have permissions for this",
                          bgColor: Colors.red[400],
                          context: context);
                    } else {
                      if (CmPermHandler.canMakeRoom(
                          context.read<CommuinityBloc>()))
                        _delKcDialog(
                            context: context, cord: kc!, commuinity: cm);
                      else
                        snackBar(
                            snackMessage:
                                "You do not have permissions to remove this room.",
                            context: context,
                            bgColor: Colors.red[400]);
                    }
                  },
                  child: showCordAsCmRoom(context, kc!, cm),
                ));
          }).toList()
        ]),
  );
}

Padding showCordAsCmRoom(BuildContext context, KingsCord cord, Church cm) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 5,
      bottom: 5,
      right: 3,
    ),
    child: Container(
      // height: MediaQuery.of(context).size.height / 9,
      width: MediaQuery.of(context).size.width / 1, // 1.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
        // Color(hc.hexcolorCode("#0a0c14")),
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (cord.mode == "chat") ...[
                  Icon(
                    Icons.question_answer,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(width: 2),
                  if (cord.readStatus != null && !cord.readStatus!)
                    SizedBox.shrink()
                  else if (cord.readStatus != null && cord.readStatus! ||
                      cord.readStatus == null)
                    CircleAvatar(backgroundColor: Colors.amber, radius: 3)
                ] else if (cord.mode == "says") ...[
                  Icon(
                    Iconsax.document,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 3),
                  Container(
                    height: 30,
                    //width: MediaQuery.of(context).size.width -
                    // 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        cord.cordName,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ] else if (cord.mode == "welcome") ...[
                  Icon(Icons.waving_hand_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 3),
                  Container(
                    height: 30,
                    //width: MediaQuery.of(context).size.width -
                    // 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        cord.cordName,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ] else if (cord.mode == "vc") ...[
                  Icon(
                    Icons.multitrack_audio_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(width: 2),
                  // if (cord.metaData["isLive"])
                  //   SizedBox.shrink()
                  // else if (cord.readStatus != null && cord.readStatus! ||
                  //     cord.readStatus == null)
                  //   CircleAvatar(backgroundColor: Colors.amber, radius: 3)
                ] else if (cord.mode == Mode.announcement) ...[
                  Icon(
                    Icons.announcement_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ] else if (cord.mode == Mode.attendance) ...[
                  Icon(
                    Icons.group,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ]
              ],
            ),
            if (cord.mode == "chat" &&
                cord.recentActivity!["chat"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(
                  m: cord.recentActivity!["chat"],
                  s: null,
                  amountInVc: null,
                ),
              )
            ] else if (cord.mode == "says" &&
                cord.recentActivity!["says"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(
                  m: null,
                  s: cord.recentActivity!["says"],
                  amountInVc: null,
                ),
              )
            ] else if (cord.mode == "welcome") ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(
                    m: cord.recentActivity!["chat"], s: null, amountInVc: null),
              )
            ] else if (cord.mode == "vc") ...[
              // Padding(
              //   padding: const EdgeInsets.only(left: 20, top: 2),
              //   child: DisplayMsg(m: null, s: null, amountInVc: cord.metaData!["inCall"]),
              // )
            ] else if (cord.mode == Mode.announcement) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(
                    m: cord.recentActivity!["chat"], s: null, amountInVc: null),
              )
            ] else if (cord.mode == Mode.attendance) ...[
              // Padding(
              //   padding: const EdgeInsets.only(left: 20, top: 2),
              //   child: DisplayMsg(
              //       m: cord.recentActivity!["chat"], s: null, amountInVc: null),
              // )
            ]
          ],
        ),
      ),
    ),
  );
}

void onLongPressCord(BuildContext context, KingsCord cord, Church cm) {
  if (!CmPermHandler.canMakeRoom(context.read<CommuinityBloc>())) {
    snackBar(
        snackMessage: "You do not have permissions for this",
        bgColor: Colors.red[400],
        context: context);
  } else {
    
    if (CmPermHandler.canMakeRoom(context.read<CommuinityBloc>()))
      _delKcDialog(context: context, cord: cord, commuinity: cm);
    else
      snackBar(
          snackMessage: "You do not have permissions to remove this room.",
          context: context,
          bgColor: Colors.red[400]);
  }
  return;
}

void NavtoKcFromRooms(
    BuildContext context, CommuinityState state, Church cm, KingsCord cord) {
  context.read<ChatscreenBloc>()..add(ChatScreenUpdateSelectedKc(kc: cord));
  context.read<CommuinityBloc>().setReadStatusFalse(kcId: cord.id!);
  context.read<CommuinityBloc>().setMentionedToFalse(kcId: cord.id!);
  scaffoldKey.currentState!.closeDrawer();
  // Navigator.of(context)
  //     .pushNamed(KingsCordScreen.routeName,
  //         arguments: KingsCordArgs(
  //             role: context.read<CommuinityBloc>().state.role,
  //             usr: state.currUserr,
  //             userInfo: {
  //               "isMember": isMember,
  //             },
  //             commuinity: cm,
  //             kingsCord: cord))
  //     .then((_) {
  //   context.read<CommuinityBloc>().setReadStatusFalse(kcId: cord.id!);
  //   context.read<CommuinityBloc>().setMentionedToFalse(kcId: cord.id!);
  // });
}

Widget header({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
          child: Text(
        cm.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 23),
      )),

      GestureDetector(
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showCmOptions(cmBloc: cmBloc, cm: cm, context: context);
          });
        },
        child: Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.more_horiz,
              color: Theme.of(context).colorScheme.primary),
        ),
      )
      // headerBtnsHomeInvite(cm, () {}, context),
    ],
  );
}
