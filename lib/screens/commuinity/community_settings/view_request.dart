import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';

// status for in house
enum Status { init, loading, pag, error }

// args for cmId
class ReviewPendingRequestArgs {
  final String cmId;
  const ReviewPendingRequestArgs({required this.cmId});
}

class ReviewPendingRequest extends StatefulWidget {
  final String cmId;
  const ReviewPendingRequest({Key? key, required this.cmId}) : super(key: key);

  static const String routeName = "ReviewPendingRequest";
  static Route route({required ReviewPendingRequestArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) {
          return ReviewPendingRequest(
            cmId: args.cmId,
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
    _controller = ScrollController();
    _controller.addListener(listenToScrolling);
  }

  // my state managment hub lol ___________\_
  List<Userr> users = [];
  late ScrollController _controller;
  String? lastSeenId;
  DocumentSnapshot? lastSeenDocSnap;
  // ______________________________________-|

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Reviewing Pending Join Request",
                  overflow: TextOverflow.ellipsis),
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  Userr user = users[index];
                  return Card(
                      child: ListTile(
                          leading: ProfileImage(
                            pfpUrl: user.profileImageUrl,
                            radius: 30,
                          ),
                          title: Text(user.username),
                          trailing: _trailing()));
                },
              ),
            )));
  }

  Widget _trailing() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // green check
        IconButton(onPressed: () {
          snackBar(snackMessage: "green chgeck", context: context);
        }, 
        icon: Icon(Icons.check_sharp, color: Colors.green)),
        // red x
        IconButton(
          onPressed: () {
            snackBar(snackMessage: "red x", context: context);
          },
          icon: FaIcon(FontAwesomeIcons.ban),
        )
      ],
    );
  }

  // grab limit ids from the cm request
  Future<List<Userr>> grabLimitUserrs() async {
    if (lastSeenId == null) {
      var snaps = await FirebaseFirestore.instance
          .collection(Paths.requestToJoinCm)
          .doc(widget.cmId)
          .collection(Paths.request)
          .limit(12)
          .get();
      lastSeenDocSnap = snaps.docs.last;
      return snaps.docs.map((e) => Userr.fromDoc(e)).toList();
    } else {
      var snaps = await FirebaseFirestore.instance
          .collection(Paths.requestToJoinCm)
          .doc(widget.cmId)
          .collection(Paths.request)
          .startAfterDocument(lastSeenDocSnap!)
          .limit(12)
          .get();
      return snaps.docs.map((e) => Userr.fromDoc(e)).toList();
    }
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
