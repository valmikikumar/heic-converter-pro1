import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_constants.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsetsGeometry? margin;

  const AdBannerWidget({
    super.key,
    this.adSize,
    this.margin,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: widget.adSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class AdInterstitialService {
  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _interstitialAd = null;
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd(); // Load next ad
        },
      );
      _interstitialAd!.show();
    } else {
      // If no ad is available, load a new one
      loadInterstitialAd();
    }
  }
}

class AdRewardedService {
  static RewardedAd? _rewardedAd;

  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({
    required Function(RewardItem reward) onRewarded,
    VoidCallback? onAdFailedToShow,
  }) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _rewardedAd = null;
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd(); // Load next ad
          onAdFailedToShow?.call();
        },
      );
      
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewarded(reward);
      });
    } else {
      onAdFailedToShow?.call();
      // Load a new ad
      loadRewardedAd();
    }
  }
}

class AdBannerPlaceholder extends StatelessWidget {
  final String? text;

  const AdBannerPlaceholder({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          text ?? 'Advertisement',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
