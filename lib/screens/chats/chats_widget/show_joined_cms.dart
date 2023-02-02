import 'dart:developer';

import "package:flutter/material.dart";
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';


import '../../../widgets/fancy_list_tile.dart';
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
                      gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topCenter,
              colors: [
                Color(hc.hexcolorCode("#20263c")),
                Color(hc.hexcolorCode("#141829"))
              ]),
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
              Navigator.of(context).pushNamed(CommunityHome.routeName, arguments: CommunityHomeArgs(cm: cm!, cmB: null)),
          child: FancyListTile(
            // ------------------------- update hee
            context: context,
            isMentioned: widget.state.mentionedMap[cm!.id],
            newNotification: false,
            location: cm.location.length > 1 ? cm.location : null,
            username: cm.name,
            imageUrl: cm.imageUrl,
            onTap: () => Navigator.of(context).pushNamed(CommunityHome.routeName, arguments: CommunityHomeArgs(cm: cm, cmB: null)),
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
