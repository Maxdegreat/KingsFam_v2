import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/widgets/snackbar.dart';

// I will make this class here because atm this is the only place this will be used
class RoomNotifications extends Equatable {
  final String? id;
  final bool recent;
  final bool all;

  const RoomNotifications({this.id, required this.recent, required this.all});

  @override
  List<Object?> get props => [recent, all];

  RoomNotifications copyWith({
    String? id,
    bool? recent,
    bool? all,
  }) {
    return RoomNotifications(
      id: id ?? this.id,
      recent: recent ?? this.recent,
      all: all ?? this.all,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'recent': recent,
      'all': all,
    };
  }

  static RoomNotifications fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomNotifications(
        recent: data['recent'] ?? false, all: data['all'] ?? false);
  }
}

class KingsCordSettingsArgs {
  final String kcId;
  final String cmId;
  const KingsCordSettingsArgs({required this.cmId, required this.kcId});
}

class KingsCordSettings extends StatefulWidget {
  final String kcId;
  final String cmId;
  const KingsCordSettings({Key? key, required this.cmId, required this.kcId})
      : super(key: key);

  // ok so now we do the do the route and route name
  static const String routeName = "KingsCordSettingsArgs";

  static Route route({required KingsCordSettingsArgs args}) {
    return MaterialPageRoute(builder: (context) {
      return KingsCordSettings(cmId: args.cmId, kcId: args.kcId);
    });
  }

  @override
  State<KingsCordSettings> createState() => _KingsCordSettingsState();
}

class _KingsCordSettingsState extends State<KingsCordSettings> {
  // class properties

  // this is the status for the individual user
  RoomNotifications _roomNotifications =
      RoomNotifications(recent: false, all: false);

  Map<String, dynamic> roomOptions = {
    "recent": [],
    "all": [],
  };

  // this is the individual settings from user -> cm -> kc.
  // if ture add to the room options list where true else rm
  Map<String, dynamic> roomSettingsLocal = {
    "recent": false,
    "all": false,
  };

  bool recentState = false;
  bool allState = false;

  bool loadingIndecator = true;

  @override
  void initState() {
    super.initState();
    getCurrOptions();
    getSettings();
  }

  @override
  Widget build(BuildContext context) {
    final String currId = context.read<AuthBloc>().state.user!.uid;

    var _path = FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(widget.cmId)
        .collection(Paths.kingsCord)
        .doc(widget.kcId)
        .collection(Paths.roomSettings)
        .doc(widget.kcId);

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
              loadingIndecator ? LinearProgressIndicator() : SizedBox.shrink(),
              // child 1 : we want to allow people subscribe to a cord this way they will get notifications
              Text("Receive notifications if you are within the last 15 to send a message in this room."),
              Text(
                roomSettingsLocal["recent"] == true
                    ? "You will be notified if your activity was recent."
                    : "You are currently not being notified",
                style: roomSettingsLocal["recent"] == true
                    ? TextStyle(color: Colors.green)
                    : TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 7,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (roomSettingsLocal["recent"] == true) {
                      roomSettingsLocal["recent"] = false;
                      setState(() {});
                      snackBar(
                          snackMessage: "settings updated",
                          context: context,
                          bgColor: Colors.green);
                      roomOptions["recent"].remove(currId);
                      update(_path);
                      updateRoomSettings(currId: currId, data: roomSettingsLocal);
                    } else {
                      roomSettingsLocal["recent"] = true;
                      setState(() {});
                      snackBar(
                          snackMessage: "settings updated",
                          context: context,
                          bgColor: Colors.green);
                      roomOptions["recent"].add(currId);
                      update(_path);
                      updateRoomSettings(currId: currId, data: roomSettingsLocal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(hc.hexcolorCode("#141829")),
                      shape: StadiumBorder(),
                      elevation: 0),
                  child: Text("Notify Me")),

              // child 2

              Text("Receive all notifications from this room."),
              Text(
                roomSettingsLocal["all"] == true
                    ? "You will be notified of all notifications."
                    : "You are currently not being notified",
                style: roomSettingsLocal["all"] == true
                    ? TextStyle(color: Colors.green)
                    : TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 7,
              ),
              ElevatedButton(
                  onPressed: () {
                    if (roomSettingsLocal["all"] == true) {
                      roomSettingsLocal["all"] = false;
                      setState(() {});
                      snackBar(
                          snackMessage: "settings updated",
                          context: context,
                          bgColor: Colors.green);
                      roomOptions["all"].remove(currId);
                      update(_path);
                      updateRoomSettings(currId: currId, data: roomSettingsLocal);
                    } else {
                      roomSettingsLocal["all"] = true;
                      setState(() {});
                      snackBar(
                          snackMessage: "settings updated",
                          context: context,
                          bgColor: Colors.green);
                      roomOptions["all"].add(currId);
                      update(_path);
                      updateRoomSettings(currId: currId, data: roomSettingsLocal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      primary: Color(hc.hexcolorCode("#141829")),
                      shape: StadiumBorder(),
                      elevation: 0),
                  child: Text("Notify Me")),
            ],
          ),
        ),
      ),
    );
  }

  // functions will go here as this class currrently does not have a BLOC

  // get current settings
  // stored in users -> cm -> kc
  Future<void> getSettings() async {
    String currId = context.read<AuthBloc>().state.user!.uid;
    DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
        .collection(Paths.users)
        .doc(currId)
        .collection(Paths.church)
        .doc(widget.cmId)
        .collection(Paths.kingsCord)
        .doc(widget.kcId)
        .get();
    if (settingsSnap.exists) {
      RoomNotifications _rn = RoomNotifications.fromDoc(settingsSnap);
      roomSettingsLocal["all"] = _rn.all;
      roomSettingsLocal["recent"] = _rn.recent;
    }
    setState(() {
      loadingIndecator = false;
    });
  }

  // the public list of users who are getting notifs
  Future<void> getCurrOptions() async {
    String currId = context.read<AuthBloc>().state.user!.uid;
    DocumentSnapshot settingsSnap = await FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(widget.cmId)
        .collection(Paths.kingsCord)
        .doc(widget.kcId)
        .collection(Paths.roomSettings)
        .doc(widget.kcId)
        .get();
    if (settingsSnap.exists) {
      // get the info
      log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      Map<String, dynamic> data = settingsSnap.data() as Map<String, dynamic>;
      roomOptions["all"] = data["all"];
      roomOptions["recent"] = data["recent"];
    } else {
      // make new info for first time
      log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      roomOptions["all"] = [];
      roomOptions["recent"] = [];
    }
  }

  update(path) {
    try {
      log("Passsssssssssssssssss");
      path.set({}, SetOptions(merge: true));
      path.update({"recent": roomOptions["recent"], "all": roomOptions["all"]});
    } catch (e) {
      log("failllllllllllllllllll");
      path.set({"recent": roomOptions["recent"], "all": roomOptions["all"]});
      // try again
      path.update({"recent": roomOptions["recent"], "all": roomOptions["all"]});
    }
  }

  // this is local to the curr user
  updateRoomSettings({
    required String currId,
    required Map<String, dynamic> data,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Paths.users)
        .doc(currId)
        .collection(Paths.church)
        .doc(widget.cmId)
        .collection(Paths.kingsCord)
        .doc(widget.kcId);

    DocumentSnapshot snap = await ref.get();
    // okay now we have the snap. check if user has any settings for this room
    if (snap.exists) {
      // use the update
      ref.update(data);
    } else {
      // use the set
      ref.set(data);
    }
  }
}
