
import 'package:flutter/material.dart';

Widget MainDrawerEnd(Widget memberBtn, Widget settingsBtn) {
  return SafeArea(
    child: Drawer(
      
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