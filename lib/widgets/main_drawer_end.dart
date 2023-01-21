
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/report_content_screen.dart';

Widget MainDrawerEnd(Widget memberBtn, Widget settingsBtn, BuildContext context, Church cm) {
  return SafeArea(
    child: Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
    // Add a ListView to the drawer. This ensures the user can scroll
    // through the options in the drawer if there isn't enough vertical
    // space to fit everything.
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [

        settingsBtn,
        memberBtn,

        ListTile(
          leading: Icon(Icons.report),
          title: Text("Report", style: Theme.of(context).textTheme.caption,),
          onTap: () {
                Map<String, dynamic> info = {
                  "userId" : cm.id,
                  "what" : "cm",
                  "continue": FirebaseFirestore.instance.collection(Paths.posts).doc(cm.id),                 
                };
            Navigator.of(context).pushNamed(ReportContentScreen.routeName, arguments: RepoetContentScreenArgs(info: info));
          },
        ), 

        ListTile(
          leading: Icon(Icons.more_vert),
          title: Text("more", style: Theme.of(context).textTheme.caption,),
          onTap: () => Navigator.of(context).pushNamed(CommunityHome.routeName, arguments: CommunityHomeArgs(cm: cm, cmB: null)),
        )
      ],
    ),
    ),
  );
}