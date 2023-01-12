import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kingsfam/api/agora.dart';
import 'package:kingsfam/helpers/notification_helper.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/repositories/vc/vcRepository.dart';
import 'package:kingsfam/screens/commuinity/screens/vc/bloc/vc_bloc.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:permission_handler/permission_handler.dart';

class VcScreenArgs {
  final Church cm;
  final KingsCord kc;
  final Userr currUserr;
  const VcScreenArgs(
      {required this.kc, required this.currUserr, required this.cm});
}

class VcScreen extends StatefulWidget {
  final KingsCord kc;
  final Userr currUserr;
  final Church cm;
  const VcScreen(
      {Key? key, required this.kc, required this.currUserr, required this.cm})
      : super(key: key);
  static const routeName = "vc_screen";
  static Route route({required VcScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<VcBloc>(
              create: (context) => VcBloc(
                userrRepository: context.read<UserrRepository>(),
                vcRepository: VcRepository(),
              )..add(VcInit(cmId: args.cm.id!, kcId: args.kc.id!)),
              child: VcScreen(
                cm: args.cm,
                kc: args.kc,
                currUserr: args.currUserr,
              ),
            ));
  }

  @override
  State<VcScreen> createState() => _VcScreenState();
}
  
class _VcScreenState extends State<VcScreen>  with WidgetsBindingObserver{
  String? token;
  int uid = Random().nextInt(100);
  int? _remoteUid;
  bool isJoined = false;
  bool isMute = true;
  late RtcEngine rtcEngine;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    setupVoiceSDKEngine();
    super.initState();
  }

  // Clean up the resources when you leave
  @override
  void dispose() async {
    leave();
    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.inactive) {
      // add a notification that can not be removed saying in call
      NotificationHelper.showNotificationNonRemote({"title": "In Call KingsFam", "body": widget.cm.name + " - " + widget.kc.cordName});
    } else if (state == AppLifecycleState.resumed) {
      // keep notification
    }
  }
  // #enddocregion AppLifecycle
  

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VcBloc, VcState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: _appBarTitle(context, state),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 1.4,
                  child: ListView.builder(
                      itemCount: state.participants.length,
                      itemBuilder: ((context, index) {
                        if (state.participants.length == 0) {
                          Center(child:Text("No participants in call",style: Theme.of(context).textTheme.bodyText1,));
                        }
                        Userr u = state.participants[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: ProfileImage(
                                radius: 25, pfpUrl: u.profileImageUrl),
                            title: Text(u.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontSize: 17)),
                          ),
                        );
                      })),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          !isJoined ? _joinCallBtn() : _inCallRow()
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> setupVoiceSDKEngine() async {
    // retrieve or request camera and microphone permissions
    await [Permission.microphone].request();

    //create an instance of the Agora engine
    rtcEngine = createAgoraRtcEngine();
    await rtcEngine
        .initialize(RtcEngineContext(appId: dotenv.env['AGORA_APP_ID']));

    // await rtcEngine.enableVideo();

    // Register the event handler
    rtcEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          showMessage(
              "Local user uid:${connection.localUid} joined the channel");
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

    
    token = await AgoraApi.agoraTokenGenerator(
      widget.kc.cordName + widget.kc.id!,
      "publisher",
      uid,
    );
  }

  void join() async {
    // await rtcEngine.startPreview();

    // Set channel options including the client role and channel profile
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );


    await rtcEngine.joinChannel(
      token: token!,
      channelId:
          widget.kc.cordName + widget.kc.id!,
      options: options,
      uid: uid,
    );
     NotificationHelper.showNotificationNonRemote({"title": "In Call KingsFam", "body": widget.cm.name + " - " + widget.kc.cordName});
    isJoined = true;
    isMute = true;
    setState(() {});
  }

  void leave() async {
    setState(() {
      isJoined = false;
      isMute = true;
      _remoteUid = null;
    });
    await rtcEngine.leaveChannel();
    _leaveCallBtn();
    context.read<VcBloc>()
            ..add(VcEventUserLeft(
                cmId: widget.cm.id!,
                kcId: widget.kc.id!,
                userr: widget.currUserr));
          context.read<VcBloc>().rmvUserSetState(widget.currUserr.id);
  }

  // ----- widgets below -----
  Widget _appBarTitle(BuildContext context, VcState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Icon_VcName(),
        Text(widget.cm.name, style: Theme.of(context).textTheme.caption)
      ],
    );
  }

  Widget _Icon_VcName() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.multitrack_audio_outlined),
          SizedBox(width: 5),
          Text(widget.kc.cordName,style: Theme.of(context).textTheme.bodyText1),
        ],
      );
  Widget _inCallRow() => Row(
    children: [
      _leaveCallBtn(),
      SizedBox(width: 8),
      _muteMicBtn()
    ],
  );

  Widget _joinCallBtn() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(111, 76, 175, 79),
        ),
        onPressed: () {
          join();
          context.read<VcBloc>()
            ..add(VcEventUserJoined(
                cmId: widget.cm.id!,
                kcId: widget.kc.id!,
                userr: widget.currUserr));
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
          width: MediaQuery.of(context).size.width / 2,
          child: Text("Join Call",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.green)),
        ),
      );

  Widget _muteMicBtn() => GestureDetector(
    onTap: () {
      isMute = !isMute;
      rtcEngine.muteRemoteAudioStream(uid: uid, mute: isMute);
      setState(() {});
    } ,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: !isMute ? Icon(Icons.mic, color: Colors.white,) :Icon(Icons.mic_off_outlined, color: Colors.white,) ,
    ),
  );

  Widget _leaveCallBtn() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Color.fromARGB(110, 175, 78, 76),
        ),
        onPressed: () {
          leave();
          
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)),
          width: MediaQuery.of(context).size.width / 2,
          child: Text("Leave Call",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.red)),
        ),
      );
}
