import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/models/says_model.dart';

class DisplayMsg extends StatelessWidget {
  final Message? m;
  final Says? s;
  final int? amountInVc;
  const DisplayMsg({Key? key, required this.m, required this.s, required this.amountInVc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextTheme s = Theme.of(context).textTheme;
    Size size = MediaQuery.of(context).size;
    if (m != null) {
      if (m!.text == welcomeMsgEncoded) {
        return _welcomMsg(size, s);
      } else if (m!.text == firstMsgEncoded) {
        return _newRoom(size, s);
      } else if (m!.text != welcomeMsgEncoded) {
        return _msg(size, s);
      } else {
        return _welcomMsg(size, s);
      }
    } else if (this.s != null) {
      return _says(size, s);
    } else if (this.amountInVc != null) {
      return _showAmountInVc(s);
    } else 
      return SizedBox.shrink();
   
  }

  _says(Size size, TextTheme s) {
    return Container(
      // height: (size.height / 9) / 2.5,
      // width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        //color: Color.fromARGB(46, 255, 193, 7),
      ),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: true,
        text: TextSpan(
          text: this.s!.author!.username,
          style: s.subtitle1!.copyWith(color: Colors.grey).copyWith(fontWeight: FontWeight.w400),
          children: <TextSpan>[
            TextSpan(text: " posted ", style: s.subtitle1!.copyWith(color: Colors.grey)!.copyWith(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic)),
            TextSpan(text: this.s!.title!+"\n", style: s.subtitle1!.copyWith(color: Colors.grey)!.copyWith(fontWeight: FontWeight.w400)),
            TextSpan(text: this.s!.contentTxt, style: s.caption,),
          ],
        ),
),
    );
  }

  _welcomMsg(Size size, TextTheme s) {
    return Container(
      //height: (size.height / 9) / 2.5,
      // width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(46, 255, 193, 7),
      ),
      child: RichText(
        text: TextSpan( 
          text: "Welcome " + m!.sender!.username, 
          style: s.subtitle1!.copyWith(color: Colors.grey)!.copyWith(fontWeight: FontWeight.w400),
          children: [
            TextSpan(
              text: " just joined 🥳",
              style: s.caption!.copyWith(fontStyle: FontStyle.italic)
            )
          ]
        ),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _newRoom(Size size, TextTheme s) {
    return Container(
      // height: (size.height / 9) / 2,
      // width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Color.fromARGB(19, 36, 255, 7),
        ),
        child: Padding( // m!.sender!.username + " created This room",
          padding: const EdgeInsets.all(2.0),
          child: RichText(
        text: TextSpan( 
          text: m!.sender!.username + " created This room\n", 
          style: s.subtitle1!.copyWith(color: Colors.grey)!.copyWith(fontWeight: FontWeight.w400),
          children: [
            TextSpan(
              text: m!.date.timeAgo(),
              style: s.caption!.copyWith(fontStyle: FontStyle.italic)
            )
          ]
        ),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
        ),
      ),
    );
  }

  _msg(Size size, TextTheme s) {
    String msg = m!.text != null ? m!.text! : " shared something";
    return Container(
      //height: (size.height / 9) / 2,
      //width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: RichText(
        text: TextSpan(
          text:  m!.sender!.username + ": ",
          style: s.subtitle1!.copyWith(color: Colors.grey),
          children: [
            TextSpan(
              text: msg,
              style: s.caption!.copyWith(fontStyle: FontStyle.italic)
            )
          ]
        ),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  _showAmountInVc(TextTheme s) {
    return Text(amountInVc.toString() + " / 10", style: s.caption!.copyWith(fontStyle: FontStyle.italic));
  }
}
