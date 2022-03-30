import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';
import 'package:uuid/uuid.dart';

const int tSAMPLERATE = 8000;

const int tSTREAMSAMPLERATE = 44000;

const int tBLOCKSIZE = 4096;


//final String pathToSaveAudio = 'audio_example.mp3';

enum Media { file, buffer, asset, stream, remoteExampleFile }

class SoundRecorderRepository {

  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _recordingDataSubscription;

  // FlutterSoundPlayer player = FlutterSoundPlayer();
  // FlutterSoundRecorder recorder = FlutterSoundRecorder();
  // String _reocrderTxt = '00:00:00';

  // double sliderCurrPosition = 0.0;
  // double maxDuration = 1.0;
  // Media? _media = Media.remoteExampleFile;
  // Codec _codec = Codec.aacMP4;

  // StreamController<Food>? recordingDataController;
  // IOSink? sink;

  // Future<void> _initializeExample() async {
  //   await player.closePlayer();
  //   await player.openPlayer();
  //   await player.setSubscriptionDuration(Duration(milliseconds: 10));
  //   await recorder.setSubscriptionDuration(Duration(milliseconds: 10));
  //   await initializeDateFormatting();
  //   await setCodec(_codec);
  // }

  // Future<void> openTheRecorder() async {
  //   if (!kIsWeb) {
  //     var status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted) {
  //       throw RecordingPermissionException('Microphone permission not granted');
  //     }
  //   }
  //   await recorder.openRecorder();

  //   // if (!await recorderModule.isEncoderSupported(_codec) && kIsWeb) {
  //   //   _codec = Codec.opusWebM;
  //   // }
    
  // }

  // Future<void> init() async {
  //   await openTheRecorder();
  //   await _initializeExample();

  //   // if ((!kIsWeb) && Platform.isAndroid) {
  //   //   await copyAssets();
  //   // }

  //    final session = await AudioSession.instance;
  //   await session.configure(AudioSessionConfiguration(
  //     avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
  //     avAudioSessionCategoryOptions:
  //         AVAudioSessionCategoryOptions.allowBluetooth |
  //             AVAudioSessionCategoryOptions.defaultToSpeaker,
  //     avAudioSessionMode: AVAudioSessionMode.spokenAudio,
  //     avAudioSessionRouteSharingPolicy:
  //         AVAudioSessionRouteSharingPolicy.defaultPolicy,
  //     avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
  //     androidAudioAttributes: const AndroidAudioAttributes(
  //       contentType: AndroidAudioContentType.speech,
  //       flags: AndroidAudioFlags.none,
  //       usage: AndroidAudioUsage.voiceCommunication,
  //     ),
  //     androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
  //     androidWillPauseWhenDucked: true,
  //   ));


  // }

  // void cancelRecorderSubscriptions() {
  //   if (_recorderSubscription != null) {
  //     _recorderSubscription!.cancel();
  //     _recorderSubscription = null;
  //   }
  // }

  //   void cancelPlayerSubscriptions() {
  //   if (_playerSubscription != null) {
  //     _playerSubscription!.cancel();
  //     _playerSubscription = null;
  //   }
  // }

  //   void cancelRecordingDataSubscription() {
  //   if (_recordingDataSubscription != null) {
  //     _recordingDataSubscription!.cancel();
  //     _recordingDataSubscription = null;
  //   }
  //   recordingDataController = null;
  //   if (sink != null) {
  //     sink!.close();
  //     sink = null;
  //   }
  // }

  //   Future<void> releaseFlauto() async {
  //   try {
  //     await player.closePlayer();
  //     await recorder.closeRecorder();
  //   } on Exception {
  //     player.logger.e('Released unsuccessful');
  //   }
  // }

  // void startRecorder() async {
  //   try {
  //     var status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted ) {
  //       throw RecordingPermissionException('Microphone Permission Not Granted');
  //     }
  //     // here we make the path
  //     var path = Uuid().v4();

  //     if (_media == Media.stream) {
  //       assert(_codec == Codec.pcm16);
  //       var outputFile = File(path);
  //       if (outputFile.existsSync()) {
  //         await outputFile.delete();
  //       } 
  //       sink = outputFile.openWrite();
  //     } else {
  //       sink = null;
  //     }
  //     // start lestening to recording on a stream
  //     recordingDataController = StreamController<Food>();
  //       _recordingDataSubscription =
  //           recordingDataController!.stream.listen((buffer) {
  //         if (buffer is FoodData) {
  //           sink!.add(buffer.data!);
  //         }
  //       });
  //       await recorder.startRecorder(
  //         toStream: recordingDataController!.sink,
  //         codec: _codec,
  //         numChannels: 1,
  //         sampleRate: tSTREAMSAMPLERATE, //tSAMPLERATE,
  //       );

  //        recorder.logger.d('startRecorder');

  //         // this will update the time
  //        _recorderSubscription = recorder.onProgress!.listen((e) {
  //       var date = DateTime.fromMillisecondsSinceEpoch(
  //           e.duration.inMilliseconds,
  //           isUtc: true);
  //       var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        
  //       // setState(() {
  //       //   _recorderTxt = txt.substring(0, 8);
  //       //   _dbLevel = e.decibels;
  //       // });
  //     });
      
  //     // set isRecording to

  //   } catch (e) {
  //   }
  // }










  // FlutterSoundRecorder? _audioRecorder;
  // bool _isRecorded = false; 

  // // geter to see if recording atm
  // bool get isRecording => _audioRecorder!.isRecording;
  // bool get isRecordedEmpty => _isRecorded;

  // // bool is recorder initalized
  // bool _isRecorderInitalized = false;

  // // recorder initallize method
  // Future init() async {
  //   _audioRecorder = FlutterSoundRecorder();

  //   final status = await Permission.microphone.request();
  //   if (status != PermissionStatus.granted) {
  //     throw RecordingPermissionException('Microphone Permission Is Needed Fam');
  //   }
  //   await _audioRecorder!.openAudioSession();
  //   _isRecorderInitalized = true;
  // }

  // // recorder dispose method
  // Future dispose() async {
  //   _audioRecorder!.closeAudioSession();
  //   _audioRecorder = null;
  //   _isRecorderInitalized = false;
  //   _isRecorded = false;
  // }

  // // record audio
  // Future _record() async {
  //   // must be initialied b4 recording
  //   if ( !_isRecorderInitalized ) return ;
  //   await _audioRecorder!.startRecorder(toFile: pathToSaveAudio);
  //   _isRecorded = true;
  // }

  // // pause or stop recording
  // Future _stop() async {
  //   // must be initialied b4 recording
  //   if ( !_isRecorderInitalized ) return ;
  //   await _audioRecorder!.stopRecorder();
  // }

  // // toggle between record audio and pausev
  // Future toggleRecording() async {
  //   if (_audioRecorder!.isStopped) {
  //     await _record();
  //     print("we are now recording (in sound repo)");
  //   } else {
  //     await _stop();
  //     print("we have stoped recording (in sound repo)");
  //   }
  // }

  // // THIS IS FOR TESTING
  // // this should return the recorded audio file that way we can play it back
  // String sendAudioFile() => pathToSaveAudio;
  
}