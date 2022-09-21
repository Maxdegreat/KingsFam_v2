import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

import 'package:kingsfam/widgets/chats_view_widgets/screens_for_page_view.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/videos/asset_video.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:new_version/new_version.dart';
import 'package:rive/rive.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// import '../../helpers/permission_helper.dart'; -- used on IOS
import '../../widgets/show_asset_image.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/chatScreen';

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin {
  //bool get wantKeepAlive => true;
  // handel permissions for notifications using FCM

  late BannerAd _bottomBannerAd;

  // ignore: unused_field
  bool _isBottomBannerAdLoaded = false;

  int _tabIdx = 1;

  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("!!!!!!!!!!!!!!!!!! - bottom Ad Error - !!!!!!!!!!!!!!!!!!!!!!!!!");
          log("chatsScreen ad error: ${error.toString()}");
          log("!!!!!!!!!!!!!!!!!! - bottom Ad Error - !!!!!!!!!!!!!!!!!!!!!!!!!");
        }),
        request: AdRequest());
    _bottomBannerAd.load();
  }


  tabControllerListener() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        log("setting state, idx == 0");
        setState(() {});
      } else if (_tabController.previousIndex == 0) {
        log("setting state, idx was 0");
        setState(() {});
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    // log("MESSAGE.DATA['TYPE'] IS OF VAL: "  + message.data['type'].toString());
    if (message.data['type'] == 'kc_type') {
      // type: kc_type has a cmId and a kcId. see cloud functions onMentionedUser for reference
      // var snap = await FirebaseFirestore.instance.collection(Paths.church).doc(message.data['cmId']).collection(Paths.kingsCord).doc(message.data['kcId']).get();
      var snap = await FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(message.data['cmId'])
          .get();

      if (!snap.exists) {
        log("SNAP DOES NOT EXIST OF TYPE kc_type -> RETURNING");
        return;
      }
      // KingsCord? kc = KingsCord.fromDoc(snap);
      Church? cm = await Church.fromDoc(snap);
      // ignore: unnecessary_null_comparison
      if (cm != null) {
        // log ("PROOF U CAN GET THE KC STILL: " + kc.cordName);
        Navigator.of(context).pushNamed(CommuinityScreen.routeName,
            arguments: CommuinityScreenArgs(commuinity: cm));
        return;
      }
      return;
    } else if (message.data['type'] == 'directMsg_type') {
      log("message type is ${message.data['type']}");
      var snap = await FirebaseFirestore.instance
          .collection(Paths.chats)
          .doc(message.data['chatId'])
          .get();

      if (!snap.exists) {
        log("SNAP DOES NOT EXIST OF TYPE directMsg_type -> RETURNING");
        return;
      }
      Chat? chat = await Chat.fromDoc(snap);
      // ignore: unnecessary_null_comparison
      if (chat != null) {
        log("The chat is not null");
        Navigator.of(context)
            .pushNamed(ChatRoom.routeName, arguments: ChatRoomArgs(chat: chat));
        return;
      } else {
        log(" The chat is def null Max");
      }
    } else {
      log("++++++++++++++++++++++++++++++");
      log("Message type did not get cought. see type: ");
      log(message.data['type']);
      log(message.data.toString());
      log("+++++++++++++++++++++++++++++++");
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _checkNewVersion();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _perkedVideoPlayerController =
        VideoPlayerController.asset("assets/promo_assets/Perked-2.mp4",
            videoPlayerOptions: VideoPlayerOptions(
              mixWithOthers: true,
            ))
          ..addListener(() => setState(() {}))
          ..setLooping(
              true) // -------------------------------- SET PERKED LOOPING TO TRUE
          ..initialize().then((_) {
            _perkedVideoPlayerController.play();
            _perkedVideoPlayerController.setVolume(0);
          });
    _tabController.addListener(() => setState(() {}));
    _createBottomBannerAd();
    setupInteractedMessage();
    // requestPhotoPermission(); -- done on Ios
    //super.build(context);
  }

  _checkNewVersion() async {
    final nv = NewVersion(
      androidId: "com.kingbiz.kingsfam",
      iOSId: "com.kingbiz.kingsfam",
    );
    final status = await nv.getVersionStatus();
    
    nv.showUpdateDialog(
      context: context,
      versionStatus: status!,
      allowDismissal: false,
      dialogTitle: "whats Up Fam, An Update Is Available",
      dialogText: "Please update KingsFam to the latest version in order to avoid compatibility errors",
      dismissAction: null,
      updateButtonText: "update!"
    );
    log("local" + status.localVersion);
    log("store" + status.storeVersion);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bottomBannerAd.dispose();
    _perkedVideoPlayerController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  late VideoPlayerController _perkedVideoPlayerController;
  @override
  Widget build(BuildContext context) {
    HexColor hexcolor = HexColor();
    bool showKfCrown = false;
    final userId = context.read<AuthBloc>().state.user!.uid;
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text(
                    'KING\'S FAM',
                    style: TextStyle(
                        color: Color(hexcolor.hexcolorCode('#FFC050'))),
                  ),
                  SizedBox(width: 5),
                  showAssetImage(40, 40, 5,
                      "assets/icons/Logo_files/PNG/KINGSFAM_LOGO.png")
                  // KFCrownV2()
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () => NavHelper().navToCreatePost(context),
                    icon: FaIcon(FontAwesomeIcons.images)),
                GestureDetector(
                    onTap: () => NavHelper().navToCreateSpaces(context),
                    child: KfCrownPadded()),
                GestureDetector(
                    onTap: () => NavHelper().navToSnackBar(context, context.read<AuthBloc>().state.user!.uid),
                    child: VisibilityDetector(
                      key: ObjectKey(_perkedVideoPlayerController),
                      onVisibilityChanged: (vis) {
                        vis.visibleFraction > 0
                            ? _perkedVideoPlayerController.play()
                            : _perkedVideoPlayerController.pause();
                      },
                      child: Container(
                          child: AssetVideoPlayer(
                        controller: _perkedVideoPlayerController,
                      )),
                    ))
              ],
            ),
            body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
                listener: (context, state) {
              if (state.status == ChatStatus.error) {
                ErrorDialog(
                    content: 'chat_screen e-code: ${state.failure.code}');
              }
            }, builder: (context, state) {
              return NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool isScrollableInnerBox) {
                    return _tabController.index == 0
                        ? <Widget>[]
                        : <Widget>[
                            SliverAppBar(
                                floating: false,
                                toolbarHeight: 00,
                                expandedHeight: 00,
                                bottom: TabBar(
                                  controller: _tabController,
                                  tabs: [
                                    Tab(text: "Following"),
                                    Tab(text: "Commuinity\'s"),
                                    Tab(text: "Chats"),
                                  ],
                                ))
                          ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      ScreensForPageView().feed(context, _tabController),
                      ScreensForPageView().commuinity_view(userId, context,
                          _bottomBannerAd, _isBottomBannerAdLoaded),
                      ScreensForPageView().chats_view(userId, state, context)
                    ],
                  ));
            })));
  }

  Padding KfCrownPadded() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        height: 25,
        width: 25,
        child: RiveAnimation.asset('assets/icons/add_icon.riv'),
      ),
    );
  }
}