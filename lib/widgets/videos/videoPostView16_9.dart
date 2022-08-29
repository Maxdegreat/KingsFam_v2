import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/widgets/videos/video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPostView16_9 extends StatefulWidget {
  final String videoUrl;
  final ScrollController? scrollCtrl;
  final bool? playVidNow;
  final Post post;
  final Userr userr;
  final TabController? tabCtrl;
  final VideoPlayerController controller;
  const VideoPostView16_9({
    Key? key, 
    required this.videoUrl, 
    required this.post,
    required this.userr,
    required this.controller,
    this.scrollCtrl,
    this.tabCtrl,
    this.playVidNow,
    })
    : super(key: key);

  @override
  State<VideoPostView16_9> createState() => _VideoPostView16_9State();
}

class _VideoPostView16_9State extends State<VideoPostView16_9> {


  @override
  void initState() {
    super.initState();

    // HERE IS MY MASTER PLAN ALGO IDEA.
    // PASS POST.ID ACCORDING TO SCROLL CONTROLLER
    // IF ID.POSTVIDEO != NULL PLAY VIDEO ONCE OFFSET MOVES PAUSE THE VIDEO.
    if (widget.tabCtrl != null) {
      widget.tabCtrl!.addListener(() { listenToTabBarChanges(); });
    }
    widget.controller
      ..addListener(() {
        setState(() {});
      } )
      ..setLooping(true)
      ..initialize().then((_) {
        widget.playVidNow != null && widget.playVidNow == true ? widget.controller.play() : widget.controller.pause();
      });

      // add a controller to listen to the scroll position.
      // if passed half the size of vid then pause vid.
      // if passed more than half the size of vid restart and pause.
      if (widget.scrollCtrl != null) {
        widget.scrollCtrl!.addListener(() {
          //log("the position of the scroll controller for the feed is: ${widget.scrollCtrl!.position.pixels}");
          
         });
      }
  }

  
  void listenToTabBarChanges() {
    if (widget.tabCtrl!= null && widget.tabCtrl!.index != 0) {
      log("The video is pausing because the tabctrl is now != 0");
      widget.controller.pause();
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<BottomnavbarCubit>().setVidCtrl(widget.controller);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.0),
        child: Center(child: VideoPlayerWidget(controller: widget.controller, post: widget.post, user: widget.userr,)),
      ),
    );
  }
}