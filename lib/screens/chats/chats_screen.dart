import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/chats_view_widgets/screens_for_page_view.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/videos/asset_video.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';
import 'package:video_player/video_player.dart';

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

  // make support for FCM
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    log(initialMessage.toString());
    log('that was the inital message');
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("This is data on a onMessageOpenedApp notification");
      log('---------------------------');
      log("The notif: ${message.notification}");
      log('---------------------------');
      log("The data: ${message.data}");
      log('---------------------------');
      log('the message: $message');
      final dynamic data = message.data;
      log(data.toString());
    });

    //FirebaseMessaging.instance.requestPermission()
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'kc_type') {
      log('The message is $message');
      // var kc = KingsCord(tag: message.data['tag'], cordName: message.data['cordName'], recentMessage: message.data['recentMessage'], recentSender: message.data['recentSender'], members: message.data['members'], id: message.data['id']);
      // Navigator.pushNamed(context, KingsCordScreen.routeName, arguments: KingsCordArgs(commuinity: Church(id: message.data['communityId'], searchPram: [], name: message.data['communityName'], location: '...', imageUrl: '...', members: message.data['members'], events: [], about: '...', recentMsgTime: Timestamp(0,0)), kingsCord: kc));
    } else {
      log("we were not able to track the remote message to ur wanted screeen");
    }
  }

  late BannerAd _bottomBannerAd;
  late BannerAd _inLineBannerAd;
  // ignore: unused_field
  bool _isBottomBannerAdLoaded = false;
  bool _isInLineBannerAdLoaded = false;
  int _inLineAdIndex = 0;
  int _getListViewIndex(int index) {
    if (index >= _inLineAdIndex && _isInLineBannerAdLoaded) {
      return index - 1;
    }
    return index;
  }

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
          log("chatsScreen ad error: ${error.toString()}");
        }),
        request: AdRequest());
    _bottomBannerAd.load();
  }

  void _createInlineBannerAd() {
    _inLineBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isInLineBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("chatsScreen ad error: ${error.toString()}");
        }),
        request: AdRequest());
    _inLineBannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    //fcmpermissions();
    setupInteractedMessage();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _perkedVideoPlayerController =
        VideoPlayerController.asset("assets/promo_assets/Perked-2.mp4")
          ..addListener(() => setState(() {}))
          ..setLooping(true)
          ..initialize().then((_) => _perkedVideoPlayerController.play());
    // _tabController.addListener(tabControllerListener);
    _createBottomBannerAd();
    //super.build(context);
  }

  // void fcmpermissions() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );

  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     print('User granted provisional permission');
  //   } else {
  //     print('User declined or has not accepted permission');
  //   }
  // }

  // bool feedBeenLoaded = false;
  // void tabControllerListener() {
  //   if (_tabController.index == 0 && !feedBeenLoaded) {
  //     context.read<ChatscreenBloc>()..add(ChatScreenFetchPosts());
  //     feedBeenLoaded = true;
  //   }
  // }

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
                  KFCrownV2()
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
                    onTap: () => NavHelper().navToSnackBar(context),
                    child: Container(
                        child: AssetVideoPlayer(
                            controller: _perkedVideoPlayerController,
                            assetPath: "assets/promo_assets/Perked-2.mp4")))
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
                    return <Widget>[
                      SliverAppBar(
                          floating: true,
                          toolbarHeight: 10,
                          expandedHeight: 10,
                          bottom: TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(text: "Feed"),
                              Tab(text: "Commuinity\'s"),
                              Tab(text: "Chats"),
                            ],
                          ))
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      ScreensForPageView().feed(context),
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
