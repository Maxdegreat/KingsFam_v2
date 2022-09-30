// ignore_for_file: unused_local_variable
import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    const String prodAdUnitIdA = "ca-app-pub-4874104031068690/5905761705"; // ad serving is limited or baned
    const String prodAdUnitIdB = "ca-app-pub-4874104031068690/3173033338";
    const String testAdUnitId = "ca-app-pub-3940256099942544/6300978111";
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
