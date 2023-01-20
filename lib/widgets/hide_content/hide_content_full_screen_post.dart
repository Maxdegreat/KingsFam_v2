import 'package:flutter/material.dart';

class HideContent {
  static Widget postFullScreen() => Container(
        color: Colors.grey[900],
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // child 1 Icon
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.block_flipped, size: 40, color: Colors.redAccent,),
            ),
            // child 2 "Hiddend post"
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Hiddend post",
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
            ),
            // child 3 "Hiddend post" post is hiddend possibly because you have blocked this users content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "post is hiddend possibly because you have blocked this users content. This post will be reviewed if reported and removed if violates KingsFam's safty guidelines.",
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

      static Widget textContent() => Text("Content is hiddend. possibly because you have blocked this user.", style: TextStyle(color: Colors.redAccent, fontSize: 17));
}
