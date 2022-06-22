import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/page_routes/custom_page_route.dart';
import 'package:kingsfam/widgets/basic_overlay_widget.dart';
import 'package:kingsfam/widgets/video_player.dart';
import 'package:video_player/video_player.dart';

class UrlViewArgs {
  final String urlMain;
  final String urlSub;
  final String heroTag;

  UrlViewArgs(
      {required this.urlMain, required this.urlSub, required this.heroTag});
}

class UrlViewScreen extends StatefulWidget {
  const UrlViewScreen(
      {required this.url, required this.heroTag, required this.subUrl});
  final String url;
  final String subUrl;
  final String heroTag;

  static const String routeName = 'UrlViewScreen';

  static Route route({required UrlViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => UrlViewScreen(
            url: args.urlMain, heroTag: args.heroTag, subUrl: args.urlSub));
  }

  @override
  State<UrlViewScreen> createState() => _FileViewScreenState();
}

class _FileViewScreenState extends State<UrlViewScreen> {
  late VideoPlayerController vidController;
  @override
  void initState() {
    vidController = VideoPlayerController.network(widget.url)
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(false)
      ..initialize().then((value) => vidController.play());
    super.initState();
  }

  @override
  void dispose() {
    vidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Hero(tag: widget.heroTag, child: _viewPort()),
    );
  }

  Widget _viewPort() => Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: widget.subUrl.isNotEmpty ? _videoPortFromMessage() : null,
        // ignore: unnecessary_null_comparison
        decoration: widget.subUrl.isEmpty || widget.subUrl == null
            ? null
            : BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.url),
                    fit: BoxFit.fitWidth)),
      );

  Widget _videoPortFromMessage() => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Center(
          child: _videoPlayer(),
        ),
      );

  Widget _videoPlayer() => vidController.value.isInitialized
      ? ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: double.infinity,
              minHeight: 900), //size of video player in app
          child: _BuildVideo())
      : Container(
          height: 250,
          child: Center(
              child: CircularProgressIndicator(
            color: Colors.red[400],
          )));

    Widget _BuildVideo()  => Stack(
        children: [
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverlayWidget(controller: vidController))
          //add btn that will allow fill of video on width
        ],
      );
  Widget buildVideoPlayer() =>
      AspectRatio(aspectRatio: vidController.value.aspectRatio, child: VideoPlayer(vidController));

}
