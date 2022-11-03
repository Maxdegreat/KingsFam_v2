import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/userr/userr_repository.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/widgets/profile_image.dart';


class ParticipantsViewArgs {
  final CommuinityBloc cmBloc;
  final Church cm;
  const ParticipantsViewArgs({required this.cmBloc, required this.cm});
}

class ParticipantsView extends StatefulWidget {
  final CommuinityBloc cmBloc;
  final Church cm;
  const ParticipantsView({Key? key, required this.cmBloc, required this.cm}) : super(key: key);
  static const String routeName = "ParticipantsView";
  static Route route({required ParticipantsViewArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return ParticipantsView(cmBloc: args.cmBloc, cm: args.cm,);
      }
    );
  }

  @override
  State<ParticipantsView> createState() => _ParticipantsViewState();
}

class _ParticipantsViewState extends State<ParticipantsView> with SingleTickerProviderStateMixin {

    @override
  void initState() {
    super.initState();
    tabctrl = TabController(length: 2, vsync: this);
    initGetUsers();
    _controller = ScrollController();
    _controller.addListener(listenToScrolling);
  }

  // my state managment hub lol ___________\|_
  List<Userr> users = [];
  late ScrollController _controller;
  String? lastSeenId;
  DocumentSnapshot? lastSeenDocSnap;
  late TabController tabctrl;
  // _____________________________________ a

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Participants View")),
        body: Column(
          
          children: [

            TabBar(
              controller: tabctrl,
              tabs: [
                Tab(text: "Participants"),
                Tab(text: "Edit"),
              ],
            ),

            Flexible(
              child: TabBarView(controller: tabctrl, 
                children: [
                      // child 1 -------------------------------------------------
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: ListView.builder(
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                Userr user = users[index];
                                    return Card(
                                      color: Color(hc.hexcolorCode("##141829")),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              leading: ProfileImage(
                                                pfpUrl: user.profileImageUrl,
                                                radius: 30,
                                              ),
                                              title: Text(user.username),
                                              onTap: () {
            
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                              } 
                            ),
                          ),
                        ),
                      // child 1 --------------------------------------------------
            
                      // child 2 -----------------------------------------------------
                      Container(child: Text("This is the edit view"))
                ]),
            ),
          ],
        ),
      ),
    );
  }

  initGetUsers() async {
    List<Userr> x = [];
    x = await grabLimitUserrs();
    log("the users count is: " + x.length.toString());
    for (var j in x) {
      users.add(j);
    }
    setState(() {});
  }

  // grab limit ids from the cm request
  Future<List<Userr>> grabLimitUserrs() async {
    List<Userr> bucket = [];
    if (lastSeenId == null) {
      var snaps = await FirebaseFirestore.instance
          .collection(Paths.communityMembers)
          .doc(widget.cm.id)
          .collection(Paths.members)
          .limit(12)
          .get();
      lastSeenDocSnap = snaps.docs.last;
      log("snaps doc len: " + snaps.docs.length.toString());
      for (var x in snaps.docs) {
        if (x.exists) {
          Userr u = await UserrRepository().getUserrWithId(userrId: x.id);
          bucket.add(u);
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
          bucket.add(u);
        }
      }
    }
    return bucket;
  }

  void listenToScrolling() async {
    if (_controller.position.atEdge) {
      if (_controller.position.pixels != 0.0 &&
          _controller.position.maxScrollExtent == _controller.position.pixels) {
        List<Userr> lst = await grabLimitUserrs();
        // TODO ADD A VALIDATION THAT WILL ALLOW NO DUPLICATE IDS
        users.addAll(lst);
        setState(() {});
      }
    }
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