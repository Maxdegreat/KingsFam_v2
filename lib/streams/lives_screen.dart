// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kingsfam/blocs/auth/auth_bloc.dart';
// import 'package:kingsfam/config/agora_configs.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LivesScreen extends StatefulWidget {
//   const LivesScreen(
//       {Key? key, required this.isBroadcaster, required this.channelId})
//       : super(key: key);

//   final bool isBroadcaster;
//   final String channelId;

//   @override
//   State<LivesScreen> createState() => _LivesScreenState();
// }

// class _LivesScreenState extends State<LivesScreen> {
//   late final RtcEngine _engine;
//   final List<int> remoteUid = [];
//   @override
//   void initState() {
//     super.initState();
//     _initEngine();
//   }

//   void _initEngine() async {
//     _engine = await RtcEngine.createWithContext(RtcEngineContext(APP_ID));
//     _addListeners();

//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
//     if (widget.isBroadcaster) {
//       _engine.setClientRole(ClientRole.Broadcaster);
//     } else {
//       _engine.setClientRole(ClientRole.Audience);
//     }
//   }

//   void joinChannel() async {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       await [Permission.microphone, Permission.camera].request();
//     }
//     await _engine.joinChannelWithUserAccount(
//         TEMP_TOKEN, 'test123', context.read<AuthBloc>().state.user!.uid);
//   }

//   void _addListeners() {
//     _engine.setEventHandler(
//         RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
//       debugPrint('joinChannelSuccess $channel $uid $elapsed');
//       setState(() {
//         remoteUid.add(uid);
//       });
//     }, userOffline: (uid, reason) {
//       debugPrint("userOfline $uid because $reason");
//       setState(() {
//         remoteUid.removeWhere((element) => element == uid);
//       });
//     }, leaveChannel: (stats) {
//       debugPrint("left channel $stats");
//       remoteUid.clear();
//     }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           children: [
//             //_renderVideo(user);
//           ],
//         ),
//       )
//     );
//   }
// }
