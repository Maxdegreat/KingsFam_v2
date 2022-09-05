
// check if video is longer than 60 seconds. return bool. only allow up to 120 if user has turbo
import 'dart:developer';
import 'dart:io';

import 'package:video_player/video_player.dart';

Future<bool> isVidLong({required File file})  async {
  VideoPlayerController ctrl = VideoPlayerController.file(file);
  await ctrl.initialize();
  if (ctrl.value.isInitialized == true && ctrl.value.duration > Duration(seconds: 60)) {
    ctrl.dispose();
    return false;
  } else {
    ctrl.dispose();
    return true;
  }
}