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
    child:  

        CustomScrollView(

          slivers: 
            [

              header(
                    cm: cm,
                    context: context,
                    cmBloc: context.read<CommuinityBloc>()
                ),


              SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 8),
            
            postList(
              cm: cm,
              context: context,
              cmBloc: context.read<CommuinityBloc>(),
              ad: _ad,
            ),
        
            if (state.mentionedCords.length > 0) ... [
              showMentions(context, cm),
              SizedBox(height: 8),
            ],
        
            showRooms(context, cm),
        
            SizedBox(height: 8),
        
            showVoice(context, cm),
        
            SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
  );
}

Padding showCordAsCmRoom(BuildContext context, KingsCord cord, Church cm) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Container(
      // height: MediaQuery.of(context).size.height / 9,
      width: MediaQuery.of(context).size.width / 1, // 1.05,
      decoration: BoxDecoration(
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
                    Icons.numbers,
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
                  Icon(Icons.auto_awesome_motion_rounded,
                  color: Theme.of(context).colorScheme.primary,),
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
                  Icon(Icons.waving_hand_outlined, color: Theme.of(context).colorScheme.primary),
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
                ]
              ],
            ),
            if (cord.mode == "chat" &&
                cord.recentActivity!["chat"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(
                  m: cord.recentActivity!["chat"],
                  s: null, amountInVc: null,
                ),
              )
            ] else if (cord.mode == "says" &&
                cord.recentActivity!["says"] != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 2),
                child: DisplayMsg(m: null, s: cord.recentActivity!["says"], amountInVc: null,),
              )
            ] else if (cord.mode == "vc") ... [
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
    if (cord.mode == "welcome")
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
      .then((_) {
    context.read<CommuinityBloc>().setReadStatusFalse(kcId: cord.id!);
    context.read<CommuinityBloc>().setMentionedToFalse(kcId: cord.id!);
  });
}

Widget header({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
}) {
  return SliverAppBar(
     backgroundColor: Colors.transparent,
    expandedHeight: MediaQuery.of(context).size.height / 4.4,
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
        cmContainerImage(cm),
        SizedBox(width: 7),
        cmTopColumn(cm, context),
    ],
  ),
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
                  Colors.black38,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: [0.25, 1.0],
                tileMode: TileMode.mirror,
              ),
            ))
          ],
        ),))
  );
}

