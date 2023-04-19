//This file takes a controller as a required pram 
//if controller is initialized we pass it to build video
//     this is where the constrained box for the widget exist.
//else we show a circular progress indicatior
import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  const VideoPlayerWidget({Key? key, required this.controller}): super(key: key);

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
      ? ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.infinity,
          minHeight: 900), //size of video player in app
        child: BuildVideo(controller: this.widget.controller,)
        )
      //Container(height: 250, child: BuildVideo(controller: controller))
      : Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.amber,
          )));
}
}