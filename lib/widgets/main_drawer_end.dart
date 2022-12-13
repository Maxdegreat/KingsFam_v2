
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';

Widget MainDrawerEnd(Widget memberBtn, Widget settingsBtn, BuildContext context) {
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
      ],
    ),
    ),
  );
}