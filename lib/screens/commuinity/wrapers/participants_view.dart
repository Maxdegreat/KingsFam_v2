import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/cm_perm_handler.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/role_modal.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/userr/userr_repository.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/commuinity/wrapers/create_new_role.dart';
import 'package:kingsfam/screens/commuinity/wrapers/role_permissions.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/profile_image.dart';

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

  List<Role> roles = Role.preBuiltRoles; // [];
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
                      pendingAndBandRow(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color(hc.hexcolorCode("#141829")),
                              shape: StadiumBorder(),
                            ),
                            onPressed: () {
                              listenToScrolling();
                            },
                            child: Text("Load more")),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height / 1.85,
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
                                          trailing: Text(user[1] ?? "Member", style: Theme.of(context).textTheme.caption!.copyWith(fontStyle: FontStyle.italic)),
                                          onTap: () {


                                              showModalBottomSheet(
                                                context: context, 
                                                builder: (context) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Align(
                                                            alignment: Alignment.topRight,
                                                            child: Text("Role: " + user[1], style: Theme.of(context).textTheme.caption),
                                                          ),
                                                        ),
                                                        // show name,
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: user[0].id));
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text( "view " + user[0].username + "\'s profile", style: Theme.of(context).textTheme.caption),
                                                          ),
                                                        ),
                                                        // view profile
                                                        // promote 

                                                        GestureDetector(
                                                          onTap: () {
                                                            if (CmPermHandler.isAdmin(widget.cmBloc)) {
                                                              // Admins and up have the ability to update roles
                                                              promotionOptionsBottomSheet(context, user).then((value) => Navigator.of(context).pop());
                                                            }
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text("Promote", style: Theme.of(context).textTheme.caption),
                                                          ),
                                                        ),

                                                        // kick name,
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text("Kick ${user[0].username}", style: Theme.of(context).textTheme.caption),
                                                        ),
                                                        // ban name,
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text("Ban ${user[0].username}", style: Theme.of(context).textTheme.caption ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              ).then((value) => setState((){})); 


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
                // child 1 --------------------------------------------------

                // child 2 -----------------------------------------------------
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ElevatedButton(onPressed: () {

                      //   Navigator.of(context).pushNamed(CreateRole.routeName, arguments: CreateRoleArgs(cmId: widget.cm.id!));
                      // }, child: Text("Create role", style: Theme.of(context).textTheme.bodyText1,)),

                      SizedBox(height: 7),
                      Text("roles - " + roles.length.toString(),
                          style: Theme.of(context).textTheme.caption),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          height: MediaQuery.of(context).size.height / 1.8,
                          child: ListView.builder(
                              itemCount: roles.length,
                              itemBuilder: (context, index) {
                                Role role = roles[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          leading: Text(role.roleName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption),
                                          onTap: () {
                                            // have a new screen that shows the role permissions
                                            Navigator.of(context).pushNamed(
                                                RolePermissions.routeName,
                                                arguments: RolePermissionsArgs(
                                                    role: role,
                                                    cmId: widget.cm.id!));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                )
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
                                                                          CmPermHandler.promoteMember(memId: user[0].id, cmId: widget.cm.id!, promotionRoleName: "Admin");
                                                                          user[1] = "Admin";
                                                                          Navigator.of(context).pop;
                                                                        },
                                                                        child: Text("Make Admin", style: Theme.of(context).textTheme.caption)),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                          CmPermHandler.promoteMember(memId: user[0].id, cmId: widget.cm.id!, promotionRoleName: "Mod");
                                                                          user[1] = "Mod";
                                                                          Navigator.of(context).pop;
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Text("Make Mod", style: Theme.of(context).textTheme.caption),
                                                                      ),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                          CmPermHandler.promoteMember(memId: user[0].id, cmId: widget.cm.id!, promotionRoleName: "Member");
                                                                          user[1] = "Member";
                                                                          Navigator.of(context).pop;
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        child: Text("Make Member" , style: Theme.of(context).textTheme.caption),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              }
                                                            );
  }

  Widget pendingAndBandRow() {
    return CmPermHandler.isAdmin(context.read<CommuinityBloc>())
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        ReviewPendingRequest.routeName,
                        arguments: ReviewPendingRequestArgs(cm: widget.cm));
                  },
                  child: Text(
                    "View Pending Joins",
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.background,
                      shape: StadiumBorder()),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ShowBanedUsers.routeName,
                        arguments: ShowBanedUsersArgs(
                            cmId: widget.cm.id!,
                            cmBloc: context.read<CommuinityBloc>()));
                  },
                  child: Text("View Baned Joins",
                      style: Theme.of(context).textTheme.bodyText1),
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.background,
                      shape: StadiumBorder()),
                )
              ],
            ),
          )
        : SizedBox.shrink();
  }

  initGetUsers() async {
    List<dynamic> x = [];
    x = await grabLimitUserrs();
    log("the users count is: " + x.length.toString());
    for (var j in x) {
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
          log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ROLEnAME = " +
              roleName.toString());
          bucket.add([u, roleName]);
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
          log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ROLEnAME = " +
              roleName.toString());
          bucket.add([u, roleName]);
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

  void getRoles() async {
    QuerySnapshot rolesSanp = await FirebaseFirestore.instance
        .collection(Paths.communityMembers)
        .doc(widget.cm.id)
        .collection(Paths.communityRoles)
        .limit(10)
        .get();
    // get roles fromDoc
    for (var r in rolesSanp.docs) {
      Role role = Role.fromDoc(r);
      roles.add(role);
    }
    setState(() {});
  }

  // admin options below

  // Future<dynamic> _adminsOptions({
  //     required Userr participatant,
  //     required String role}) {
  //   return showModalBottomSheet(
  //       context: context,
  //       builder: (context) {
  //         if (role == Roles.Admin || role == Roles.Owner) {
  //           return changRolePopUp(context, participatant, cm);
  //         } else {
  //           return Text(
  //             "${participatant.username} is alredy an Admin",
  //           );
  //         }
  //       });
  // }

  // // extension of the moreoptions
  // Column changRolePopUp(
  //     BuildContext context, Userr participatant, Church cm) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Center(
  //         child: Text("Options: " + participatant.username),
  //       ),
  //       TextButton(
  //           onPressed: () {
  //             context.read<BuildchurchCubit>().changeRole(
  //                 user: participatant,
  //                 commuinityId: cm.id!,
  //                 role: Roles.Admin);
  //             Navigator.of(context).pop();
  //           },
  //           child: FittedBox(
  //               child: Text(
  //             "Promote ${participatant.username} to an admin",
  //             overflow: TextOverflow.ellipsis,
  //             style: Theme.of(context).textTheme.bodyText1,
  //           ))),
  //       TextButton(
  //           onPressed: () {
  //             context.read<BuildchurchCubit>().changeRole(
  //                 user: participatant,
  //                 commuinityId: cm.id!,
  //                 role: Roles.Elder);
  //             Navigator.of(context).pop();
  //           },
  //           child: FittedBox(
  //               child: Text(
  //             "Make ${participatant.username} an Elder",
  //             overflow: TextOverflow.ellipsis,
  //             style: Theme.of(context).textTheme.bodyText1,
  //           ))),
  //       TextButton(
  //           onPressed: () {
  //             context.read<BuildchurchCubit>().changeRole(
  //                 user: participatant,
  //                 commuinityId: cm.id!,
  //                 role: Roles.Member);
  //             Navigator.of(context).pop();

  //           },
  //           child: FittedBox(
  //               child: Text(
  //             "Make ${participatant.username} a Member",
  //             overflow: TextOverflow.ellipsis,
  //             style: Theme.of(context).textTheme.bodyText1,
  //           ))),
  //       TextButton(
  //           onPressed: () {
  //             try {
  //               context.read<ChurchRepository>().leaveCommuinity(
  //                   commuinity: cm, leavingUserId: participatant.id);
  //               Navigator.of(context).pop();
  //             } catch (e) {
  //               log("err: " + e.toString());
  //             }

  //             Navigator.of(context).pop();
  //           },
  //           child: FittedBox(
  //               child: Text(
  //                   "Remove ${participatant.username} from ${cm.name}",
  //                   overflow: TextOverflow.ellipsis,
  //                   style: Theme.of(context).textTheme.bodyText1))),
  //       TextButton(
  //           onPressed: () {
  //             if (cm.members[participatant]['role'] == Roles.Owner) {
  //               snackBar(
  //                   snackMessage: "You can not ban the community owner",
  //                   context: context,
  //                   bgColor: Colors.red);
  //               return;
  //             }
  //             context.read<ChurchRepository>().banFromCommunity(
  //                 community: cm, baningUserId: participatant.id);
  //             Navigator.of(context).pop();
  //             snackBar(
  //                 snackMessage:
  //                     "Update will show onReload, user can no longer join",
  //                 context: context);
  //           },
  //           child: FittedBox(
  //               child: Text(
  //             "ban ${participatant.username}",
  //             overflow: TextOverflow.ellipsis,
  //             style: Theme.of(context).textTheme.bodyText1,
  //           )))
  //     ],
  //   );
  // }

}
