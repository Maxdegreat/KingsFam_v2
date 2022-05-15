// import 'package:flutter/material.dart';
// import 'package:kingsfam/widgets/video_player.dart';
// import 'package:video_player/video_player.dart';
// class VidoeDisplay extends StatefulWidget {
//   final String videoUrl;
//   final ScrollController? scrollCtrl;
//   const VidoeDisplay({
//     Key? key, 
//     required this.videoUrl, 
//     this.scrollCtrl})
//     : super(key: key);

//   @override
//   _VidoeDisplayState createState() => _VidoeDisplayState();
// }

// class _VidoeDisplayState extends State<VidoeDisplay> {
//   //    INITIAL INITIALIZATION OF VIDEO PLAYER CONTORLLER
//   late VideoPlayerController controller;
//   @override
//   void initState() {
//     super.initState();

//     // HERE IS MY MASTER PLAN ALGO IDEA.
//     // PASS POST.ID ACCORDING TO SCROLL CONTROLLER
//     // IF ID.POSTVIDEO != NULL PLAY VIDEO ONCE OFFSET MOVES PAUSE THE VIDEO.

//     controller = VideoPlayerController.network(widget.videoUrl)
//       ..addListener(() => setState(() {}))
//       ..setLooping(true)
//       ..initialize().then((_) => controller.pause());
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.0),
//       child: Center(child: VideoPlayerWidget(controller: controller, post: ,)),
//     );
//   }
// }
