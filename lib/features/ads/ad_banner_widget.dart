import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import '../subscriptions/bloc/subscription_bloc.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize size;

  const AdBannerWidget({super.key, this.size = AdSize.banner});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  void _maybeLoadAd() {
    final subState = context.read<SubscriptionBloc>().state;
    if (!subState.effectivePlan.isAdFree && _bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, subState) {
        // React to subscription state changes
        if (subState.effectivePlan.isAdFree) {
          // User upgraded to premium — dispose the ad
          if (_bannerAd != null) {
            _disposeAd();
          }
        } else {
          // User is on free tier — load ad if not already loaded
          if (_bannerAd == null) {
            _loadAd();
          }
        }
      },
      builder: (context, subState) {
        // If the user's plan is Ad-Free, return empty
        if (subState.effectivePlan.isAdFree) {
          return const SizedBox.shrink();
        }

        // If the ad is not loaded yet, return a placeholder
        if (!_isAdLoaded || _bannerAd == null) {
          return Container(
            width: widget.size.width.toDouble(),
            height: widget.size.height.toDouble(),
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Text(
              'Advertisement',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          );
        }

        // Return the actual Ad Widget
        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
