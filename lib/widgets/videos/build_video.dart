// This widget acepts a required controller
// calls the build video which handels the aspect ratio and
// handels the call of videoplayer and basicoverlay widget is also a nested call
// nested in build_video_player
import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

import 'build_video_player.dart';

class BuildVideo extends StatelessWidget {
  final VideoPlayerController controller;
  final Post post; 
  final Userr user;
  const BuildVideo({Key? key, required this.controller, required this.post, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          buildVideoPlayer(controller: controller),
          Positioned.fill(child: _showPostUi()),
          Positioned.fill(child: BasicOverlayWidget(controller: controller))
          //add btn that will allow fill of video on width
        ],
      );

Widget _showPostUi() {
  return Stack(children: [
    Positioned(
      bottom: 10,
      right: 0,
      left: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ProfileImage(radius: 20, pfpUrl: user.profileImageUrl),
              SizedBox(width: 7),
              Text(user.username),
            ],
          )
        ],
      ),
    )
  ],);
}

}

class BuildVideoFile extends StatelessWidget {
  final VideoPlayerController controller;

  const BuildVideoFile({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          buildVideoPlayer(),
          // Positioned.fill(child: _showPostUi()),
          Positioned.fill(child: BasicOverlayWidget(controller: controller))
          //add btn that will allow fill of video on width
        ],
      );
  Widget buildVideoPlayer() =>
      AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));



}
// class BuildVideo_16_9 extends StatelessWidget {
//   final VideoPlayerController controller;
//   const BuildVideo_16_9({Key? key, required this.controller}) : super(key: key);

//   @override
//   Widget build(BuildContext context) => Stack(
//         children: [
//           Positioned(
//             bottom: ,
//           )
//           buildVideoPlayer(),
//           Positioned.fill(child: BasicOverlayWidget(controller: controller))
//           //add btn that will allow fill of video on width
//         ],
//       );
//   Widget buildVideoPlayer() =>
//       AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller));
// }