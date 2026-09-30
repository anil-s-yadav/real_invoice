with open('d:/real_invoice/lib/features/ads/ad_helper.dart', 'r', encoding='utf-8') as f:
    content = f.read()

new_content = """import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3285536359619016/8770780103'; // Real Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3285536359619016/8770780103'; // Real iOS Banner
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3285536359619016/8894069036'; // Real Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3285536359619016/8894069036'; // Real iOS Interstitial
    }
    throw UnsupportedError('Unsupported platform');
  }
}
"""

with open('d:/real_invoice/lib/features/ads/ad_helper.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("ad_helper.dart reverted to strictly use real IDs")