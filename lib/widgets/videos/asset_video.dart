import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/videos/build_video_player.dart';
import 'package:video_player/video_player.dart';

class AssetVideoPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  final double height;
  final double width;
  const AssetVideoPlayer({
    Key? key,
    required this.controller,
    this.height = 70,
    this.width = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => controller.value.isInitialized
      ? ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: this.width,
              minHeight: this.height), //size of video player in app
          child: buildVideoPlayer(controller: controller))
      //Container(height: 250, child: BuildVideo(controller: controller))
      : SizedBox.shrink();
}
