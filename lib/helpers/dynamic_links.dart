import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/screens.dart';

class FirebaseDynamicLinkService {
  static Future<String> createDynamicLink(Church cmData, bool isShort) async {
    String? _linkMessage;

    final dynamicLinkParams = DynamicLinkParameters(
      socialMetaTagParameters: SocialMetaTagParameters(),
      navigationInfoParameters: NavigationInfoParameters(forcedRedirectEnabled: false),
      link: Uri.parse("https://www.kingsfam.com/cmData?id=${cmData.id}"),
      uriPrefix: "https://kingsfam.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.kingbiz.kingsfam",
        minimumVersion: 0,
      ),
      iosParameters: IOSParameters(
        bundleId: "com.kingbiz.kingsfam",
        // fallbackUrl: Uri.parse("https://testflight.apple.com/join/oPDxmw2T"),
        appStoreId: "123456789",
        minimumVersion: "1.0.1",
      ),
    );

    Uri? url;

    if (isShort) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
      url = shortLink.shortUrl;
    }

    _linkMessage = url.toString();
    return _linkMessage;
  }

  // when app is not terminated this is how the link will open app.
  static Future<void> initDynamicLink(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      log("in init dynamic link");
      final Uri deepLink = dynamicLinkData.link;
      bool isCm = deepLink.pathSegments.contains("cmData");
      if (isCm) {
        log("is cmId");
        String? cmId = deepLink.queryParameters['id'];

        if (cmId != null) {
          log("naving to cm");
          DocumentSnapshot snap = await FirebaseFirestore.instance
              .collection(Paths.church)
              .doc(cmId)
              .get();
          Church? cm = await Church.fromDoc(snap);
          Navigator.of(context).pushNamed(CommunityHome.routeName,
              arguments: CommunityHomeArgs(cm: cm, cmB: null));
          // context.read<BottomnavbarCubit>().updateSelectedItem(BottomNavItem.chats);
          // context.read<ChatscreenBloc>().add(ChatScreenUpdateSelectedCm(cm: cm));
        }
      }
    }).onError((error) {
      log("!!!!! error occurred DynamicLinkService: " + error.message);
    });
  }
}
