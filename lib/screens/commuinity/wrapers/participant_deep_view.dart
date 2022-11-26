import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';

class ParticipantDeepViewArgs {
  final Userr user;
  final String cmId;
  const ParticipantDeepViewArgs({required this.user, required this.cmId});
}

class Participant_deep_view extends StatefulWidget {
  final Userr user;
  final String cmId;

  const Participant_deep_view(
      {Key? key, required this.user, required this.cmId})
      : super(key: key);

  static const String routeName = "Participant_deep_view";
  static Route route({required ParticipantDeepViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return Participant_deep_view(
            cmId: args.cmId,
            user: args.user,
          );
        });
  }

  @override
  State<Participant_deep_view> createState() => _Participant_deep_viewState();
}

class _Participant_deep_viewState extends State<Participant_deep_view> {
  Map<String, dynamic> roleInfo = {
    "role": "member",
  };

  @override
  void initState() {
    _getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.user.username),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        CachedNetworkImageProvider(widget.user.profileImageUrl),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Text("Name: ${widget.user.username}"),
          Text("Role: ${roleInfo["role"]}"),
        ],
      ),
    );
  }

  _getRole() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection(Paths.communityMembers)
        .doc(widget.user.id)
        .collection(Paths.communityRoles)
        .get();
    if (qs.docs.length > 0) {
      DocumentSnapshot doc = qs.docs[0];
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      roleInfo = {"role": data["roleName"] ?? "member"};
      setState(() {});
    }
  }
}
