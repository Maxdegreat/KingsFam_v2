import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/feed_main/feed.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/chats_view_widgets/chats_screen_widgets.dart';
import 'package:kingsfam/widgets/widgets.dart';


class ScreensForPageView {
  // ignore: non_constant_identifier_names
  Widget commuinity_view(String userId, BuildContext context, BannerAd bannerAd,
      bool bannerAdLoaded) {
    return BlocConsumer<ChatscreenBloc, ChatscreenState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
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
                            ? Column(
                                children: [
                                  Center(
                                      child: Container(
                                          height: 150,
                                          width: 150,
                                          child: KFCrownV2())),
                                 
                                  howToBox()
                                ],
                              )
                            : Expanded(
                                flex: 1,
                                child: ListView.builder(
                                  itemCount: state.chs.length,
                                  itemBuilder: (context, index) {
                                    Church? commuinity = state.chs[index];
                                    return GestureDetector(
                                      onLongPress: () => leaveCommuinity(
                                          commuinity: commuinity!,
                                          context: context),
                                      onTap: () => Navigator.of(context)
                                          .pushNamed(CommuinityScreen.routeName,
                                              arguments: CommuinityScreenArgs(
                                                commuinity: commuinity!,
                                              )),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: FancyListTile(
                                              location: commuinity!.location.length > 1 ? commuinity.location : null,
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

  

  // ignore: non_constant_identifier_names
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> chats_view(String userId) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Paths.chats)
            .where('memberIds', arrayContains: userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (!snapshot1.hasData) {
            return Center(child: Text('waiting for simpels img'));
          } else if (snapshot1.data!.docs.length <= 0) {
            return Center(child: Text('Join some chats!'));
          } else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      flex: 1,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 20.0,
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          Chat chat = Chat.fromDoc(snapshot1.data!.docs[index]);
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ChatRoom.routeName,
                                arguments: ChatRoomArgs(chat: chat)),
                            child: buildChat(
                                chat: chat, context: context, userId: userId),
                          );
                        },
                        itemCount: snapshot1.data!.docs.length,
                      ),
                    )
                  ],
                ));
          }
        });
  }

  

  

  Widget feed(context) => FeedScreenWidget();

  //Container(child: FeedScreenWidget());
}