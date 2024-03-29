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

Widget iconName (Icon i, Widget t) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [t, i],
  );
}

Widget singlePostDisplay ({ required BuildContext context, required CommuinityBloc cmBloc, required Church cm, required Widget? ad }) {
  List<Widget> items = [];
  items.insert(
      0,
      SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.secondary,
                ),
                height: 50,
                width: 50,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CameraScreen.routeName,
                          arguments: CameraScreenArgs(cmId: cm.id));
                    },
                    icon: Icon(Icons.add_rounded)),
              ),
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
  for (int i = 0; i < cmBloc.state.postDisplay.length; i++) {
    items.add(AnimatedSwitcher(
      duration: Duration(milliseconds: 50 * i + 1),
      child: contentPreview(post: cmBloc.state.postDisplay[i]!, context: context, cm: cm)));
  }
  return Container(
      height: 80,
      width: kIsWeb
          ? MediaQuery.of(context).size.width / 3.2
          : MediaQuery.of(context).size.width / 1.2,
      child: ListView(
        scrollDirection: Axis.horizontal,
        addAutomaticKeepAlives: true,
        children: items,
      ));
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
        // _showVc(state, context, cm),
        // your rooms
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Your Rooms",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.fade,
              ),
              CmPermHandler.canMakeRoom(context.read<CommuinityBloc>())
                  ? new_kingscord(
                      cmBloc: context.read<CommuinityBloc>(),
                      cm: cm,
                      context: context)
                  : SizedBox.shrink(),
            ],
          ),
        ),
        if (state.yourRooms.isNotEmpty) ...[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: state.yourRooms.map((cord) {
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
            }).toList(),
          )
        ],

        // other rooms
        if (state.otherRooms.isNotEmpty) ...[
          Text("All Rooms",
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              overflow: TextOverflow.fade),
          SizedBox(height: 7),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: state.otherRooms.map((cord) {
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
            }).toList(),
          )
        ]
      ]);
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
      width: kIsWeb
          ? MediaQuery.of(context).size.width / 6
          : MediaQuery.of(context).size.width / 1, // 1.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
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
                    size: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 5),
                  Text(
                    cord.cordName,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.subtitle1,
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
                    size: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 3),
                  Container(
                    //width: MediaQuery.of(context).size.width -
                    // 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        cord.cordName,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                ] else if (cord.mode == "welcome") ...[
                  Icon(Icons.waving_hand_outlined,
                      size: 15, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 3),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: Text(
                        cord.cordName,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.subtitle1,
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
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(width: 2),
                  // if (cord.metaData["isLive"])
                  //   SizedBox.shrink()
                  // else if (cord.readStatus != null && cord.readStatus! ||
                  //     cord.readStatus == null)
                  //   CircleAvatar(backgroundColor: Colors.amber, radius: 3)
                ]
              ],
            ),
            if (cord.mode == "chat" &&
                cord.recentActivity!["chat"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: DisplayMsg(
                  m: cord.recentActivity!["chat"],
                  s: null,
                  amountInVc: null,
                ),
              )
            ] else if (cord.mode == "says" &&
                cord.recentActivity!["says"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
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
  context.read<BottomnavbarCubit>().updateSelectedItem(BottomNavItem.chats);
  // context.read<CommuinityBloc>().setMentionedToFalse(kcId: cord.id!);
  scaffoldKey.currentState!.closeDrawer();
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
