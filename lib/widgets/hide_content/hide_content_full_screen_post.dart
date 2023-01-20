import 'package:flutter/material.dart';

class HideContent {
  static Widget postFullScreen(VoidCallback? callback) => Container(
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
              child: ListTile(
                leading: Icon(Icons.block_flipped, size: 40, color: Colors.redAccent,),
                title: Text(
                "Hiddend post",
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
              ),
            ),
            // child 2 "Hiddend post"
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(Icons.remove_red_eye, color: Colors.white,),
                title: Text(
                "Show post",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: callback,
              )
            ),
            // child 3 "Hiddend post" post is hiddend possibly because you have blocked this users content
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "post is hiddend possibly because you have blocked this users content.",
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

      static Widget textContent(TextTheme t, VoidCallback? callback) => Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: callback,
                child: Text("Show", style: t.caption)),
              SizedBox(height: 7,), 
              Text("Content is hiddend. possibly because you have blocked this user.", style: t.subtitle1!.copyWith(color: Colors.redAccent))
            ]
          ),
        ),
      );
}
