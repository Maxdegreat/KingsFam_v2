// This screen allows for room options such as what role can type
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/base/animation/interpolation/linear.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/notification_helper.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class KingsCordRoomSettingsArgs {
  final Church cm;
  final KingsCord kc;
  const KingsCordRoomSettingsArgs({required this.cm, required this.kc});
}

class KingsCordRoomSettings extends StatefulWidget {
  final Church cm;
  final KingsCord kc;
  KingsCordRoomSettings({Key? key, required this.cm, required this.kc})
      : super(key: key);
  static const String routeName = "/KingsCordRoomSettings";
  static Route route({required KingsCordRoomSettingsArgs a}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return KingsCordRoomSettings(cm: a.cm, kc: a.kc);
      },
    );
  }

  @override
  State<KingsCordRoomSettings> createState() => _KingsCordRoomSettingsState();
}

class _KingsCordRoomSettingsState extends State<KingsCordRoomSettings> {
  String? kcName;
  String roleWithWritePermissions = "Member";

  Set roles = {};

  @override
  void initState() {
    kcName = widget.kc.cordName;
    if (widget.kc.metaData != null && widget.kc.metaData?["roles"] != null) {
      roles = widget.kc.metaData?["roles"].toSet();
    }
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
                    Text("Below shows the roles of people who are allowed to add to this room (type, share links, images, gifs ect...)", style: Theme.of(context).textTheme.caption),
                    SizedBox(
                      height: 7,
                    ),
                    _rowOfRoles(),
                    
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
            if (roles.isNotEmpty) {
              widget.kc.metaData?["roles"] = roles.toList();
            }

              
            // direct api call
            FirebaseFirestore.instance.collection(Paths.church).doc(widget.cm.id).collection(Paths.kingsCord).doc(widget.kc.id).update({
              "cordName" : kcName,
              "metaData":  widget.kc.metaData
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

   Widget _rowOfRoles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textForRR("All Members"),
          _textForRR("Mods, Admins and Leads"),
          _textForRR("Lead and Admins"),
        ],
      ),
    );
  }

  _textForRR(String text) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            if (roles.isNotEmpty) {
              roles.clear();
              roles.add(text);
            } else {
              roles.add(text);
            }
            setState(() {});
          },
          child: Container(
              decoration: BoxDecoration(
                  border: roles.contains(text)
                      ? Border.all(color: Colors.greenAccent, width: .7)
                      : null,
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(7)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.caption,
                ),
              )),
        ),
      );

 
}
