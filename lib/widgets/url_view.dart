import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/models/user_model.dart';

import 'package:kingsfam/widgets/basic_overlay_widget.dart';
import 'package:kingsfam/widgets/videos/videoPostView16_9.dart';

import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UrlViewArgs {
  final String? urlVid;
  final String? urlImg;
  final String? heroTag;
  final File? fileVid;
  final File? fileImg;

  UrlViewArgs(
      {this.urlVid,
      required this.urlImg,
      required this.heroTag,
      this.fileImg,
      this.fileVid});
}

class UrlViewScreen extends StatefulWidget {
  const UrlViewScreen(
      {this.urlVid,
      required this.urlImg,
      required this.heroTag,
      required this.fileVid,
      required this.fileImg});
  final String? urlVid;
  final String? urlImg;
  final String? heroTag;
  final File? fileVid;
  final File? fileImg;

  static const String routeName = 'UrlViewScreen';

  static Route route({required UrlViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => UrlViewScreen(
              heroTag: args.heroTag,
              urlVid: args.urlVid,
              urlImg: args.urlImg,
              fileVid: args.fileVid,
              fileImg: args.fileImg,
            ));
  }

  @override
  State<UrlViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends State<UrlViewScreen> {
  bool flagWhichVidPlayer = true;
  VideoPlayerController? vidController;
  @override
  void initState() {
    if (widget.fileVid != null) {
      vidController = VideoPlayerController.file(widget.fileVid!);
    } else if (widget.urlVid != null) {
      vidController = VideoPlayerController.network(widget.urlVid!);
    }
    if (vidController != null && !flagWhichVidPlayer)
      vidController!
        ..addListener(() {
          setState(() {});
        })
        ..setLooping(false)
        ..initialize().then((value) => vidController!.play());
    super.initState();
  }

  @override
  void dispose() {
    if (vidController != null) vidController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
      ),
      body: Hero(tag: widget.heroTag!, child: _viewPort()),
    );
  }

  Widget _viewPort() => VisibilityDetector(
        key: ObjectKey(vidController),
        onVisibilityChanged: (vis) {
          if (vis.visibleFraction == 0 && this.mounted) {
            Navigator.of(context).pop();
            if (vidController != null) vidController!.dispose();
          }
        },
        child: flagWhichVidPlayer
            ? Container(
              
                child: vidController != null
                    ? VideoPostView16_9(
                        controller: vidController!,
                        videoUrl: "",
                        post: Post.empty,
                        userr: Userr.empty,
                      )
                    : null,
                decoration: widget.urlImg != null || widget.fileImg != null
                    ? BoxDecoration(
                      color: Colors.black,
                        image: widget.urlImg != null
                            ? DecorationImage(
                                image:
                                    CachedNetworkImageProvider(widget.urlImg!),
                                fit: BoxFit.fitWidth)
                            : DecorationImage(
                                image: FileImage(widget.fileImg!)))
                    : null,
              )
            : Expanded(
                child: Center(
                  child: Container(
                    child: widget.urlVid != null || widget.fileVid != null
                        ? _videoPortFromMessage()
                        : null,
                    // ignore: unnecessary_null_comparison
                    decoration: widget.urlImg != null || widget.fileImg != null
                        ? BoxDecoration(
                            image: widget.urlImg != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        widget.urlImg!),
                                    fit: BoxFit.fitWidth)
                                : DecorationImage(
                                    image: FileImage(widget.fileImg!)))
                        : null,
                  ),
                ),
              ),
      );

  Widget _videoPortFromMessage() => Padding(
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Center(
          child: _videoPlayer(),
        ),
      );

  Widget _videoPlayer() => vidController!.value.isInitialized
      ? ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: double.infinity,
              minHeight: 900), //size of video player in app
          child: _buildVideo())
      : Container(
          height: 250,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.amber,
          )));

  Widget _buildVideo() => Stack(
        children: [
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverlayWidget(controller: vidController!))
          //add btn that will allow fill of video on width
        ],
      );
  Widget buildVideoPlayer() => AspectRatio(
      aspectRatio: vidController!.value.aspectRatio,
      child: VideoPlayer(vidController!));

  getTitle() {
    return "";
  }
}
