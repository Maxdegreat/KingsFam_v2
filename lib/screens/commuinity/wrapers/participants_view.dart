import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/cm_perm_handler.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/userr/userr_repository.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class ParticipantsViewArgs {
  final CommuinityBloc cmBloc;
  final Church cm;
  const ParticipantsViewArgs({required this.cmBloc, required this.cm});
}

class ParticipantsView extends StatefulWidget {
  final CommuinityBloc cmBloc;
  final Church cm;
  const ParticipantsView({Key? key, required this.cmBloc, required this.cm})
      : super(key: key);
  static const String routeName = "ParticipantsView";
  static Route route({required ParticipantsViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return ParticipantsView(
            cmBloc: args.cmBloc,
            cm: args.cm,
          );
        });
  }

  @override
  State<ParticipantsView> createState() => _ParticipantsViewState();
}

class _ParticipantsViewState extends State<ParticipantsView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    tabctrl = TabController(length: 2, vsync: this);
    // getRoles();
    initGetUsers();
    _controller = ScrollController();
    _controller.addListener(listenToScrolling);
  }

  // my state managment hub lol ___________\|_
  // [ [Userr, roleName] ]
  List<dynamic> users = [];

  late ScrollController _controller;
  DocumentSnapshot? lastSeenDocSnap;
  late TabController tabctrl;

  // _____________________________________ a

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).iconTheme.color,
                )),
            title: Text(
              "Participants View",
              style: Theme.of(context).textTheme.bodyText1,
            )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: tabctrl,
              tabs: [
                Tab(
                  child: Text(
                    "Participants",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                Tab(
                    child: Text(
                  "roles",
                  style: Theme.of(context).textTheme.caption,
                )),
              ],
            ),
            Flexible(
              child: TabBarView(controller: tabctrl, children: [
                // child 1 -------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // child 1 will be a row allowing you to view pending joins or baned users ---------
                      pendingAndBandRow(widget.cmBloc),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                shape: StadiumBorder(),
                              ),
                              onPressed: () {
                                listenToScrolling();
                              },
                              child: Text(
                                "Load more",
                                style: Theme.of(context).textTheme.bodyText1,
                              )),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              dynamic user = users[index];
                              return Card(
                                // color: Color(hc.hexcolorCode("#141829")),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: ProfileImage(
                                            pfpUrl: user[0].profileImageUrl,
                                            radius: 30,
                                          ),
                                          title: Text(
                                            user[0].username,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1,
                                          ),
                                          trailing: Text(user[1] ?? "Member",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                      fontStyle:
                                                          FontStyle.italic)),
                                          onTap: () {
                                            showModalBottomSheet(
                                                    context: context,
                                                    builder: (context) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: Text(
                                                                    "Role: " +
                                                                        user[1],
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),
                                                            // show name,
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(context).pushNamed(
                                                                    ProfileScreen
                                                                        .routeName,
                                                                    arguments: ProfileScreenArgs(
                                                                        initScreen:
                                                                            true,
                                                                        userId:
                                                                            user[0].id));
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                    "view " +
                                                                        user[0]
                                                                            .username +
                                                                        "\'s profile",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),
                                                            // view profile
                                                            // promote

                                                            GestureDetector(
                                                              onTap: () {
                                                                if (CmPermHandler
                                                                    .isAdmin(widget
                                                                        .cmBloc)) {
                                                                  // Admins and up have the ability to update roles
                                                                  promotionOptionsBottomSheet(
                                                                          context,
                                                                          user)
                                                                      .then((value) =>
                                                                          Navigator.of(context)
                                                                              .pop());
                                                                } else {
                                                                  snackBar(
                                                                      snackMessage:
                                                                          "You do not have the right permissions.",
                                                                      context:
                                                                          context);
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                    "Promote",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),

                                                            GestureDetector(
                                                              onTap: () {
                                                                if (CmPermHandler
                                                                    .isAdmin(widget
                                                                        .cmBloc)) {
                                                                  // Admins and up have the ability to update roles
                                                                  _showUpdateBadgesBottomSheet(
                                                                          context,
                                                                          user)
                                                                      .then((value) =>
                                                                          Navigator.of(context)
                                                                              .pop());
                                                                } else {
                                                                  snackBar(
                                                                      snackMessage:
                                                                          "You do not have the right permissions.",
                                                                      context:
                                                                          context);
                                                                }
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                    "Badges",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),

                                                            // kick name,
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  if (user[0]
                                                                          .id ==
                                                                      context
                                                                          .read<
                                                                              AuthBloc>()
                                                                          .state
                                                                          .user!
                                                                          .uid)
                                                                    snackBar(
                                                                        snackMessage:
                                                                            "You can not remove yourself",
                                                                        context:
                                                                            context);

                                                                  if (CmPermHandler.canRemoveMember(
                                                                     
                                                                      cmBloc: widget
                                                                          .cmBloc)) {
                                                                    widget
                                                                        .cmBloc
                                                                        .onLeaveCommuinity(
                                                                            commuinity: widget
                                                                                .cm,
                                                                            leavingUid: user[0]
                                                                                .id)
                                                                        .then(
                                                                            (value) {
                                                                      snackBar(
                                                                          snackMessage: user[0].username +
                                                                              " has been kicked. " +
                                                                              user[0]
                                                                                  .username +
                                                                              "can join back. Use Ban if you do not want this user to join again. you can un-ban later.",
                                                                          context:
                                                                              context,
                                                                          bgColor: Color.fromARGB(
                                                                              37,
                                                                              50,
                                                                              235,
                                                                              62));
                                                                      users.remove(
                                                                          user);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    });
                                                                  } else {
                                                                    snackBar(
                                                                        snackMessage:
                                                                            "You do not have the right permissions.",
                                                                        context:
                                                                            context);
                                                                  }
                                                                },
                                                                child: Text(
                                                                    "Kick ${user[0].username}",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),
                                                            // ban name,
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  if (user[0]
                                                                          .id ==
                                                                      context
                                                                          .read<
                                                                              AuthBloc>()
                                                                          .state
                                                                          .user!
                                                                          .uid)
                                                                    snackBar(
                                                                        snackMessage:
                                                                            "You can not remove yourself",
                                                                        context:
                                                                            context);

                                                                  if (CmPermHandler.canRemoveMember(
                                                                      cmBloc: widget
                                                                          .cmBloc,
                                                                      )) {
                                                                    widget.cmBloc.ban(
                                                                        cm: widget
                                                                            .cm,
                                                                        uid: user[0]
                                                                            .id);
                                                                    snackBar(
                                                                        snackMessage: user[0].username +
                                                                            " has been baned. " +
                                                                            user[0]
                                                                                .username +
                                                                            "can NOT join back. you can un-ban later.",
                                                                        context:
                                                                            context,
                                                                        bgColor: Color.fromARGB(
                                                                            37,
                                                                            50,
                                                                            235,
                                                                            62));
                                                                    users.remove(
                                                                        user);
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  } else {
                                                                    snackBar(
                                                                        snackMessage:
                                                                            "You do not have the right permissions.",
                                                                        context:
                                                                            context);
                                                                  }
                                                                },
                                                                child: Text(
                                                                    "Ban ${user[0].username}",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .caption),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    })
                                                .then(
                                                    (value) => setState(() {}));

                                            // Navigator.of(context).pushNamed(
                                            //     Participant_deep_view.routeName,
                                            //     arguments:
                                            //         ParticipantDeepViewArgs(
                                            //             user: user[0],
                                            //             cmId: widget.cm.id!));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),

              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> promotionOptionsBottomSheet(BuildContext context, user) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    onTap: () {
                      if (user[1] == "Lead") {
                        snackBar(
                            snackMessage:
                                "You can not change the role of a Lead at the moment.",
                            context: context,
                            bgColor: Colors.red[400]);
                        return;
                      }
                      CmPermHandler.promoteMember(
                          memId: user[0].id,
                          cmId: widget.cm.id!,
                          promotionRoleName: "Admin");
                      user[1] = "Admin";
                      Navigator.of(context).pop;
                    },
                    child: Text("Make Admin",
                        style: Theme.of(context).textTheme.caption)),
              ),
              GestureDetector(
                onTap: () {
                  CmPermHandler.promoteMember(
                      memId: user[0].id,
                      cmId: widget.cm.id!,
                      promotionRoleName: "Mod");
                  user[1] = "Mod";
                  Navigator.of(context).pop;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Make Mod",
                      style: Theme.of(context).textTheme.caption),
                ),
              ),
              GestureDetector(
                onTap: () {
                  CmPermHandler.promoteMember(
                      memId: user[0].id,
                      cmId: widget.cm.id!,
                      promotionRoleName: "Member");
                  user[1] = "Member";
                  Navigator.of(context).pop;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Make Member",
                      style: Theme.of(context).textTheme.caption),
                ),
              ),
            ],
          );
        });
  }

  Widget pendingAndBandRow(cmBloc) {
    return CmPermHandler.canRemoveMember(cmBloc: cmBloc)
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        ReviewPendingRequest.routeName,
                        arguments: ReviewPendingRequestArgs(cm: widget.cm)).then((value) {
                          if (value == false) {
                            // TODO update copywith and make pending join false. also do this in review screen
                          }
                        });
                  },
                  child: Text(
                    "Pending Joins",
                    style: cmBloc.state.cmHasRequest ?  Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).colorScheme.primary) : Theme.of(context).textTheme.bodyText1,
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: StadiumBorder()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ShowBanedUsers.routeName,
                        arguments: ShowBanedUsersArgs(
                            cmId: widget.cm.id!,
                            cmBloc: context.read<CommuinityBloc>()));
                  },
                  child: Text("Baned Users",
                      style: Theme.of(context).textTheme.bodyText1),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: StadiumBorder()),
                )
              ],
            ),
          )
        : SizedBox.shrink();
  }

  initGetUsers() async {
    // [user, role]
    List<dynamic> x = [];

    x = await grabLimitUserrs();
    log("the users count is: " + x.length.toString());
    for (var j in x) {
      if (j[1] == "Lead") {
        users.insert(0, j);
      } else
        users.add(j);
    }
    setState(() {});
  }

  // grab limit ids from the cm request
  Future<List<dynamic>> grabLimitUserrs() async {
    List<dynamic> bucket = [];
    if (lastSeenDocSnap == null) {
      var snaps = await FirebaseFirestore.instance
          .collection(Paths.communityMembers)
          .doc(widget.cm.id)
          .collection(Paths.members)
          .limit(7)
          .get();
      lastSeenDocSnap = snaps.docs.last;

      for (var x in snaps.docs) {
        if (x.exists) {
          Userr u = await UserrRepository().getUserrWithId(userrId: x.id);
          String? roleName = x.data()["kfRole"];
          List<String> badges = x.data()["kfBadges"] ?? ["member"];

          bucket.add([u, roleName, badges]);
        }
      }
    } else {
      var snaps = await FirebaseFirestore.instance
          .collection(Paths.communityMembers)
          .doc(widget.cm.id)
          .collection(Paths.members)
          .startAfterDocument(lastSeenDocSnap!)
          .limit(12)
          .get();
      for (var x in snaps.docs) {
        if (x.exists) {
          Userr u = await UserrRepository().getUserrWithId(userrId: x.id);
          String? roleName = x.data()["kfRole"];
          List<String> badges = x.data()["kfBadges"] ?? ["member"];

          bucket.add([u, roleName, badges]);
        }
      }
    }
    setState(() {});
    // log("bucket len" + bucket.length.toString());
    return bucket;
  }

  void listenToScrolling() async {
    List<dynamic> lst = await grabLimitUserrs();

    users.addAll(lst);
    setState(() {});
    // if (_controller.position.atEdge) {
    //   if (_controller.position.pixels != 0.0 &&
    //       _controller.position.maxScrollExtent == _controller.position.pixels) {
    //     List<Userr> lst = await grabLimitUserrs();
    //     // TODO ADD A VALIDATION THAT WILL ALLOW NO DUPLICATE IDS
    //     users.addAll(lst);
    //     setState(() {});
    //   }
    // }
  }


  dynamic _showUpdateBadgesBottomSheet(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0),
              height: 4.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Update Badges",
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),

                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
