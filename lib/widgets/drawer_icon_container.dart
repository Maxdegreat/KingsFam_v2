

  import 'package:flutter/material.dart';

Widget drawerIcon(Icon i) {
    return CircleAvatar(
      backgroundColor: Color.fromARGB(120, 255, 145, 0),
      radius: 25,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: i,
      ));
  }