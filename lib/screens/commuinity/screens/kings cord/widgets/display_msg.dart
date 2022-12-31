import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/models/says_model.dart';

class DisplayMsg extends StatelessWidget {
  final Message? m;
  final Says? s;
  const DisplayMsg({Key? key, required this.m, required this.s})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle s = Theme.of(context).textTheme.caption!;
    Size size = MediaQuery.of(context).size;
    if (m != null) {
      if (m!.text == welcomeMsgEncoded) {
        log("seen");
        return _welcomMsg(size, s);
      } else if (m!.text == firstMsgEncoded) {
        return _newRoom(size, s);
      } else if (m!.text != welcomeMsgEncoded) {
        return _msg(size, s);
      } else {
        return _welcomMsg(size, s);
      }
    } else {
      return _says(size, s);
    }
  }

  _says(Size size, TextStyle s) {
    return Container(
      height: (size.height / 9) / 2.5,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: Center(
        child: Text(
          this.s!.author!.username + ": " + this.s!.title!,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }

  _welcomMsg(Size size, TextStyle s) {
    return Container(
      height: (size.height / 9) / 2.5,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(46, 255, 193, 7),
      ),
      child: Center(
        child: Text(
          "Welcome " + m!.sender!.username,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }

  _newRoom(Size size, TextStyle s) {
    return Container(
      height: (size.height / 9) / 2,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Color.fromARGB(45, 36, 255, 7),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              m!.sender!.username + " created This room",
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: s,
            ),
          ),
        ),
      ),
    );
  }

  _msg(Size size, TextStyle s) {
    String msg = m!.text != null ? m!.text! : " shared something";
    return Container(
      height: (size.height / 9) / 2,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: Center(
        child: Text(
          m!.sender!.username + ": " + msg,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }
}
