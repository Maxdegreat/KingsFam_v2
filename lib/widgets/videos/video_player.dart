//This file takes a controller as a required pram 
//if controller is initialized we pass it to build video
//     this is where the constrained box for the widget exist.
//else we show a circular progress indicatior
import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController controller;
  final Post post;
  final Userr user;
  const VideoPlayerWidget({Key? key, required this.controller, required this.post, required this.user}): super(key: key);

  @override
  Widget build(BuildContext context) => controller.value.isInitialized
      ? ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          minHeight: 900), //size of video player in app
        child: BuildVideo(controller: this.controller, post: post, user: user,)
        )
      //Container(height: 250, child: BuildVideo(controller: controller))
      : Container(
          height: 250,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.red[400],
          )));
}
