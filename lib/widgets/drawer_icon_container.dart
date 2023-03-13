

  import 'package:flutter/material.dart';

Widget drawerIcon(Widget i, BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSecondary,
      borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: i,
      ));
  }