import 'dart:io';

import 'package:flutter/material.dart';

Future<void> helpDialog(BuildContext context) async {
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
      content: howToBox(),
    );
  }
);
}

Widget howToBox() {
  return StatefulBuilder(
    builder: (BuildContext context, setState) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.grey[900]),
        height: 300,
        child: PageView.builder(
          itemCount: 3,
          itemBuilder: (_, i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Text("Step 1."),
            );
          }
        ),
      );
    },
  );
}

class onboardingContent {
  final File image;
  final String text;

  onboardingContent(this.image, this.text);
}

List<Widget> _contents() {
  return   [
    Container(),
    Container(),
    Container(),
  ];
}