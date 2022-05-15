import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPostView16_9 extends StatefulWidget {
  final String videoUrl;
  final ScrollController? scrollCtrl;
  final Post post;
  final Userr userr;
  const VideoPostView16_9({
    Key? key, 
    required this.videoUrl, 
    required this.post,
    required this.userr,
    this.scrollCtrl
    })
    : super(key: key);

  @override
  State<VideoPostView16_9> createState() => _VideoPostView16_9State();
}

class _VideoPostView16_9State extends State<VideoPostView16_9> {

  late VideoPlayerController controller;
  @override
  void initState() {
    super.initState();

    // HERE IS MY MASTER PLAN ALGO IDEA.
    // PASS POST.ID ACCORDING TO SCROLL CONTROLLER
    // IF ID.POSTVIDEO != NULL PLAY VIDEO ONCE OFFSET MOVES PAUSE THE VIDEO.

    controller = VideoPlayerController.network(widget.videoUrl)
      ..addListener(() => setState(() {}))
      ..setLooping(true)
      ..initialize().then((_) => controller.pause());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Center(child: VideoPlayerWidget(controller: controller, post: widget.post, user: widget.userr,)),
    );
  }
}