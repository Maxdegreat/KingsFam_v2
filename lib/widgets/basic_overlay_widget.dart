import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BasicOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  //pass the post here so when double pated it will increcent the like if post is not null
  const BasicOverlayWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      controller.value.isPlaying ?  controller.pause() : controller.play();
    },
    child: Stack(
          children: [
            isPlay(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildIndicator(),
            )
          ],
        ),
  );

  Widget buildIndicator() =>
      VideoProgressIndicator(controller, allowScrubbing: true);
  Widget isPlay() => controller.value.isPlaying
      ? SizedBox.shrink()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: Icon(Icons.play_arrow_outlined, size: 38,), // add a color to the play btn latter if you want
        );
}
