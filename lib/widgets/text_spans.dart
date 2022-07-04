import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class TextSpansForRichText {

   dispose() {
    children = [];
  }

  // default text for messages in kingsCord
  TextSpan defaultTextForMessagesInKingsCord({required String msg}) => TextSpan(
      text: msg,
      style: TextStyle(
          color: Colors.pink[400],
          fontSize: 17.0,
          fontWeight: FontWeight.w800));

  // link text for messages
   TextSpan linkTextForMessages({required String link}) => TextSpan(
      text: link,
      recognizer: TapGestureRecognizer()..onTap = () => launchLink(link),
      style: TextStyle(
        fontSize: 22,
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ));

  // mentioned Text for messages
   TextSpan mentionedTextForMessages({required String msg}) => TextSpan(
    text: msg,
      style: TextStyle(
          color: Colors.blue,
          fontSize: 17.0,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800)
  );

   launchLink(String link) async {
    launch(link);
  }
    List<InlineSpan> children = [];

  // parsed to formated stings for message generator
//    List<InlineSpan> parsedStringToFormatedForMessageGenerator ({required fuleAsString}) {
//     var msgAsList = fuleAsString.split("{{"); // This is an example message. look at {{a-https://someUrl}} {{b-@maximus}} -> This is an example message. look at ||
//     // it has a {{a-https://...}} and a {{b-@username}} ...
//     // hi maximus agu {{a-@max}} - > hi maximus agu | a-@max}}
//     for (String msg in msgAsList) {
//       if (msg[2].endsWith('}}')) {
//         if (msg[2].startsWith('a-')) {
//           log("this is a web link, adding $msg to children");
//           // web link
//           children.add(linkTextForMessages(link: msg));
//         } else if (msg[2].startsWith('b-')) {
//           log("This is a mention link adding $msg to children");
//           // mentioned
//           children.add(mentionedTextForMessages(msg: msg));
//         }
//       } else {
//         log("adding $msg as a default");
//         children.add(defaultTextForMessagesInKingsCord(msg: msg));
//       }
//     }
//     return children;
// }
}