

  import 'package:flutter/material.dart';

Widget drawerIcon(Icon i) {
    return Container(
      height: 50,
      width: 50,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: i,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(120, 255, 145, 0)
      ),
    );
  }