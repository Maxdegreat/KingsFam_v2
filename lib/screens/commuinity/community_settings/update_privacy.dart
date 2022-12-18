import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/config/cm_privacy.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/widgets/widgets.dart';

class UpdatePrivacyCmArgs {
  final Church cm;
  UpdatePrivacyCmArgs({required this.cm});
}

class UpdatePrivacyCm extends StatefulWidget {
  final Church cm;
  const UpdatePrivacyCm({Key? key, required this.cm}) : super(key: key);

  static const String routeName = "updatePrivacyCm";

  static Route route({required UpdatePrivacyCmArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) {
          return UpdatePrivacyCm(
            cm: args.cm,
          );
        }));
  }

  @override
  State<UpdatePrivacyCm> createState() => _UpdatePrivacyCmState();
}

class _UpdatePrivacyCmState extends State<UpdatePrivacyCm> {
  VoidCallback armored () => 
    () =>
      vcHelp(CmPrivacy.armored);
  VoidCallback shielded () => 
    () => vcHelp(CmPrivacy.shielded);
  VoidCallback open () =>
    () => vcHelp(CmPrivacy.open);

  vcHelp(String cmPrivacy) {
    log("updating your cm privacy");
    snackBar(snackMessage: "Updating your commuinity privacy", context: context);
    return FirebaseFirestore.instance.collection(Paths.cmPrivacy).doc(widget.cm.id).set({"privacy":cmPrivacy});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Updating ${widget.cm.name}'s privacy", style: Theme.of(context).textTheme.bodyText1,),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   width: MediaQuery.of(context).size.width/1.7,
          //   child: Text("If your"),
          // )
          EmbedTextIcon(context: context, iconData: Icons.health_and_safety_outlined, text: "armored", voidCallback: armored()),
          // EmbedTextIcon(context: context, iconData: Icons.shield_outlined, text: "shielded", voidCallback: shielded()),
          EmbedTextIcon(context: context, iconData: FontAwesomeIcons.lockOpen, text: "open", voidCallback: open()),
        ],
      ),
    );
  }

  GestureDetector EmbedTextIcon({ required BuildContext context, required String text, required IconData iconData, required VoidCallback voidCallback}) {
    return GestureDetector(
          onTap: () {
            voidCallback();
            snackBar(snackMessage: "The Status has been updated", context: context);
            Navigator.of(context).pop();
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color(hc.hexcolorCode('#1b2136')),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text + " ", style: Theme.of(context).textTheme.bodyText1,),
                  Icon(iconData)
                ],
              ),
            ),
          ),
        );
  }
}
