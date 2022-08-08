import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


Widget buildVideoPlayer({required VideoPlayerController controller}) =>
      AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));