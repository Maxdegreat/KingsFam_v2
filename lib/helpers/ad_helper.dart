// ignore_for_file: unused_local_variable

import 'dart:io';

class AdHelper {

  static String get nativeAdUnitId {
    String prodNativeAdUnitId = "ca-app-pub-5583578072631354/4772946038";
    String testNativeAdUnitId = "ca-app-pub-3940256099942544/2247696110";

    if (Platform.isAndroid) {
      return testNativeAdUnitId;
    } else {
      return "";
    }
  }

  static String get bannerAdUnitId {
    String prodAdUnitIdA = "ca-app-pub-5583578072631354/4427022170";
    String testAdUnitId = "ca-app-pub-3940256099942544/6300978111";
    if (Platform.isAndroid) {
      // ignore: dead_code
      return testAdUnitId ;
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/2934735716";
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
