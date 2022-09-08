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
import 'package:visibility_detector/visibility_detector.dart';

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

  tabControllerListener() {
    if (_tabController.indexIsChanging) {
      if (_tabController.index == 0) {
        log("setting state, idx == 0");
        setState(() {
          
        });
      } else if (_tabController.previousIndex == 0) {
        log("setting state, idx was 0");
        setState(() {
          
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _perkedVideoPlayerController = VideoPlayerController.asset(
      "assets/promo_assets/Perked-2.mp4",
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    )
      ..addListener(() => setState(() {}))
      ..setLooping(true) // -------------------------------- SET PERKED LOOPING TO TRUE
      ..initialize().then((_) {
        _perkedVideoPlayerController.play();
        _perkedVideoPlayerController.setVolume(0);
      });
    _tabController.addListener(() => setState(() {}));
    _createBottomBannerAd();
    //super.build(context);
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
                    child: VisibilityDetector(
                      key: ObjectKey(_perkedVideoPlayerController),
                      onVisibilityChanged: (vis) {
                        vis.visibleFraction > 0 ? _perkedVideoPlayerController.play() : _perkedVideoPlayerController.pause();
                      },
                      child: Container(
                          child: AssetVideoPlayer(
                              controller: _perkedVideoPlayerController,
                              assetPath: "assets/promo_assets/Perked-2.mp4")),
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
                    return _tabController.index == 0 ? <Widget> [] : <Widget>[
                     SliverAppBar(
                          floating: false,
                          toolbarHeight:  00,
                          expandedHeight:   00,
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
                      ScreensForPageView().feed(context, _tabController),
                      ScreensForPageView().commuinity_view(userId, context,_bottomBannerAd, _isBottomBannerAdLoaded),
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
