import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/models/says_model.dart';

class DisplayMsg extends StatelessWidget {
  final Message? m;
  final Says? s;
  const DisplayMsg({Key? key, required this.m, required this.s})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme s = Theme.of(context).textTheme;
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

  _says(Size size, TextTheme s) {
    return Container(
      height: (size.height / 9) / 2.5,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: Center(
        child: RichText(
          overflow: TextOverflow.clip,
          maxLines: 2,
          softWrap: true,
          text: TextSpan(
            text: this.s!.author!.username + ": ",
            style: s.subtitle1!.copyWith(fontWeight: FontWeight.w400),
            children: <TextSpan>[
              TextSpan(text: this.s!.title, style: s.caption),

            ],
          ),
)
        
        
        // Text(
        //   this.s!.author!.username + ": " + this.s!.title!,
        //   softWrap: true,
        //   maxLines: 2,
        //   overflow: TextOverflow.fade,
        //   style: s,
        // ),
      ),
    );
  }

  _welcomMsg(Size size, TextTheme s) {
    return Container(
      height: (size.height / 9) / 2.5,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(46, 255, 193, 7),
      ),
      child: Center(
        child: RichText(
          text: TextSpan( 
            text: "Welcome " + m!.sender!.username, 
            style: s.subtitle1!.copyWith(fontWeight: FontWeight.w400),
            children: [
              TextSpan(
                text: "just joined 🥳",
                style: s.caption!.copyWith(fontStyle: FontStyle.italic)
              )
            ]
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  _newRoom(Size size, TextTheme s) {
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
          child: Padding( // m!.sender!.username + " created This room",
            padding: const EdgeInsets.all(2.0),
            child: RichText(
          text: TextSpan( 
            text: m!.sender!.username + " created This room", 
            style: s.subtitle1!.copyWith(fontWeight: FontWeight.w400),
            children: [
              TextSpan(
                text: m!.date.timeAgo(),
                style: s.caption!.copyWith(fontStyle: FontStyle.italic)
              )
            ]
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
        ),
          ),
        ),
      ),
    );
  }

  _msg(Size size, TextTheme s) {
    String msg = m!.text != null ? m!.text! : " shared something";
    return Container(
      height: (size.height / 9) / 2,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: Center(
        child: RichText(
          text: TextSpan(
            text:  m!.sender!.username + ": ",
            style: s.subtitle1,
            children: [
              TextSpan(
                text: msg,
                style: s.caption!.copyWith(fontStyle: FontStyle.italic)
              )
            ]
          ),
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }
}
