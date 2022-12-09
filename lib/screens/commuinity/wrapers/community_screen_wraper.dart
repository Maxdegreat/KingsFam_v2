part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

Set<dynamic> cmPrivacySet = {
  CommuintyStatus.armormed,
  CommuintyStatus.shielded,
  RequestStatus.pending
};

Padding _mainScrollView(BuildContext context, CommuinityState state, Church cm,
    String? currRole, Widget? _ad) {
      
  // create list for mentioned rooms and reg rooms

  // load an ad for the cm content

  // ignore: unused_local_variable
  Color primaryColor = Colors.white;
  // ignore: unused_local_variable
  Color secondaryColor = Color(hc.hexcolorCode('#141829'));

  return Padding(
    padding: const EdgeInsets.only(
      bottom: 8.0,
    ),
    child: CustomScrollView(slivers: <Widget>[
      cmSliverAppBar(
          currRole: currRole,
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
              padding: EdgeInsets.only(right: 10, left: 5, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height / 27,
                        width: MediaQuery.of(context).size.width / (2.3*2.25),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(hc.hexcolorCode("#141829"))),
                          onPressed: () => Navigator.of(context).pushNamed(
                              CreatePostScreen.routeName),
                          child: Icon(Icons.add),
                        ),
                      ),
                      
                      SizedBox(width: 10),

                      Container(
                        height: MediaQuery.of(context).size.height / 27,
                        width: MediaQuery.of(context).size.width / (2.3*1.8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(hc.hexcolorCode("#141829"))),
                          onPressed: () => Navigator.of(context).pushNamed(
                              CommunityHome.routeName,
                              arguments: CommunityHomeArgs(
                                  cm: cm, cmB: context.read<CommuinityBloc>())),
                          child: Text("Home",
                              style: Theme.of(context).textTheme.bodyText1),
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
                          primary: Color(hc.hexcolorCode("#141829"))),
                      onPressed: () {},
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
                                          cm: cm, context: context, post: post);
                                    } else {
                                      return _ad !=null ? _ad : SizedBox.shrink();
                                    }
                                  })
                              : Center(
                                  child: state.status == CommuintyStatus.loading
                                      ? Text("One Second ...")
                                      :SizedBox.shrink()),
                        ),
                      ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      state.mentionedCords.isNotEmpty
                          ? Text(
                          "Mentions",
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
                                    Navigator.of(context)
                                        .pushNamed(KingsCordScreen.routeName,
                                            arguments: KingsCordArgs(
                                                usr: state.currUserr,
                                                userInfo: {
                                                  "isMember": isMember,
                                                },
                                                commuinity: cm,
                                                kingsCord: cord));

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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width /
                                        1.3,
                                    decoration: BoxDecoration(
                                        color:
                                            Color(hc.hexcolorCode("#0a0c14")),
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          cord.mode == "chat"
                                              ? Text(
                                                  "#",
                                                  style:
                                                      TextStyle(fontSize: 21),
                                                )
                                              : Icon(Icons
                                                  .record_voice_over_rounded),
                                          SizedBox(width: 3),
                                          Container(
                                            height: 30,
                                            //width: MediaQuery.of(context).size.width -
                                            // 50,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 7),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    cord.cordName,
                                                    overflow:
                                                        TextOverflow.fade,
                                                    style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
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
                              ? new_kingscord(
                                  cmBloc: context.read<CommuinityBloc>(),
                                  cm: cm,
                                  context: context)
                              : SizedBox.shrink(),
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
                                      Navigator.of(context)
                                          .pushNamed(KingsCordScreen.routeName,
                                              arguments: KingsCordArgs(
                                                  usr: state.currUserr,
                                                  userInfo: {
                                                    "isMember": isMember,
                                                  },
                                                  commuinity: cm,
                                                  kingsCord: cord));

                                      // if (state.mentionedMap[cord.id] !=
                                      //     false) {
                                      //   // del the @ notification (del the mention)
                                      //   String currId = context
                                      //       .read<AuthBloc>()
                                      //       .state
                                      //       .user!
                                      //       .uid;
                                      //   FirebaseFirestore.instance
                                      //       .collection(Paths.mention)
                                      //       .doc(currId)
                                      //       .collection(cm.id!)
                                      //       .doc(cord.id)
                                      //       .delete();
                                      // }
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.3,
                                      decoration: BoxDecoration(
                                          color:
                                              Color(hc.hexcolorCode("#0a0c14")),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            cord.mode == "chat"
                                                ? Text(
                                                    "#",
                                                    style:
                                                        TextStyle(fontSize: 21),
                                                  )
                                                : Icon(Icons
                                                    .record_voice_over_rounded),
                                            SizedBox(width: 3),
                                            Container(
                                              height: 30,
                                              //width: MediaQuery.of(context).size.width -
                                              // 50,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      cord.cordName,
                                                      overflow:
                                                          TextOverflow.fade,
                                                      style: TextStyle(
                                                          color: cord.readStatus !=
                                                                      null &&
                                                                  cord
                                                                      .readStatus!
                                                              ? Colors.white
                                                              : Colors.grey,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ));
                            } else {
                              return SizedBox.shrink();
                            }
                          }).toList(),
                      ]),
                    ],
                  ),

                  // // child 2 this is a display of events 222222222222222222222222222222222222222222222222222222222222222222222222222

                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.start,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         SizedBox(height: 10),
                  //         Text(
                  //           "~ Events ~",
                  //           textAlign: TextAlign.left,
                  //           style: TextStyle(
                  //             color: Colors.grey,
                  //             fontSize: 21,
                  //             fontWeight: FontWeight.w800,
                  //           ),
                  //           overflow: TextOverflow.fade,
                  //         ),
                  //         context
                  //                     .read<CommuinityBloc>()
                  //                     .state
                  //                     .role["permissions"]
                  //                     .contains("*") ||
                  //                 context
                  //                     .read<CommuinityBloc>()
                  //                     .state
                  //                     .role["permissions"]
                  //                     .contains("#") ||
                  //                 context
                  //                     .read<CommuinityBloc>()
                  //                     .state
                  //                     .role["permissions"]
                  //                     .contains(CmActions.makeRoom)
                  //             ? IconButton(
                  //                 onPressed: () {
                  //                   Navigator.of(context)
                  //                       .pushNamed(CreateRoom.routeName,
                  //                           arguments: CreateRoomArgs(
                  //                               cmBloc: context
                  //                                   .read<CommuinityBloc>(),
                  //                               cm: cm))
                  //                       .then((value) {
                  //                     // TODO setState and read the events again.
                  //                   });
                  //                 },
                  //                 icon: Icon(Icons.add))
                  //             : SizedBox.shrink()
                  //       ],
                  //     ),
                  //     // This is the listview of events that is displayed.
                  //     Container(
                  //       height: MediaQuery.of(context).size.height / 1.89,
                  //       width: double.infinity,
                  //       child: state.events.length > 0
                  //           ? ListView.builder(
                  //               itemCount: state.events.length,
                  //               scrollDirection: Axis.vertical,
                  //               itemBuilder: (context, index) {
                  //                 Event? event = state.events[index];
                  //                 return event != null
                  //                     ? GestureDetector(
                  //                         onTap: () => Navigator.of(context)
                  //                             .pushNamed(EventView.routeName,
                  //                                 arguments: EventViewArgs(
                  //                                   cm: cm,
                  //                                   cmBloc: context
                  //                                       .read<CommuinityBloc>(),
                  //                                   event: event,
                  //                                 )),
                  //                         child: Padding(
                  //                           padding: const EdgeInsets.all(8.0),
                  //                           child: Container(
                  //                             decoration: BoxDecoration(
                  //                                 color: Colors.black87,
                  //                                 borderRadius:
                  //                                     BorderRadius.circular(
                  //                                         15)),
                  //                             child: Padding(
                  //                               padding:
                  //                                   const EdgeInsets.all(8.0),
                  //                               child: Column(
                  //                                 mainAxisAlignment:
                  //                                     MainAxisAlignment.start,
                  //                                 crossAxisAlignment:
                  //                                     CrossAxisAlignment.start,
                  //                                 children: [
                  //                                   Row(
                  //                                     children: [
                  //                                       //        month                             day                                   year
                  //                                       Padding(
                  //                                         padding:
                  //                                             const EdgeInsets
                  //                                                 .all(2.0),
                  //                                         child: Text(event
                  //                                                     .startDateFrontEnd![
                  //                                                 1] +
                  //                                             "/" +
                  //                                             event.startDateFrontEnd![
                  //                                                 2] +
                  //                                             "/" +
                  //                                             event.startDateFrontEnd![
                  //                                                 0]),
                  //                                       ),
                  //                                       SizedBox(width: 5),
                  //                                       Flexible(
                  //                                         child: Padding(
                  //                                           padding:
                  //                                               const EdgeInsets
                  //                                                   .all(2.0),
                  //                                           child: Text(
                  //                                               event
                  //                                                   .eventTitle,
                  //                                               style: TextStyle(
                  //                                                   fontWeight:
                  //                                                       FontWeight
                  //                                                           .w700,
                  //                                                   color: Colors
                  //                                                           .blue[
                  //                                                       700]),
                  //                                               overflow:
                  //                                                   TextOverflow
                  //                                                       .ellipsis),
                  //                                         ),
                  //                                       ),
                  //                                     ],
                  //                                   ),
                  //                                   Padding(
                  //                                     padding:
                  //                                         const EdgeInsets.only(
                  //                                             left: 5.0),
                  //                                     child: Text(
                  //                                       event.eventDescription,
                  //                                       style: TextStyle(
                  //                                           fontStyle: FontStyle
                  //                                               .italic),
                  //                                       overflow: TextOverflow
                  //                                           .ellipsis,
                  //                                     ),
                  //                                   )
                  //                                 ],
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       )
                  //                     : SizedBox.shrink();
                  //               })
                  //           : Center(
                  //               child: state.status == CommuintyStatus.loading
                  //                   ? Text("One Second ...")
                  //                   : Text(
                  //                       "Your Community Events Will Show Here")),
                  //     ),
                  //  ],
                  // ),
                ],
              ),
            ),
          ],
        ),
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
    actions: [Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(Icons.people),
    )],
    expandedHeight: MediaQuery.of(context).size.height / 4.4,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(cm.name),
      background: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        child: Center(
          child: Stack(
            children: [
              Container(
                  height: MediaQuery.of(context).size.height / 4.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(cm.imageUrl),
                        fit: BoxFit.cover),
                  )),
              Container(
                  decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    Colors.black87,
                    Colors.black26,
                    Colors.transparent,
                  ], // Gradient from https://learnui.design/tools/gradient-generator.html
                  tileMode: TileMode.mirror,
                ),
              ))
            ],
          ),
        ),
      ),
    ),
  );
}
