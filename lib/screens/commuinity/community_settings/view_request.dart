import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';

// status for in house
enum Status { init, loading, pag, error }


// args for cm
class ReviewPendingRequestArgs {
  final Church cm;
  const ReviewPendingRequestArgs({required this.cm});
}

class ReviewPendingRequest extends StatefulWidget {
  final Church cm;
  const ReviewPendingRequest({Key? key, required this.cm}) : super(key: key);

  static const String routeName = "ReviewPendingRequest";
  static Route route({required ReviewPendingRequestArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) {
          return ReviewPendingRequest(
            cm: args.cm,
          );
        }));
  }

  @override
  State<ReviewPendingRequest> createState() => _ReviewPendingRequestState();
}

class _ReviewPendingRequestState extends State<ReviewPendingRequest> {
  
  @override
  void initState() {
    super.initState();
    initGetUsers();
    _controller = ScrollController();
    _controller.addListener(listenToScrolling);
  }

  // my state managment hub lol ___________\|_
  List<Userr> users = [];
  late ScrollController _controller;
  String? lastSeenId;
  DocumentSnapshot? lastSeenDocSnap;
  // ______________________________________ _\|/_

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Reviewing Pending Join Request",
                  overflow: TextOverflow.ellipsis),
            ),
            body: Column(
              children: [
                Text("You can allow people to join or deny them because you are an admin or owner.", textAlign: TextAlign.center,),
                Container(
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: users.length,
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
                                ),
                                _trailing(user)
                              ],
                            ),
                          ),
                        );
                      },
                    )),
              ],
            )));
  }

  Widget _trailing(Userr user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // green check
        IconButton(
            onPressed: () {
              ChurchRepository().onJoinCommuinity(commuinity: widget.cm, user: user);
              // send a push noti to the users phone

              snackBar(snackMessage: "green chgeck", context: context);
            },
            icon: Icon(Icons.check_sharp, color: Colors.green)),

        SizedBox(width: 25),

        // red x
        IconButton(
          onPressed: () {
            snackBar(snackMessage: "red x", context: context);
          },
          icon: FaIcon(FontAwesomeIcons.ban, color: Colors.red),
        )
      ],
    );
  }

  // this is an init method. so we want to grab pending users at the start of the community
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
          .collection(Paths.requestToJoinCm)
          .doc(widget.cm.id)
          .collection(Paths.request)
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
          .collection(Paths.requestToJoinCm)
          .doc(widget.cm.id)
          .collection(Paths.request)
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
}
