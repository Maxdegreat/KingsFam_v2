// This screen allows for room options such as what role can type
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/base/animation/interpolation/linear.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/notification_helper.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class KingsCordRoomSettingsArgs {
  final String cmId;
  final KingsCord kc;
  const KingsCordRoomSettingsArgs({required this.cmId, required this.kc});
}

class KingsCordRoomSettings extends StatefulWidget {
  final String cmId;
  final KingsCord kc;
  KingsCordRoomSettings({Key? key, required this.cmId, required this.kc})
      : super(key: key);
  static const String routeName = "/KingsCordRoomSettings";
  static Route route({required KingsCordRoomSettingsArgs a}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return KingsCordRoomSettings(cmId: a.cmId, kc: a.kc);
      },
    );
  }

  @override
  State<KingsCordRoomSettings> createState() => _KingsCordRoomSettingsState();
}

class _KingsCordRoomSettingsState extends State<KingsCordRoomSettings> {
  String? kcName;
  bool switchValue = false;
  String roleWithWritePermissions = "Member";
  @override
  void initState() {
    kcName = widget.kc.cordName;

    if (widget.kc.metaData != null &&
        widget.kc.metaData!.containsKey("writePermissions"))
      roleWithWritePermissions = widget.kc.metaData!["writePermissions"];

    if (widget.kc.mode == "anouncment")
      switchValue = true;
    else
      switchValue = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
       onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: (AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).iconTheme.color,
                )),
            title: Text("Room settings",
                style: Theme.of(context).textTheme.bodyText1),
            actions: [_save()],
          )),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 1,
                width: MediaQuery.of(context).size.width / 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Room name", style: Theme.of(context).textTheme.bodyText1),
                    SizedBox(height: 20),
                    // update title if has mod role
                    _updateTitle(theme),
                    Divider(
                      height: 8,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    // who can write based on role
                    _writeAccess(theme),
                    SizedBox(
                      height: 3,
                    ),
              
                    _showRoomWritePermissions(theme),
                    SizedBox(height: 7),
              
                    // update to anouncment room or back to chat room (if anouncment only admin and up can type)
                    _switchToAnouncmentRoom(theme),
                    SizedBox(
                      height: 7,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _save() {
    // update the data in db
    return TextButton(
        onPressed: () {
          if (kcName == "" || kcName!.isEmpty) {
            return snackBar(
                snackMessage:
                    "your room name can not be empty, fill name and try again",
                context: context,
                bgColor: Colors.red);
          } else {
            Map<String, dynamic> temp = {};
            if (widget.kc.metaData != null && widget.kc.metaData!.containsKey("writePermissions")) {
              widget.kc.metaData!["writePermissions"] = roleWithWritePermissions;
              temp = widget.kc.metaData!;
            }
            else  
              temp["writePermissions"] = roleWithWritePermissions;
            // direct api call
            FirebaseFirestore.instance.collection(Paths.church).doc(widget.cmId).collection(Paths.kingsCord).doc(widget.kc.id).update({
              "cordName" : kcName,
              "mode": switchValue ? "anouncments" : "chat",
              "metaData": temp
            });
            snackBar(snackMessage: "Saving", context: context, bgColor: Colors.green);
            Navigator.of(context).pop();
          }
        },
        child: Text("Save"));
  }

  Widget _updateTitle(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: kcName,
        border: InputBorder.none,
      ),
      onChanged: (value) {
        if (value.length > 25) {
          snackBar(
              snackMessage: "name must be 25 characters or less",
              context: context,
              bgColor: Colors.red);
        } else {
          kcName = value;
        }
      },
    );
  }

  Widget _writeAccess(ThemeData theme) {
    return ListTile(
      leading: Icon(Icons.shield),
      title: Text(
        "Room permissions",
        style: theme.textTheme.caption,
      ),
      // trailing: Icon(Icons.arrow_forward_ios),
    );
  }

  Widget _showRoomWritePermissions(ThemeData theme) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // child 1 is lead
          _listTileForWritePermissions("Lead", theme),
          _listTileForWritePermissions("Admin", theme),
          _listTileForWritePermissions("Mod", theme),
          _listTileForWritePermissions("Member", theme)
        ],
      ),
    );
  }

  Widget _listTileForWritePermissions(String role, ThemeData t) => ListTile(
            leading: Text(role, style: t.textTheme.bodyText1),
            onTap: () {
              setState(() {roleWithWritePermissions = role;});
            },
            trailing: Checkbox(
              checkColor: Theme.of(context).colorScheme.onPrimary,
              fillColor: MaterialStateProperty.all(Colors.amber),
              value: roleWithWritePermissions == role,
              onChanged: (bool? value) {
                setState(() {roleWithWritePermissions = role;  });
              },
            ));

  Widget _switchToAnouncmentRoom(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Anouncment Room ", style: theme.textTheme.caption),
        Switch(
            activeColor: Theme.of(context).colorScheme.primary,
            value: switchValue,
            onChanged: (newVal) {
              setState(() {
                switchValue = newVal;
              });
            })
      ],
    );
  }
}
