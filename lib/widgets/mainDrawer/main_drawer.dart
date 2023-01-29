import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/build_church/build_church.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    
    List<Widget> drawerLst = _getCms(); log("drawerList len: ${drawerLst.length}");

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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                 _cmsList(context, drawerLst),
                  
                  Container(
                    height: MediaQuery.of(context).size.height / 2.50,
                    child: NavigationRail(
                      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
                      onDestinationSelected: widget.callBack,
                      selectedIndex: BottomNavItem.values.indexOf(widget.selectedItem),
                      destinations: widget.items.values.map((e) => NavigationRailDestination(icon: e, label: Text(""),)).toList(),
                    )
                  )
                ],
              ),
            ),
            VerticalDivider(
              color: Theme.of(context).colorScheme.inversePrimary,
              thickness: 0.50,
            ),

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
        height: MediaQuery.of(context).size.height / 1.8,
        child: ListView(children: drawerLst));
  }

  List<Widget> _getCms() {
    if (context.read<ChatscreenBloc>().state.chs == null ||
        context.read<ChatscreenBloc>().state.chs!.isEmpty) {
      return [];
    } else {
      return context.read<ChatscreenBloc>().state.chs!.map((c) {
        log("in here");
        setState(() {});
        if (c == null) return SizedBox.shrink();
        return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 0),
              leading: ContainerWithURLImg(
                  imgUrl: c.imageUrl, height: 70, width: 90),
              title: Text(c.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 24, fontStyle: FontStyle.italic)),
              trailing: c.readStatus!
                  ? CircleAvatar(
                      radius: 5,
                      backgroundColor: Theme.of(context).colorScheme.primary)
                  : SizedBox.shrink(),
              onTap: () {
                if (c != context.read<ChatscreenBloc>().state.selectedCh) {
                  context.read<ChatscreenBloc>()
                    ..add(ChatScreenUpdateSelectedCm(cm: c));
                  Navigator.of(context).pop();
                }
              },
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
