import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/camera/bloc/camera_screen.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/helpers/clipboard.dart';
import 'package:kingsfam/helpers/cm_perm_handler.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';
import 'package:kingsfam/helpers/image_helper.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/storage/storage_repository.dart';
import 'package:kingsfam/repositories/userr/userr_repository.dart';
import 'package:kingsfam/screens/build_church/build_church.dart';
import 'package:kingsfam/screens/build_church/cubit/buildchurch_cubit.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/commuinity_screen.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/commuinity/community_settings/update_privacy.dart';
import 'package:kingsfam/screens/commuinity/screens/create_room/create_room.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/commuinity_feed.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/widgets/display_msg.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/says_room.dart';
import 'package:kingsfam/screens/commuinity/screens/vc/vc_screen.dart';
import 'package:kingsfam/screens/commuinity/wrapers/participants_view.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/widgets/drawer_icon_container.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screens/commuinity/screens/kings cord/kingscord.dart';

part '../../screens/commuinity/wrapers/cm_widgets.dart';
part '../../screens/commuinity/wrapers/community_screen_methods.dart';

class MainDrawer extends StatefulWidget {
  final Function(int) callBack;
  final Map<BottomNavItem, Widget> items;
  final BottomNavItem selectedItem;
  const MainDrawer(
      {Key? key,
      required this.callBack,
      required this.items,
      required this.selectedItem})
      : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late NativeAd _nativeAd;
  bool _isNativeAdLoaded = false;
  void _createNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        factoryId: "listTile",
        listener: NativeAdListener(onAdLoaded: (_) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("chatsScreen ad error: ${error.toString()}");
        }),
        request: const AdRequest());
    _nativeAd.load();
  }

  @override
  void initState() {
    _createNativeAd();
    super.initState();
  }

  @override
  void dispose() {
    _nativeAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerLst = _getCms();

    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        width: MediaQuery.of(context).size.width,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 4.350,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _cmsList(context, drawerLst),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(BuildChurch.routeName),
                    child: drawerIcon(Icon(Icons.add, color: Theme.of(context).colorScheme.secondary,))),
                  // SizedBox(child: Divider(color: Theme.of(context).colorScheme.inversePrimary), width: 70,),
                  Container(
                      height: MediaQuery.of(context).size.height / 2.50,
                      child: NavigationRail(
                        selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
                        backgroundColor:
                            Theme.of(context).drawerTheme.backgroundColor,
                        onDestinationSelected: widget.callBack,
                        selectedIndex:
                            BottomNavItem.values.indexOf(widget.selectedItem),
                        destinations: widget.items.values
                            .map((e) => NavigationRailDestination(
                                  icon: e,
                                  label: Text(""),
                                ))
                            .toList(),
                      ))
                ],
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.inversePrimary,
              thickness: 0.30,
            ),
            if (context.read<ChatscreenBloc>().state.selectedCh != null) ...[
              BlocBuilder<CommuinityBloc, CommuinityState>(
                builder: (context, state) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 1.395,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        header(
                            cm: context
                                .read<ChatscreenBloc>()
                                .state
                                .selectedCh!,
                            context: context,
                            cmBloc: context.read<CommuinityBloc>()),


                        SizedBox(height: 8),

                        singlePostDisplay(
                              cm: context
                                  .read<ChatscreenBloc>()
                                  .state
                                  .selectedCh!,
                              context: context,
                              cmBloc: context.read<CommuinityBloc>(),
                              ad: null,
                            ),

                        // if (state.mentionedCords.length > 0) ... [
                        //   showMentions(context, cm),
                        //   SizedBox(height: 8),
                        // ],

                        showRooms(
                            context,
                            context
                                .read<ChatscreenBloc>()
                                .state
                                .selectedCh!),

                        SizedBox(height: 8),

                        showVoice(
                            context,
                            context
                                .read<ChatscreenBloc>()
                                .state
                                .selectedCh!),

                        SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              )
            ]
          ],
        ),
      ),
    );
  }

  _createNewCm() {
    return Expanded(
        flex: 2,
        // height: 50, //MediaQuery.of(context).size.height * .3,
        child: ListTile(
            onTap: () => Navigator.of(context).pushNamed(BuildChurch.routeName),
            leading: Icon(Iconsax.add_square4, size: 20),
            title: Text("Create new community",
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontStyle: FontStyle.italic))));
  }

  _showAd() {
    return _isNativeAdLoaded
        ? Expanded(
            //height: 50, // MediaQuery.of(context).size.height * .1,
            flex: 2,
            // width: MediaQuery.of(context).size.width / 2.2,
            child: AdWidget(ad: _nativeAd),
            // decoration: BoxDecoration(
            //    color: Theme.of(context).colorScheme.primary,
            //    borderRadius: BorderRadius.circular(10),
            // ),
          )
        : SizedBox.shrink();
  }

  Container _cmsList(BuildContext context, List<Widget> drawerLst) {
    return Container(
        height: MediaQuery.of(context).size.height / 2.09,
        child: ListView(children: drawerLst));
  }

  List<Widget> _getCms() {
    if (context.read<ChatscreenBloc>().state.chs == null ||
        context.read<ChatscreenBloc>().state.chs!.isEmpty) {
      return [];
    } else {
      return context.read<ChatscreenBloc>().state.chs!.map((c) {
        setState(() {});
        if (c == null) return SizedBox.shrink();
        return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: GestureDetector(
              onTap: () {
                if (c != context.read<ChatscreenBloc>().state.selectedCh) {
                  context.read<ChatscreenBloc>()
                    ..add(ChatScreenUpdateSelectedCm(cm: c));
                  setState(() {});
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: c == context.read<ChatscreenBloc>().state.selectedCh
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3)
                        : null),
                child: ContainerWithURLImg(
                    imgUrl: c.imageUrl,
                    height: MediaQuery.of(context).size.shortestSide / 6,
                    width: MediaQuery.of(context).size.shortestSide / 6),
              ),
            ));
      }).toList();
    }
  }
}

// Widget MainDrawer(BuildContext context, ChatscreenBloc? chatScreenBloc) {

  

//   return SafeArea(
//     child: Drawer(

//   );
// }
