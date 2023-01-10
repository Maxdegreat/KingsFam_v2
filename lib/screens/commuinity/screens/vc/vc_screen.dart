

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kingsfam/api/agora.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:permission_handler/permission_handler.dart';

class VcScreenArgs {
  final KingsCord kc;
  final Userr currUserr;
  const VcScreenArgs({required this.kc, required this.currUserr});
}

class VcScreen extends StatefulWidget {
  final KingsCord kc;
  final Userr currUserr;
  const VcScreen({Key? key, required this.kc, required this.currUserr}) : super(key: key);
  static const routeName = "vc_screen";
  static Route route({required VcScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => VcScreen(kc: args.kc, currUserr: args.currUserr,)
    );
  }

  @override
  State<VcScreen> createState() => _VcScreenState();
}

class _VcScreenState extends State<VcScreen> {

  

  String? token; 
  int? _remoteUid;
  bool isJoined = false;
  late RtcEngine rtcEngine;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
    = GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
        scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        content: Text(message),
        ));
  }

    @override
  void initState() {
    setupSDKEngine();
    super.initState();
  }

  // Clean up the resources when you leave
@override
void dispose() async {
    await rtcEngine.leaveChannel();
    super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text("demo"),)
          ],
        ),
      ),
    );
  }

  Future<void> setupSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    rtcEngine = createAgoraRtcEngine();
    await rtcEngine.initialize( RtcEngineContext(
    appId: dotenv.env['AGORA_APP_ID']
    ));

    // await rtcEngine.enableVideo();
    
    // Register the event handler
    rtcEngine.registerEventHandler(
    RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        showMessage("Local user uid:${connection.localUid} joined the channel");
        setState(() {
            isJoined = true;
        });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        showMessage("Remote user uid:$remoteUid joined the channel");
        setState(() {
            _remoteUid = remoteUid;
        });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
        showMessage("Remote user uid:$remoteUid left the channel");
        setState(() {
            _remoteUid = null;
        });
        },
    ),
    );

    // make token 
    token = await AgoraApi.agoraTokenGenerator(
      widget.kc.cordName+widget.kc.id!,
      "publisher",
      int.parse(widget.currUserr.id),
    );
    
}

void  join() async {
    await rtcEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await rtcEngine.joinChannel(
        token: token!,
        channelId: widget.kc.cordName+widget.kc.id!,
        options: options,
        uid: int.parse(widget.currUserr.id),
    );
}

void leave() {
    setState(() {
    isJoined = false;
    _remoteUid = null;
    });
    rtcEngine.leaveChannel();
}
}