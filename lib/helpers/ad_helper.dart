// ignore_for_file: unused_local_variable

import 'dart:io';

class AdHelper {
  static String get nativeAdUnitId {
    String testNativeAdUnitId = "ca-app-pub-3940256099942544/2247696110";
    String prodNativeAdUnitIdAndroid =
        testNativeAdUnitId; // "ca-app-pub-5583578072631354/4772946038";
    String prodNativeAdUnitIdIos = "ca-app-pub-5583578072631354/8261954275";

    return testNativeAdUnitId;

    if (Platform.isAndroid) {
      return prodNativeAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return prodNativeAdUnitIdIos;
    } else {
      throw new UnsupportedError("Unsupported Platform");
    }
  }

  static String get bannerAdUnitId {
    String testAdUnitId = "ca-app-pub-3940256099942544/6300978111";
    String prodAdUnitIdA =
        testAdUnitId; //"ca-app-pub-5583578072631354/4427022170";
    String prodBannerAdIos = "ca-app-pub-5583578072631354/9875177985";

    return testAdUnitId;

    if (Platform.isAndroid) {
      // ignore: dead_code
      return prodAdUnitIdA;
    } else if (Platform.isIOS) {
      return prodBannerAdIos; //"ca-app-pub-3940256099942544/2934735716";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}

class AdHelperTest {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw new UnsupportedError("Unsupported platform");
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/2247696110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/3986624511';
    }
    throw new UnsupportedError("Unsupported platform");
  }
}
