import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/config/paths.dart';
class KingsCordSettingsArgs {
  final String kcId;
  final String cmId;
  const KingsCordSettingsArgs({required this.cmId, required this.kcId});
}
class KingsCordSettings extends StatefulWidget {
  final String kcId;
  final String cmId;
  const KingsCordSettings({Key? key, required this.cmId, required this.kcId}) : super(key: key);

  // ok so now we do the do the route and route name
  static const String routeName = "KingsCordSettingsArgs";

  @override
  State<KingsCordSettings> createState() => _KingsCordSettingsState();
}

class _KingsCordSettingsState extends State<KingsCordSettings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Room Settings"),
          actions: [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // child 1 : we want to allow people subscribe to a cord this way they will get notifications
              Text("Subscribe to this chat Room to get notifications for all messages that are sent"),
              ElevatedButton(onPressed: () {
                // update the kc to add the user id to the subscribed info
                // FirebaseFirestore.instance.collection(Paths.communityMembers).doc(widget.cmId).collection(Paths.)
              }, 
              child: Text("Subscribe"))

              // child 2


            ],
          ),
        ),
      ),
    );
  }
}