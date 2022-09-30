import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/feed_main/feed.dart';

import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/chats_view_widgets/getting_started.dart';
import 'package:kingsfam/widgets/kf_crown_v2.dart';
import 'package:kingsfam/widgets/chats_view_widgets/chats_screen_widgets.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

import '../../screens/chats/chats_widget/show_joined_cms.dart';

class ScreensForPageView {
  // ignore: non_constant_identifier_names
  Widget commuinity_view(String userId, BuildContext context) {
    return BlocConsumer<ChatscreenBloc, ChatscreenState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        var currId = context.read<AuthBloc>().state.user!.uid;
        return Scaffold(
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
                            ? GettingStarted(
                                bloc: context.read<ChatscreenBloc>(),
                                state: state,
                              )
                            : showJoinedCms(currId: currId, state: state),
                      ],
                    ),
                  ))),
        );
      },
    );
  }



  // ignore: non_constant_identifier_names
  Widget chats_view(
      String userId, ChatscreenState state, BuildContext context) {
    return Scaffold(
      body: state.chat.length > 0
          ? gridOfChats(state, userId)
          : Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Hmm, it's kinda empty over here",
                    style: Theme.of(context).textTheme.bodyText1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Start a chat or Community?  ",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    navToCreateScreen(context),
                  ],
                )
              ],
            )),
    );
  }

  GestureDetector navToCreateScreen(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(CreateComuinity.routeName),
      child: Container(
          height: 20,
          width: 20,
          child: RiveAnimation.asset('assets/icons/add_icon.riv')),
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

  Widget feed(context, tabController) => FeedScreenWidget(
        tabController: tabController,
      );

  //Container(child: FeedScreenWidget());
}
