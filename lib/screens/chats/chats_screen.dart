import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/chats_view_widgets/screens_for_page_view.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

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

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    print("running setupInteractedMessage()");
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

  void _handleMessage(RemoteMessage message) {
    if (2 == 2) {
      print("THE DANG MESSAGE DATA BOY ${message.data}");
      print("the date time is ${message.data['date']}");
      final obj = message.data;
      DateTime date = DateTime.parse(obj['date']);
      Chat chat = Chat(
          name: obj['name'],
          recentMessage: obj['recentMessage'],
          searchPram: obj['searchPram'],
          imageUrl: obj['imageUrl'],
          recentSender: obj['recentSender'],
          date: date,
          memberIds: obj['memberIds'],
          memberInfo: obj['memberInfo'],
          readStatus: obj['readStatus']);
      Navigator.pushNamed(
        context,
        ChatRoom.routeName,
        arguments: ChatRoomArgs(chat: chat),
      );
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
    setupInteractedMessage();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    // _tabController.addListener(tabControllerListener);
    
    _createBottomBannerAd();
    //super.build(context);
  }

  

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
    super.dispose();
  }

  late TabController _tabController;
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
                    'K I N G S F A M',
                    style: TextStyle(
                        color: Color(hexcolor.hexcolorCode('#FFC050'))),
                  ),
                  SizedBox(width: 5),
                  KFCrownV2()
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(CreatePostScreen.routeName),
                    icon: Icon(Icons.camera)),
                GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(CreateComuinity.routeName),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        height: 25,
                        width: 25,
                        child: RiveAnimation.asset('assets/icons/add_icon.riv'),
                      ),
                    )),
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
                              Tab(text: "Commuinities"),
                              Tab(text: "Chats")
                            ],
                          ))
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                       ScreensForPageView().feed(context),
                      ScreensForPageView().commuinity_view(userId, context,_bottomBannerAd, _isBottomBannerAdLoaded),
                      ScreensForPageView().chats_view(userId)
                    ],
                  ));
            })));
  }
}
