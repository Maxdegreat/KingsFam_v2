import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertDialogKf extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback cb;
  final String cbTxt;

  const AlertDialogKf(
      {Key? key, required this.title, required this.content, required this.cb, required this.cbTxt})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _showIOSDialog(context)
        : _showAndroidDialog(context);
  }

  CupertinoAlertDialog _showIOSDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),

        CupertinoDialogAction(
          onPressed: () => this.cb,
          child: Text(this.cbTxt) ,
        )

      ],
    );
  }

  AlertDialog _showAndroidDialog(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: 
      [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      
        TextButton(
          onPressed: () => this.cb,
          child: Text(this.cbTxt),
        )

      ],
    );
  }
}
