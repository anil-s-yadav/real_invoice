import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Google Test Banner
      }
      return 'ca-app-pub-3285536359619016/8770780103'; // Real Android Banner
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/2934735716';
      return 'ca-app-pub-3285536359619016/8770780103'; // Real iOS Banner
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/1033173712'; // Google Test Interstitial
      }
      return 'ca-app-pub-3285536359619016/8894069036'; // Real Android Interstitial
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/4411468910';
      return 'ca-app-pub-3285536359619016/8894069036'; // Real iOS Interstitial
    }
    return '';
  }
}
