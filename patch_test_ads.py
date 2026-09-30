with open('d:/real_invoice/lib/features/ads/ad_helper.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_content = """import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/6300978111'; // Google Test Banner
      return 'ca-app-pub-3285536359619016/8770780103'; // Real Android Banner
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/2934735716';
      return 'ca-app-pub-3285536359619016/8770780103'; // Real iOS Banner
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712'; // Google Test Interstitial
      return 'ca-app-pub-3285536359619016/8894069036'; // Real Android Interstitial
    } else if (Platform.isIOS) {
      if (kDebugMode) return 'ca-app-pub-3940256099942544/4411468910';
      return 'ca-app-pub-3285536359619016/8894069036'; // Real iOS Interstitial
    }
    throw UnsupportedError('Unsupported platform');
  }
}
"""

with open('d:/real_invoice/lib/features/ads/ad_helper.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("ad_helper.dart reverted to kDebugMode for test ads")