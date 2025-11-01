import 'dart:io';

class AdHelper {
  /// Change this to `false` before publishing to Play Store
  static bool get isTestMode => false;

  /// Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/6300978111' // ✅ Test Banner
          : 'ca-app-pub-2227439392595568/7422595994'; // ✅ Your Banner
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/2934735716'
          : throw UnsupportedError('Production iOS ad unit not configured');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Interstitial Ad Unit ID
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/1033173712' // ✅ Test Interstitial
          : 'ca-app-pub-2227439392595568/9745507001'; // ✅ Your Interstitial
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/4411468910'
          : throw UnsupportedError('Production iOS ad unit not configured');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
