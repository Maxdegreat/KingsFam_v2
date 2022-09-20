import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/feed_main/feed.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/chats_view_widgets/chats_screen_widgets.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

class ScreensForPageView {
  // ignore: non_constant_identifier_names
  Widget commuinity_view(String userId, BuildContext context, BannerAd bannerAd,
      bool bannerAdLoaded) {
    return BlocConsumer<ChatscreenBloc, ChatscreenState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var currId = context.read<AuthBloc>().state.user!.uid;
        return Scaffold(
          persistentFooterButtons: [
            state.chs.length > 0
                ? bannerAdLoaded
                    ? Container(
                        height: bannerAd.size.height.toDouble(),
                        width: double.infinity,
                        child: AdWidget(
                          ad: bannerAd,
                        ),
                      )
                    : SizedBox.shrink()
                : SizedBox.shrink()
          ],
          body: RefreshIndicator(
              onRefresh: () async =>
                  context.read<ChatscreenBloc>()..add(LoadCms()),
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1.25,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        state.chs.length == 0
                            ? GettingStartedCrown(context)
                            : Expanded(
                                flex: 1,
                                child: ListView.builder(
                                  itemCount: state.chs.length,
                                  itemBuilder: (context, index) {
                                    // check if the path userid, church, kc ezist if so flag with a @ symbole

                                    Church? commuinity = state.chs[index];
                                    bool isMentioned = false;
                                    FirebaseFirestore.instance
                                        .collection(Paths.mention)
                                        .doc(currId)
                                        .collection(commuinity!.id!)
                                        .snapshots()
                                        .isEmpty;

                                    var usersrecentTime =
                                        commuinity.members[state.currUserr];
                                    int? compraeTimes = commuinity.recentMsgTime
                                        .compareTo(
                                            usersrecentTime['timestamp']);
                                    // ignore: unnecessary_null_comparison
                                    bool cmHasNotif = compraeTimes != null ? compraeTimes  > 0 : false;

                                    return GestureDetector(
                                      onLongPress: () => leaveCommuinity(
                                          commuinity: commuinity,
                                          context: context),
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(CommuinityScreen.routeName,
                                              arguments: CommuinityScreenArgs(
                                                commuinity: commuinity,
                                              )), // ----------------------------------------------------------------------set state here
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          // see child of list view here below.
                                          child: FancyListTile(
                                              // ------------------------- update hee
                                              isMentioned: state
                                                  .mentionedMap[commuinity.id],
                                              newNotification: cmHasNotif,
                                              location:
                                                  commuinity.location.length > 1
                                                      ? commuinity.location
                                                      : null,
                                              username: commuinity.name,
                                              imageUrl: commuinity.imageUrl,
                                              onTap: () => Navigator.of(context)
                                                  .pushNamed(
                                                      CommuinityScreen
                                                          .routeName,
                                                      arguments:
                                                          CommuinityScreenArgs(
                                                              commuinity:
                                                                  commuinity)),
                                              isBtn: false,
                                              BR: 12.0,
                                              height: 12.0,
                                              width: 12.0)),
                                    );
                                  },
                                )),
                      ],
                    ),
                  ))),
        );
      },
    );
  }

  Column GettingStartedCrown(BuildContext context) {
    return Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Center(
                                    child: Container(
                                        height: 100,
                                        width: 100,
                                        child: KFCrownV2())),
                                Container(
                                    width: 125,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Color(hexcolor
                                                .hexcolorCode('#FFC050'))),
                                        onPressed: () async {
                                          helpDialog(context);
                                        },
                                        child: Text(
                                          "Getting Started",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        )))
                              ],
                            );
  }

  // ignore: non_constant_identifier_names
  Widget chats_view(String userId, ChatscreenState state, BuildContext context) {
    return Scaffold(
      body: state.chat.length > 0
          ? gridOfChats(state, userId)
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Hmm, it's kinda empty over here", style: Theme.of(context).textTheme.bodyText1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Start a chat or Community?  ", style: Theme.of(context).textTheme.bodyText1,),
                    navToCreateScreen(context),
                  ],
                )
              ],
            )),
    );
  }

  GestureDetector navToCreateScreen(BuildContext context) {
    return GestureDetector(
                    onTap: () => Navigator.of(context)
                      .pushNamed(CreateComuinity.routeName),
                    child: Container(
                        height: 20,
                        width: 20,
                        child:
                            RiveAnimation.asset('assets/icons/add_icon.riv')),
                  );
  }

  GridView gridOfChats(ChatscreenState state, String userId) {
    return GridView.builder(
      itemCount: state.chat.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 20.0,
        crossAxisCount: 2,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        //TODO
        Chat? chat = state.chat[index];
        // ignore: unnecessary_null_comparison
        if (chat != null) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(ChatRoom.routeName,
                arguments: ChatRoomArgs(chat: chat)),
            child: buildChat(chat: chat, context: context, userId: userId),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget feed(context, tabController) => FeedScreenWidget(tabController: tabController,);
  //Container(child: FeedScreenWidget());
}
