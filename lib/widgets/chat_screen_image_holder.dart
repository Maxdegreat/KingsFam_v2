import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatImage extends StatelessWidget {
  final String chatUrl;
  //final File? pfpImage; //if not null user wants to update image
  const ChatImage({
    Key? key,
    required this.chatUrl,
    //this.pfpImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
                image: CachedNetworkImageProvider(chatUrl), fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                topLeft: Radius.circular(10.0))));
  }

  // Icon? _noProfileIcon() {
  //  if (pfpImage == null && pfpUrl.isEmpty) {
  //    return Icon(Icons.account_circle,
  //        color: Colors.grey[400], size: radius * 2);
  //  }
  //  return null;
  //}
}
