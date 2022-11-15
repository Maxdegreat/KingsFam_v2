import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/widgets/says_container.dart';

import '../../../config/paths.dart';
import '../../../models/church_model.dart';
import '../../../widgets/chats_view_widgets/chats_screen_widgets.dart';
import '../../../widgets/fancy_list_tile.dart';
import '../../commuinity/commuinity_screen.dart';
import '../bloc/chatscreen_bloc.dart';

class showJoinedCms extends StatefulWidget {
  const showJoinedCms({
    Key? key,
    required this.state,
    required this.currId,
  }) : super(key: key);

  final String currId;
  final ChatscreenState state;

  @override
  State<showJoinedCms> createState() => _showJoinedCmsState();
}

class _showJoinedCmsState extends State<showJoinedCms> {
  late NativeAd _nativeAd;
  bool _isNativeAdLoaded = false;
  void _createBottomBannerAd() {
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
    _createBottomBannerAd();
    super.initState();
  }

  @override
  void dispose() {
    _nativeAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // this is the nativeAd.
    dynamic nativeAd = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: _isNativeAdLoaded
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(hc.hexcolorCode("#141829")),
                    ),
                    height: 70,
                    child: AdWidget(
                      ad: _nativeAd,
                    ),
                  )
                : SizedBox()));

    List<dynamic> showChsWithAd = widget.state.chs!.map((cm) {
      // FirebaseFirestore.instance
      //     .collection(Paths.mention)
      //     .doc(widget.currId)
      //     .collection(cm!.id!)
      //     .snapshots()
      //     .isEmpty;

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(CommuinityScreen.routeName,
                  arguments: CommuinityScreenArgs(
                    commuinity: cm!,
                  )),
          child: FancyListTile(
            // ------------------------- update hee
            isMentioned: widget.state.mentionedMap[cm!.id],
            newNotification: false,
            location: cm.location.length > 1 ? cm.location : null,
            username: cm.name,
            imageUrl: cm.imageUrl,
            onTap: () => Navigator.of(context).pushNamed(
                CommuinityScreen.routeName,
                arguments: CommuinityScreenArgs(commuinity: cm)),
            isBtn: false,
            BR: 12.0,
            height: 12.0,
            width: 12.0,
          ),
        ),
      );
    }).toList();

    // where to plact the nativeAd
    if (showChsWithAd.length < 3)
      showChsWithAd.add(nativeAd);
    else
      showChsWithAd.insert(3, nativeAd);

    return Expanded(
        flex: 1,
        child: Column(
          children: [
            Flexible(
              //height: MediaQuery.of(context).size.height - 241,
              child: ListView.builder(
                itemCount: widget.state.chs!.length + 1,
                itemBuilder: (context, index) {
                  return showChsWithAd[index];
                },
              ),
            ),
          ],
        ));
  }
}
