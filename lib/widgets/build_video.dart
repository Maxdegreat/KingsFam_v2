// This widget acepts a required controller
// calls the build video which handels the aspect ratio and
// handels the call of videoplayer and basicoverlay widget is also a nested call
// nested in build_video_player
import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

class BuildVideo extends StatelessWidget {
  final VideoPlayerController controller;
  const BuildVideo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverlayWidget(controller: controller))
          //add btn that will allow fill of video on width
        ],
      );
  Widget buildVideoPlayer() =>
      AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));
}
