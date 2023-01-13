// check if video is longer than 60 seconds. return bool. only allow up to 120 if user has turbo
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/create_post/post_content_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';




class VideoEditorArgs {
  final File file;
  final String? nextScreen;
  final Map<String, dynamic>? data;
  VideoEditorArgs({required this.file, required this.nextScreen, this.data});
}


class VideoEditor extends StatefulWidget {
  const VideoEditor({Key? key, required this.file, required this.nextScreen, this.data}) : super(key: key);

  final File file;
  final String? nextScreen;
  final Map<String, dynamic>? data;
  static const String routeName = "/videoEditor";
  static Route route (VideoEditorArgs args) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => VideoEditor(file: args.file, nextScreen: args.nextScreen)
    );
  }
  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  
 final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (outputPath) {

        debugPrint('OUTPUT PATH: $outputPath');
        var arguments;
        if (widget.nextScreen == PostContentScreen.routeName) {
          arguments = PostContentArgs(type: "video", content: File(outputPath!));
          Navigator.of(context).pushNamed(widget.nextScreen!, arguments: arguments);
        }
        else {
          Navigator.of(context).pop(File(outputPath!));
        }
      },
    );
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
        title: Text("Trim Post", style: Theme.of(context).textTheme.bodyText1),
      actions: [
        TextButton(
                  onPressed: _progressVisibility ? null : () => _saveVideo(),
                  child: Text("continue", style: _progressVisibility ? Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey) : Theme.of(context).textTheme.bodyText1!),
                ),
      ],),
      body: Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
                
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrimViewer(
                      trimmer: _trimmer,
                      viewerHeight: 50.0,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_MM_SS,
                      maxVideoLength: const Duration(seconds: 20),
                      editorProperties: TrimEditorProperties(
                        borderPaintColor: Colors.amber,
                        borderWidth: 4,
                        borderRadius: 5,
                        circlePaintColor: Colors.yellow.shade800,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(
                        thumbnailQuality: 10,
                      ),
                      onChangeStart: (value) => _startValue = value,
                      onChangeEnd: (value) => _endValue = value,
                      onChangePlaybackState: (value) =>
                          setState(() => _isPlaying = value),
                    ),
                  ),
                ),
                TextButton(
                  child: _isPlaying
                      ? const Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() => _isPlaying = playbackState);
                  },
                )
              ],
            ),
          ))
    );
  }

}