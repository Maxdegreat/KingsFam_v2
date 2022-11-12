part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

Set<dynamic> cmPrivacySet = {
  CommuintyStatus.armormed,
  CommuintyStatus.shielded,
  RequestStatus.pending
};

Padding _mainScrollView(BuildContext context, CommuinityState state, Church cm,
    String? currRole, TabController cmTabCtrl) {
  // ignore: unused_local_variable
  Color primaryColor = Colors.white;
  // ignore: unused_local_variable
  Color secondaryColor = Color(hc.hexcolorCode('#141829'));

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CustomScrollView(slivers: <Widget>[
      cmSliverAppBar(
          currRole: currRole,
          cm: cm,
          context: context,
          cmBloc: context.read<CommuinityBloc>()),
      SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.status == CommuintyStatus.loading
              ? LinearProgressIndicator()
              : SizedBox.shrink(),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(hc.hexcolorCode("#141829")),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                unselectedLabelColor: Colors.grey[700],
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(hc.hexcolorCode("#20263c"))),
                controller: cmTabCtrl,
                tabs: [
                  Tab(child: Text("rooms")),
                  Tab(child: Text("Events")),
                  Tab(child: Text("About")),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: TabBarView(
              controller: cmTabCtrl,
              children: [
                // child 1. this is a display of post and ooms 111111111111111111111111111111111111111111111111111111111111111111111111111111111111
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        state.isMember == null
                            ? SizedBox.shrink()
                            : state.isMember != false
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
                                    child: Container(
                                      height: 30,
                                      width: 200,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (currRole != Roles.Owner) {
                                              showLeaveCommuinity(
                                                  b: context
                                                      .read<CommuinityBloc>(),
                                                  cm: cm,
                                                  context: context);
                                            } else {
                                              snackBar(
                                                  snackMessage:
                                                      "Owners can not abandon ship",
                                                  context: context,
                                                  bgColor: Colors.red);
                                            }
                                          },
                                          child: Text(
                                            "Leave",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              shape: StadiumBorder(),
                                              primary: Color(
                                                  hc.hexcolorCode("#141829")))),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: joinBtn(
                                        b: context.read<CommuinityBloc>(),
                                        cm: cm,
                                        context: context),
                                  ),
                        SizedBox(width: 10),
                        Text("${cm.size} members")
                      ],
                    ),
                    Text(
                      "${cm.name}\'s Content",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                    Container(
                      height: 85,
                      width: double.infinity,
                      child: state.postDisplay.length > 0
                          ? ListView.builder(
                              itemCount: state.postDisplay.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                Post? post = state.postDisplay[index];
                                if (post != null) {
                                  return contentPreview(
                                      cm: cm, context: context, post: post);
                                } else {
                                  return SizedBox.shrink();
                                }
                              })
                          : Center(
                              child: state.status == CommuintyStatus.loading
                                  ? Text("One Second ...")
                                  : Text("Your Community Post Will Show Here")),
                    ),
                    //ContentContaner(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Rooms",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        collapseOrExpand(
                            context.read<CommuinityBloc>(), 'cord'),
                        new_kingscord(
                            cmBloc: context.read<CommuinityBloc>(),
                            cm: cm,
                            context: context),
                      ],
                    ),

                    Column(children: [
                      if (state.collapseCordColumn) ...[
                        SizedBox.shrink(),
                      ] else
                        ...state.kingCords.map((cord) {
                          if (cord != null) {
                            return GestureDetector(
                                onTap: () {
                                  if (cmPrivacySet.contains(state.status)) {
                                    snackBar(
                                        snackMessage:
                                            "You must be a member to view",
                                        context: context);
                                    return null;
                                  }
                                  if (cord.mode == "chat") {
                                    // handels the navigation to the kingscord screen and also handels the
                                    // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.
                                    bool isMember = context
                                            .read<CommuinityBloc>()
                                            .state
                                            .isMember ??
                                        false;
                                    Navigator.of(context).pushNamed(
                                        KingsCordScreen.routeName,
                                        arguments: KingsCordArgs(userInfo: {
                                          "isMember": isMember,
                                        }, commuinity: cm, kingsCord: cord));

                                    if (state.mentionedMap[cord.id] != false) {
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
                                    }
                                  } else {
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
                                  if (cmPrivacySet.contains(state.status)) {
                                    snackBar(
                                        snackMessage:
                                            "You must be a member to view",
                                        context: context);
                                    return null;
                                  }
                                  _delKcDialog(
                                      context: context,
                                      cord: cord,
                                      commuinity: cm);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    cord.mode == "chat"
                                        ? Text(
                                            "#",
                                            style: TextStyle(fontSize: 21),
                                          )
                                        : Icon(Icons.record_voice_over_rounded),
                                    SizedBox(width: 3),
                                    Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width -
                                          50,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              cord.cordName,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                  color: state.mentionedMap[
                                                              cord.id] ==
                                                          true
                                                      ? Colors.amber
                                                      : Colors.white,
                                                  fontWeight:
                                                      state.mentionedMap[
                                                                  cord.id] ==
                                                              true
                                                          ? FontWeight.w900
                                                          : FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ));
                          } else {
                            return SizedBox.shrink();
                          }
                        }).toList(),
                    ]),
                  ],
                ),

                // child 2 this is a display of events 222222222222222222222222222222222222222222222222222222222222222222222222222

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "~ Events ~",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        context
                                    .read<CommuinityBloc>()
                                    .state
                                    .role["permissions"]
                                    .contains("*") ||
                                context
                                    .read<CommuinityBloc>()
                                    .state
                                    .role["permissions"]
                                    .contains("#") ||
                                context
                                    .read<CommuinityBloc>()
                                    .state
                                    .role["permissions"]
                                    .contains(CmActions.makeRoom)
                            ? IconButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(CreateRoom.routeName,
                                          arguments: CreateRoomArgs(
                                              cmBloc: context
                                                  .read<CommuinityBloc>(),
                                              cm: cm))
                                      .then((value) {
                                    // TODO setState and read the events again.
                                  });
                                },
                                icon: Icon(Icons.add))
                            : SizedBox.shrink()
                      ],
                    ),
                    Container(
                      height: 95,
                      width: double.infinity,
                      child: state.events.length > 0
                          ? ListView.builder(
                              itemCount: state.events.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                Event? event = state.events[index];
                                return event != null
                                    ? GestureDetector(
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(EventView.routeName,
                                                arguments: EventViewArgs(
                                                    cmBloc: context
                                                        .read<CommuinityBloc>(),
                                                    event: event)),
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    //        month                             day                                   year
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text(event
                                                                  .startDateFrontEnd![
                                                              1] +
                                                          "/" +
                                                          event.startDateFrontEnd![
                                                              2] +
                                                          "/" +
                                                          event.startDateFrontEnd![
                                                              0]),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Text(
                                                          event.eventTitle,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Colors
                                                                  .blue[700]),
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Text(
                                                    event.eventDescription,
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink();
                                ;
                              })
                          : Center(
                              child: state.status == CommuintyStatus.loading
                                  ? Text("One Second ...")
                                  : Text(
                                      "Your Community Events Will Show Here")),
                    ),
                  ],
                ),

                // child 3 this is the about 333333333333333333333333333333333333333333333333333333333333333333

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "About This Community",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    SizedBox(height: 5),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 75,
                        minWidth: double.infinity,
                      ),
                      child: Container(
                        margin: Margin.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: cm.about.isNotEmpty
                              ? Text(cm.about, textAlign: TextAlign.center)
                              : Text("Nothing To See Here ..."),
                        ),
                        decoration: BoxDecoration(
                          color: Color(hc.hexcolorCode('#141829')),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ))
    ]),
  );
}

SliverAppBar cmSliverAppBar({
  required BuildContext context,
  required CommuinityBloc cmBloc,
  required Church cm,
  required String? currRole,
}) {
  return SliverAppBar(
    expandedHeight: MediaQuery.of(context).size.height / 4,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(cm.name),
      background: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(cm.imageUrl),
                  fit: BoxFit.cover),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,//Alignment(0.8, 1),
                  
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black87
                  ], // Gradient from https://learnui.design/tools/gradient-generator.html
                  tileMode: TileMode.mirror,
                ),
              ),
            ),
          )
        ],
      ),
    ),
    actions: [
      memberBtn(cmBloc: cmBloc, cm: cm, context: context),
      inviteButton(cm: cm, context: context),
      settingsBtn(cmBloc: cmBloc, cm: cm, context: context)
      // _themePackButton()
    ],
  );
}
