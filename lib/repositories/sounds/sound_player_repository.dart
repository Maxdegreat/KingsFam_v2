

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';

final pathToReadAudio = 'audio_example.aad'; // MAKE SURE THIS COMES AS A PRAM IN THE PLAY FUNC. IT HAS TO BE DYNAMIC BC WE ARE READING FROM WEB OR RECORDING
class SoundPlayerReposityry{
  FlutterSoundPlayer? _audioPlayer;

  // init and dispose methods
  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openAudioSession();
  }

  Future disopse() async {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play({VoidCallback? whenFinished, String? toPlay}) async {
    await _audioPlayer!.startPlayer(
      fromURI: toPlay,
      whenFinished: whenFinished
    );
  }

  Future _stop() async => await _audioPlayer!.stopPlayer();

  // made above two methods (play and stop) private because we can just call the two methods in a toggle
  // play function. This just makes for cleaner code!

  Future togglePlaying({required VoidCallback whenFinished, String? toPlay}) async {
    if (_audioPlayer!.isPaused) {
      await _play(whenFinished: whenFinished, toPlay: toPlay);
    } else {
      await _stop();
    }
  }
}