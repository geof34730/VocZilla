import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/services/admob_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/blocs/purchase/purchase_is_subscribed_bloc.dart';

class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets padding;
  final String placementId; // NEW: To identify which banner to show

  const AdaptiveBannerAdWidget({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.placementId,
  });

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  late final ValueNotifier<bool> _loadNotifier;

  @override
  void initState() {
    super.initState();
    // Subscribe to updates from the central service
    _loadNotifier = AdMobService.instance.getBannerNotifier(widget.placementId);
    _loadNotifier.addListener(_onAdLoadStateChanged);

    // Get the initial state
    _bannerAd = AdMobService.instance.getBanner(widget.placementId);
    _isLoaded = _loadNotifier.value;
  }

  void _onAdLoadStateChanged() {
    // Rebuild the widget when the ad load state changes
    if (mounted) {
      setState(() {
        _bannerAd = AdMobService.instance.getBanner(widget.placementId);
        _isLoaded = _loadNotifier.value;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the listener
    _loadNotifier.removeListener(_onAdLoadStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseIsSubscribedBloc, PurchaseIsSubscribedState>(
      builder: (context, state) {
        // Only show ads if the user is confirmed not to be subscribed
        if (state.isSubscribed == false) {
          if (_isLoaded && _bannerAd != null) {
            return Padding(
              padding: widget.padding,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            );
          }
        }
        // For all other cases (subscribed, unknown, or ad not loaded), show nothing.
        return const SizedBox.shrink();
      },
    );
  }
}
