

part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

Set<dynamic> cmPrivacySet = {CommuintyStatus.armormed, CommuintyStatus.shielded, RequestStatus.pending};

Padding _mainScrollView(BuildContext context, CommuinityState state, Church cm, String? currRole, TabController tabCtrl) {
    // ignore: unused_local_variable
    Color primaryColor = Colors.white;
    // ignore: unused_local_variable
    Color secondaryColor = Color(hc.hexcolorCode('#141829'));
    Color backgoundColor = Color(hc.hexcolorCode('#20263c'));
    if (state.themePack != "none") {
      if (state.themePack == "assets/cm_backgrounds/2.svg") {
        // log("theme pack contains 1.svg");
        primaryColor = Colors.pink[700]!;
        secondaryColor = Colors.blue[700]!;
        backgoundColor = Color.fromARGB(255, 4, 34, 78);
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(slivers: <Widget>[
        cmSliverAppBar(
          currRole: currRole,
          tabCtrl: tabCtrl,
          cm: cm,
            context: context, cmBloc: context.read<CommuinityBloc>()),
        SliverToBoxAdapter(
            child: Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: SvgPicture.asset(
                state.themePack,
                alignment: Alignment.topCenter,
              ),
              height: 200, //MediaQuery.of(context).size.height / 2,
              width: double.infinity,
              decoration: BoxDecoration(color: backgoundColor),
            ),
            // Container(height: MediaQuery.of(context).size.height, width: double.infinity, color: Colors.black38,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                state.status == CommuintyStatus.loading
                    ? LinearProgressIndicator()
                    : SizedBox.shrink(),

                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 5, left: 2.5, right: 2.5),
                  child: Text(cm.cmType + "  •  " + cm.cmPrivacy,
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    state.isMember == null
                        ? SizedBox.shrink()
                        : state.isMember != false
                            ? Container(
                                height: 30,
                                width: 200,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currRole != Roles.Owner) {
                                     showLeaveCommuinity(b: context.read<CommuinityBloc>(), cm: cm, context: context);
                                    } else {
                                      snackBar(
                                          snackMessage:
                                              "Owners can not abandon ship",
                                          context: context,
                                          bgColor: Colors.red);
                                    }
                                  },
                                  child: Text(
                                    "...Leave",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                              side: BorderSide(
                                                  color: Colors.red)))),
                                ),
                              )
                            : joinBtn(b: context.read<CommuinityBloc>(), cm: cm, context: context),
                    SizedBox(width: 10),
                    Text("${cm.size} members")
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
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
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(CreateRoom.routeName,
                              arguments: CreateRoomArgs(
                                  cmBloc: context.read<CommuinityBloc>(),
                                  cm: cm)).then((value) {
                                    // TODO setState and read the events again.
                                  });
                        },
                        icon: Icon(Icons.add))
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
                              return  event!=null? GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(EventView.routeName, arguments: EventViewArgs(cmBloc: context.read<CommuinityBloc>(), event: event)),
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            //        month                             day                                   year
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Text(event.startDateFrontEnd![1] + "/" + event.startDateFrontEnd![2] + "/" + event.startDateFrontEnd![0]),
                                            ),
                                            SizedBox(width : 5),
                                            Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Text(event.eventTitle, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.blue[700]), overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5.0),
                                          child: Text(event.eventDescription, style: TextStyle(fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis,),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ):SizedBox.shrink();;
                            }
                          )
                      : Center(
                          child: state.status == CommuintyStatus.loading
                              ? Text("One Second ...")
                              : Text("Your Community Events Will Show Here")),
                ),
                SizedBox(
                  height: 10,
                ),
                //TODO remove row below?
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
                              return contentPreview(cm: cm, context: context, post: post);
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
                    collapseOrExpand(context.read<CommuinityBloc>(), 'cord'),
                    new_kingscord(cmBloc: context.read<CommuinityBloc>(), cm: cm, context: context, currRole: currRole),
                  ],
                ),
                

                Column(
                  children: [ 
                    if(state.collapseCordColumn)...[
                      SizedBox.shrink(),
                    ]else...
                      state.kingCords.map((cord) {
                        
                          if (cord != null) {
                            return GestureDetector(
                                onTap: () {
                                  if (cmPrivacySet.contains(state.status)) {
                                    snackBar(snackMessage: "You must be a member to view", context: context);
                                    return null;
                                  }
                                  if (cord.mode == "chat") {
                                    // handels the navigation to the kingscord screen and also handels the
                                    // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.

                                    Navigator.of(context).pushNamed(
                                        KingsCordScreen.routeName,
                                        arguments: KingsCordArgs(
                                            commuinity: cm,
                                            kingsCord: cord));

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
                                    snackBar(snackMessage: "You must be a member to view", context: context);
                                    return null;
                                  }
                                  _delKcDialog(context: context, cord: cord, commuinity: cm);
                                } ,
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

                SizedBox(height: 15),
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
                          ? Text(cm.about,
                              textAlign: TextAlign.center)
                          : Text("Nothing To See Here ..."),
                    ),
                    decoration: BoxDecoration(
                      color: Color(hc.hexcolorCode('#141829')),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )
              ],
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
  required TabController tabCtrl,
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
                        image: CachedNetworkImageProvider(
                            cm.imageUrl),
                        fit: BoxFit.cover)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        settingsBtn(cmBloc: cmBloc, cm: cm, context: context, tabcontrollerForCmScreen: tabCtrl, currRole: currRole ),
        inviteButton(cm: cm, context: context),
        // _themePackButton()
      ],
    );
  }