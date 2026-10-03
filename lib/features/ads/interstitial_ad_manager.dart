import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import '../subscriptions/bloc/subscription_bloc.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;
  static bool _isLoading = false;

  static void loadAd(BuildContext context) {
    if (_isAdLoaded || _isLoading) return;

    final subState = context.read<SubscriptionBloc>().state;
    if (subState.effectivePlan.isAdFree) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
              // Preload next ad silently
              // Using Future.microtask prevents build context issues across frames
              Future.microtask(() {
                if (context.mounted) {
                  loadAd(context);
                }
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  static void showAd(BuildContext context) {
    final subState = context.read<SubscriptionBloc>().state;
    if (subState.effectivePlan.isAdFree) return;

    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      loadAd(context);
    }
  }
}
