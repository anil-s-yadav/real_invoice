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
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Ad failed to load: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        // If the user's plan is Ad-Free, we return an empty widget
        if (subState.plan?.isAdFree ?? false) {
          return const SizedBox.shrink();
        }

        // If the ad is not loaded yet, or it failed, return a placeholder or shrink
        if (!_isAdLoaded || _bannerAd == null) {
          return SizedBox(
            width: widget.size.width.toDouble(),
            height: widget.size.height.toDouble(),
            child: const SizedBox.shrink(),
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
