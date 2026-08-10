import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  /// Automatically use test ads in debug mode and production ads in release mode
  static bool get isTestMode => kDebugMode;

  static BannerAd? preloadedBannerAd;
  static InterstitialAd? preloadedInterstitialAd;
  static RewardedAd? preloadedRewardedAd;

  static bool isBannerLoading = false;
  static bool isInterstitialLoading = false;
  static bool isRewardedLoading = false;

  static final ValueNotifier<bool> adsLoadedNotifier = ValueNotifier(false);

  static bool get isPreloadComplete {
    return preloadedBannerAd != null &&
        preloadedInterstitialAd != null &&
        preloadedRewardedAd != null;
  }

  static void checkPreloadStatus() {
    if (isPreloadComplete) {
      adsLoadedNotifier.value = true;
    }
  }

  static Future<void> preloadAllAds() async {
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  static void loadBannerAd() {
    if (preloadedBannerAd != null || isBannerLoading) return;
    isBannerLoading = true;
    preloadedBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerLoading = false;
          debugPrint('✅ Preloaded Banner loaded');
          checkPreloadStatus();
        },
        onAdFailedToLoad: (ad, error) {
          isBannerLoading = false;
          debugPrint('❌ Preloaded Banner failed to load: ${error.message}');
          ad.dispose();
          preloadedBannerAd = null;
          Future.delayed(const Duration(seconds: 5), loadBannerAd);
        },
      ),
    )..load();
  }

  static void loadInterstitialAd() {
    if (preloadedInterstitialAd != null || isInterstitialLoading) return;
    isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          isInterstitialLoading = false;
          preloadedInterstitialAd = ad;
          debugPrint('✅ Preloaded Interstitial loaded');
          checkPreloadStatus();
        },
        onAdFailedToLoad: (error) {
          isInterstitialLoading = false;
          debugPrint('❌ Preloaded Interstitial failed to load: ${error.message}');
          preloadedInterstitialAd = null;
          Future.delayed(const Duration(seconds: 5), loadInterstitialAd);
        },
      ),
    );
  }

  static void loadRewardedAd() {
    if (preloadedRewardedAd != null || isRewardedLoading) return;
    isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          isRewardedLoading = false;
          preloadedRewardedAd = ad;
          debugPrint('✅ Preloaded Rewarded ad loaded');
          checkPreloadStatus();
        },
        onAdFailedToLoad: (error) {
          isRewardedLoading = false;
          debugPrint('❌ Preloaded Rewarded ad failed to load: ${error.message}');
          preloadedRewardedAd = null;
          Future.delayed(const Duration(seconds: 5), loadRewardedAd);
        },
      ),
    );
  }

  /// Banner Ad Unit ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/6300978111' // ✅ Test Banner
          : 'ca-app-pub-2227439392595568/4658693677'; // ✅ Your Banner
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/2934735716' // iOS Test Banner
          : 'ca-app-pub-2227439392595568/3048998417'; // Production iOS Banner
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
          ? 'ca-app-pub-3940256099942544/4411468910' // iOS Test Interstitial
          : 'ca-app-pub-2227439392595568/5918704337'; // Production iOS Interstitial
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Rewarded Ad Unit ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Android Test Rewarded
          : 'ca-app-pub-2227439392595568/9745507010'; // Android Production Placeholder
    } else if (Platform.isIOS) {
      return isTestMode
          ? 'ca-app-pub-3940256099942544/1712485313' // iOS Test Rewarded
          : 'ca-app-pub-2227439392595568/6136382092'; // Production iOS Rewarded
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
