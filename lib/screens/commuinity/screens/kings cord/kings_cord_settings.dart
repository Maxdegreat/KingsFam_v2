import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';

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
  RoomNotifications _roomNotifications =
      RoomNotifications(recent: false, all: false);

  Map<String, dynamic> roomOptions = {
    "recent": [],
    "all": [],
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
              Text(
                  "Receive notifications if you are within the last 15 to send a message in this room."),
              Checkbox(
                  value: recentState,
                  onChanged: (bool? value) {


                    if (_roomNotifications.recent != true) {
                      // auto update and make true bc we just clicked
                      roomOptions["recent"].add(currId);
                      roomOptions["recent"].toSet();
                      _roomNotifications.copyWith(recent: true);
                      setState(() {});
                    } else {
                      roomOptions["recent"].toSet().remove(currId);
                      _roomNotifications.copyWith(recent: false);
                      setState(() {});
                    }
                    // now do the auto update in db
                    _path.set(roomOptions);
                  }),

              // child 2

              Text("Receive all notifications from this room."),
              Checkbox(
                value: _roomNotifications.recent,
                onChanged: (bool? value) {
                  setState(() {
                    _roomNotifications.copyWith(
                        recent: _roomNotifications.recent,
                        all: !_roomNotifications.all);
                  });

                  if (_roomNotifications.all != true) {
                    // auto update and make true bc we just clicked
                    roomOptions["all"].add(currId).toSet();
                  } else {
                    roomOptions["all"].toSet().remove(currId);
                  }
                  // now do the auto update in db
                  _path.set(roomOptions);
                },
              ),
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
        .doc(widget.cmId)
        .get();
    if (settingsSnap.exists) {
      RoomNotifications _rn = RoomNotifications.fromDoc(settingsSnap);
      _roomNotifications.copyWith(recent: _rn.recent, all: _rn.all);
      setState(() {
        recentState =  _rn.recent;
        allState = _rn.all;
      });
    }
    log("made it to the end ye hearddd");
    setState(() {
      
      loadingIndecator = false;
    });
  }

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
    if (settingsSnap.exists) {}
  }
}
