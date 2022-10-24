import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:rive/rive.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../helpers/permission_helper.dart';
import '../../widgets/show_asset_image.dart';
import 'chats_widget/tab_dropdown.dart';

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

  int _tabIdx = 1;



  Future<void> setupInteractedMessage() async {
    
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

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
    
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
   
    _tabController.addListener(() => setState(() {}));
    setupInteractedMessage();
    //super.build(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  bool chatScreenStateUnReadChats = false;
  
  @override
  Widget build(BuildContext context) {
    HexColor hexcolor = HexColor();
    
    final userId = context.read<AuthBloc>().state.user!.uid;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('KING\'SFAM',
                      style: GoogleFonts.cedarvilleCursive(
                          color: Color(hexcolor.hexcolorCode('#FFC050')))),
                  SizedBox(width: 5),
                  // showAssetImage(40, 40, 5,
                  //     "assets/icons/Logo_files/PNG/KINGSFAM_LOGO.png")
                ],
              ),
              actions: [
                ChatsDropDownButton(tabctrl: _tabController, stateUnreadChats: chatScreenStateUnReadChats),
              ],
            ),
            body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
              
                listener: (context, state) {
              if (state.status == ChatStatus.error) {
                ErrorDialog(content: 'chat_screen e-code: ${state.failure.message}');
              }

              if (state.unreadChats != false) {
                chatScreenStateUnReadChats = state.unreadChats;
                setState(() {});
              }
            }, builder: (context, state) {
              
              
              log(state.unreadChats.toString() + "That is the val of stateUnreadChats");
              return Scaffold(
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      ScreensForPageView().commuinity_view(userId, context),
                      ScreensForPageView().chats_view(userId, state, context)
                    ],
                  ));
            })));
  }

  // ignore: non_constant_identifier_names
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
