// import 'package:flutter/material.dart';
// import 'package:agora_uikit/agora_uikit.dart';

// class VideoCallScreenArgs {
//   final String channlName;
//   final String tokenUrl;
//   const VideoCallScreenArgs({required this.channlName, required this.tokenUrl});
// }

// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({required this.channelName, required this.tokenUrl});
//   final String channelName;
//   final String tokenUrl;
//   // add a static route name

//   // add a static Route func

//   //    add args if needed

//   //  return MaterialPageRoute prams setting: routeSettings (name:routename), builder: (context) => screen

//   static const String routeName = "VideoCallScree";
//   static Route route({required VideoCallScreenArgs args}) {
//     return MaterialPageRoute(
//       settings: RouteSettings(name: routeName),
//       builder: (context) => VideoCallScreen(
//         channelName: args.channlName,
//         tokenUrl: args.tokenUrl,
//       ),
//     );
//   }

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late String channelName;
//   late String tokenUrl;
//   final String j = 'j';

//   @override
//   void initState() {
//     super.initState();
//     channelName = widget.channelName;
//     tokenUrl = widget.tokenUrl;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AgoraClient _client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: "fa726875676f4320aa6c8834dec7d032",
//         channelName: channelName,
//         // tokenUrl: tokenUrl,
//         tempToken: '006fa726875676f4320aa6c8834dec7d032IABSEaMnMofQElDjWcAuCQYzM7dHUDpA11AgGvuyOSpK8zow4VAAAAAAEABCwUE+4Q2JYgEAAQCXKIli'
//       ),


//       // agoraChannelData: AgoraChannelData(
//       //   channelProfile: ChannelProfile.LiveBroadcasting,
//       //   muteAllRemoteVideoStreams: false
//       // ),

      
//       enabledPermission: [
//         Permission.camera,
//         Permission.microphone,
//       ],
//     );
//     void _initAgora() async {
//       await _client.initialize();
//     }

//     _initAgora();
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(
//             "$channelName ~ Audio / Video Room",
//             overflow: TextOverflow.fade,
//           ),
//         ),
//         body: SafeArea(
//           child: Stack(
//             children: [
//               AgoraVideoViewer(client: _client, ),
//               AgoraVideoButtons(client: _client, ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
