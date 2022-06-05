import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/helpers/ad_helper.dart';

class AdvertismentRepo {
    List<dynamic> createInlineBannerAd({required BannerAd inLineBannerAd, required inLineBannerAdLoaded}) {
    inLineBannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
            inLineBannerAdLoaded = true;
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("ad.dart _createInlineBannerAd ad error: ${error.toString()}");
        }),
        request: AdRequest());
    inLineBannerAd.load();
    return [inLineBannerAd, inLineBannerAdLoaded];
  }
}