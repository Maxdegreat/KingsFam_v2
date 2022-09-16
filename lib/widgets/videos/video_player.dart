//This file takes a controller as a required pram 
//if controller is initialized we pass it to build video
//     this is where the constrained box for the widget exist.
//else we show a circular progress indicatior
import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  final Post post;
  final Userr user;
  const VideoPlayerWidget({Key? key, required this.controller, required this.post, required this.user}): super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  @override
  void deactivate() {
    widget.controller.dispose();
    super.deactivate();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) { 

    return widget.controller.value.isInitialized
      ? BuildVideo(controller: this.widget.controller, post: widget.post, user: widget.user,)
      //Container(height: 250, child: BuildVideo(controller: controller))
      : Container(
          height: 250,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.red[400],
          )));
}
}