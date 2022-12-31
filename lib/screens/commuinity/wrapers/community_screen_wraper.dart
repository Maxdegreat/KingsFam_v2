part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

Set<dynamic> cmPrivacySet = {
  CommuintyStatus.armormed,
  CommuintyStatus.shielded,
  RequestStatus.pending
};

Widget _mainScrollView(
    BuildContext context,
    CommuinityState state,
    Church cm,
    Widget? _ad,
    VoidCallback setStateCallBack,
    ScrollController scrollController) {
  // create list for mentioned rooms and reg rooms

  // load an ad for the cm content

  // ignore: unused_local_variable
  Color primaryColor = Colors.white;
  // ignore: unused_local_variable
  Color secondaryColor = Color(hc.hexcolorCode('#141829'));

  return RefreshIndicator(
    onRefresh: () async {
      context.read<CommuinityBloc>().add(CommunityInitalEvent(commuinity: cm));
    },
    child: Stack(
      children: [
        Positioned.fill(
            child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Color.fromARGB(255, 17, 59, 122),
                ]),
          ),
        )),
        CustomScrollView(
            // controller:
            slivers: <Widget>[
              cmSliverAppBar(
                  cm: cm,
                  context: context,
                  cmBloc: context.read<CommuinityBloc>()),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    state.status == CommuintyStatus.loading
                        ? LinearProgressIndicator()
                        : SizedBox.shrink(),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(right: 10, left: 7, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 27,
                                width: MediaQuery.of(context).size.width /
                                    (2.3 * 2.25),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary:
                                          Theme.of(context).colorScheme.primary),
                                  onPressed: () async {
                                    List<CameraDescription> _cameras =
                                        <CameraDescription>[];
                                    _cameras = await availableCameras();
                                    Navigator.of(context).pushNamed(
                                        CameraScreen.routeName,
                                        arguments:
                                            CameraScreenArgs(cameras: _cameras));
                                    // createMediaPopUpSheet(context: context),
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                height: MediaQuery.of(context).size.height / 27,
                                width: MediaQuery.of(context).size.width /
                                    (2.3 * 1.8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary:
                                          Theme.of(context).colorScheme.primary),
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(CommunityHome.routeName,
                                          arguments: CommunityHomeArgs(
                                              cm: cm,
                                              cmB: context
                                                  .read<CommuinityBloc>())),
                                  child: Text("Home",
                                      style:
                                          Theme.of(context).textTheme.bodyText1),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height / (27),
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Theme.of(context).colorScheme.primary),
                              onPressed: () async {
                                String generatedDeepLink =
                                    await FirebaseDynamicLinkService
                                        .createDynamicLink(cm, true);
                                communityInvitePopUp(context, generatedDeepLink);
                              },
                              child: Text("Invite",
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          // child 1. this is a display of post and ooms 111111111111111111111111111111111111111111111111111111111111111111111111111111111111
  
                          Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Container(
                              height: state.postDisplay.isNotEmpty ? 60 : null,
                              width: double.infinity,
                              child: state.postDisplay.length > 0
                                  ? ListView.builder(
                                      itemCount: 2,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        Post? post = state.postDisplay[0];
                                        if (post != null && index == 0) {
                                          return contentPreview(
                                              cm: cm,
                                              context: context,
                                              post: post);
                                        } else {
                                          return _ad != null
                                              ? _ad
                                              : SizedBox.shrink();
                                        }
                                      })
                                  : Center(
                                      child:
                                          state.status == CommuintyStatus.loading
                                              ? Text("One Second ...")
                                              : SizedBox.shrink()),
                            ),
                          ),
  
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              state.mentionedCords.isNotEmpty
                                  ? Text(
                                      "Mentions", // ---------------------------------------------- MENTIONS
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      overflow: TextOverflow.fade,
                                    )
                                  : SizedBox.shrink(),
                              if (state.mentionedCords.isNotEmpty)
                                ...state.mentionedCords.map((cord) {
                                  if (cord != null) {
                                    return GestureDetector(
                                        onTap: () {
                                          if (cmPrivacySet
                                              .contains(state.status)) {
                                            snackBar(
                                                snackMessage:
                                                    "You must be a member to view",
                                                context: context);
                                            return null;
                                          }
                                          if (cord.mode == "chat") {
                                            // handels the navigation to the kingscord screen and also handels the
                                            // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.
                                            NavtoKcFromRooms(
                                                context, state, cm, cord);
  
                                            // Future.delayed(Duration(seconds: 1)).then((value) {
                                            //   log("setting the state");
                                            //   setStateCallBack();
                                            // });
  
                                            // del the @ notification (del the mention)
                                            String currId = context
                                                .read<AuthBloc>()
                                                .state
                                                .user!
                                                .uid;
                                            FirebaseFirestore.instance
                                                .collection(Paths.mention)
                                                .doc(currId)
                                                .collection(cm.id!)
                                                .doc(cord.id)
                                                .delete();
                                          } else if (cord.mode == "welcome") {
                                            NavtoKcFromRooms(
                                                context, state, cm, cord);
                                          } else {
                                            log("pushing to a says");
                                            Navigator.of(context).pushNamed(
                                                SaysRoom.routeName,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3.0),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.3,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  if (cord.mode == "chat") ...[
                                                    Icon(
                                                      Icons.numbers,
                                                      color: Theme.of(context)
                                                          .iconTheme
                                                          .color,
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
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900),
                                                    ),
                                                    SizedBox(width: 2),
                                                    cord.readStatus != null &&
                                                            !cord.readStatus!
                                                        ? SizedBox.shrink()
                                                        : CircleAvatar(
                                                            backgroundColor:
                                                                Colors.amber,
                                                            radius: 5,
                                                          ),
                                                  ] else if (cord.mode ==
                                                      "welcome") ...[
                                                    Text("Welcome")
                                                  ] else ...[
                                                    Icon(Icons
                                                        .auto_awesome_motion_rounded),
                                                    SizedBox(width: 3),
                                                    Container(
                                                      height: 30,
                                                      //width: MediaQuery.of(context).size.width -
                                                      // 50,
                                                      child: Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 7),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              cord.cordName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .fade,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
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
                              // SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Rooms", // ----------------------------------------------------------------- Rooms
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.fade,
                                  ),
                                  collapseOrExpand(
                                      context.read<CommuinityBloc>(), 'cord'),
                                  CmPermHandler.canMakeRoom(
                                          context.read<CommuinityBloc>())
                                      ? new_kingscord(
                                          cmBloc: context.read<CommuinityBloc>(),
                                          cm: cm,
                                          context: context)
                                      : SizedBox.shrink(),
                                ],
                              ),
                              Column(children: [
                                if (state.collapseCordColumn) ...[
                                  Text("...",
                                      style:
                                          Theme.of(context).textTheme.bodyText1)
                                ] else
                                  ...state.kingCords.map((cord) {
                                    // log("cord: " + cord!.toString());
                                    if (cord != null) {
                                      return GestureDetector(
                                          onTap: () {
                                            if (cmPrivacySet
                                                .contains(state.status)) {
                                              snackBar(
                                                  snackMessage:
                                                      "You must be a member to view",
                                                  context: context);
                                              return null;
                                            }
                                            if (cord.mode == "chat") {
                                              NavtoKcFromRooms(
                                                  context, state, cm, cord);
                                            } else if (cord.mode == "welcome") {
                                              NavtoKcFromRooms(
                                                  context, state, cm, cord);
                                            } else if (cord.mode == "says") {
                                              Navigator.of(context).pushNamed(
                                                  SaysRoom.routeName,
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
                                          child: showCordAsCmRoom(
                                              context, cord, cm));
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  }).toList(),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
            ]),
      ],
    ),
  );
}

Padding showCordAsCmRoom(BuildContext context, KingsCord cord, Church cm) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3.0),
    child: Container(
      height: MediaQuery.of(context).size.height / 9,
      width: MediaQuery.of(context).size.width / 1.05,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          // Color(hc.hexcolorCode("#0a0c14")),
          borderRadius: BorderRadius.circular(8)),
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
                    Icons.numbers,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(width: 2),
                  cord.readStatus != null && !cord.readStatus!
                      ? SizedBox.shrink()
                      : CircleAvatar(
                          backgroundColor: Colors.amber,
                          radius: 5,
                        ),
                ] else if (cord.mode == "says") ...[
                  Icon(Icons.auto_awesome_motion_rounded),
                  SizedBox(width: 3),
                  Container(
                    height: 30,
                    //width: MediaQuery.of(context).size.width -
                    // 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cord.cordName,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (cord.mode == "welcome") ...[
                  Icon(Icons.waving_hand_outlined),
                  SizedBox(width: 3),
                  Container(
                    height: 30,
                    //width: MediaQuery.of(context).size.width -
                    // 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cord.cordName,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
            if (cord.mode == "chat" &&
                cord.recentActivity!["chat"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left:20, top: 2),
                child: DisplayMsg(m: cord.recentActivity!["chat"], s: null,),
              )
            ] else if (cord.mode == "says" &&
                cord.recentActivity!["says"] != null) ...[
             Padding(
                padding: const EdgeInsets.only(left:20, top: 2),
                child: DisplayMsg(m:null, s: cord.recentActivity!["says"]),
              )
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
    if (cord.mode != "welcome")
      snackBar(
          snackMessage: "Must have welcome room at this moment",
          context: context);
    else if (CmPermHandler.canMakeRoom(context.read<CommuinityBloc>()))
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
  bool isMember = context.read<CommuinityBloc>().state.isMember ?? false;
  Navigator.of(context)
      .pushNamed(KingsCordScreen.routeName,
          arguments: KingsCordArgs(
              role: context.read<CommuinityBloc>().state.role,
              usr: state.currUserr,
              userInfo: {
                "isMember": isMember,
              },
              commuinity: cm,
              kingsCord: cord))
      .then((_) =>
          context.read<CommuinityBloc>().setMentionedToFalse(kcId: cord.id!));
}

SliverAppBar cmSliverAppBar({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
}) {
  return SliverAppBar(
    // actions: [
    //   Padding(
    //     padding: const EdgeInsets.only(right: 8.0),
    //     child: Icon(Icons.people),
    //   )
    // ],
    backgroundColor: Colors.transparent,
    expandedHeight: MediaQuery.of(context).size.height / 4.4,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(cm.imageUrl)),
                  borderRadius: BorderRadius.circular(7))),
          SizedBox(height: 7),
          Text(cm.name)
        ],
      ),
      background: Center(
        child: Stack(
          children: [
            Container(
                height: MediaQuery.of(context).size.height / 4.4,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(cm.imageUrl),
                      fit: BoxFit.cover),
                )),
            Container(
                decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color.fromARGB(82, 93, 125, 172),
                  Color.fromARGB(83, 13, 72, 161),
                  Theme.of(context).colorScheme.secondary,
                ],
                tileMode: TileMode.mirror,
              ),
            ))
          ],
        ),
      ),
    ),
  );
}
