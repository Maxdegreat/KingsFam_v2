// import 'package:flutter/material.dart';
// import 'package:agora_uikit/agora_uikit.dart';

// class VideoCallScreen extends StatefulWidget {
//   const VideoCallScreen({ Key? key }) : super(key: key);

//   // add a static route name

//   // add a static Route func
  
//   //    add args if needed

//   //  return MaterialPageRoute prams setting: routeSettings (name:routename), builder: (context) => screen

//   static const String routeName = "VideoCallScree";
//   static Route route() {
//     return MaterialPageRoute(
//       settings: RouteSettings(name: routeName),
//       builder: (context) => VideoCallScreen(),
//     );
//   }

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {

//   final AgoraClient _client = AgoraClient(
//     agoraConnectionData: AgoraConnectionData(
//       appId: "fa726875676f4320aa6c8834dec7d032",
//       channelName: "fluttering",
//       tempToken: "006fa726875676f4320aa6c8834dec7d032IADWECkXDkHMRazd3dgVr5yHVDDG+ICHXSyCtoOCJOwV6r2YShYAAAAAEAD+JYqAF8B2YgEAAQDj2nZi006fa726875676f4320aa6c8834dec7d032IADWECkXDkHMRazd3dgVr5yHVDDG+ICHXSyCtoOCJOwV6r2YShYAAAAAEAD+JYqAF8B2YgEAAQDj2nZi"
      
//     ),
//     enabledPermission: [
//       Permission.camera,
//       Permission.microphone,
//     ],
//   );

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   void _initAgora() async {
//     await _client.initialize();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         appBar: AppBar(title: Text("Audio / Video Room"),),
//         body: SafeArea(
//           child: Stack(
//             children: [
//               AgoraVideoViewer(client: _client),
//               AgoraVideoButtons(client: _client),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }