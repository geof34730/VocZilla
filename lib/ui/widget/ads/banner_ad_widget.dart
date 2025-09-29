import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/core/utils/logger.dart';
import 'package:voczilla/services/admob_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/blocs/purchase/purchase_is_subscribed_bloc.dart';

class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets padding;
  const AdaptiveBannerAdWidget({super.key, this.padding = EdgeInsets.zero});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  double? _w, _h;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  Future<void> _load(double availableWidth) async {
    if (_loaded || !mounted) return;

    final orientation = MediaQuery.of(context).orientation;
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      orientation,
      availableWidth.truncate(),
    );

    if (!mounted) return;
    if (size == null) {
      Logger.Red.log('Adaptive size null, retrying…');
      Future.delayed(const Duration(seconds: 5), () { // Augmentation du délai
        if (mounted && !_loaded) _load(availableWidth);
      });
      return;
    }

    final ad = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          final banner = ad as BannerAd;
          setState(() {
            _bannerAd?.dispose();
            _bannerAd = banner;
            _w = banner.size.width.toDouble();
            _h = banner.size.height.toDouble();
            _loaded = true;
          });
          Logger.Green.log('Adaptive banner loaded');
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Adaptive failed: ${err.code} - ${err.message}');
          ad.dispose();
          if (mounted) {
            Future.delayed(const Duration(seconds: 10), () { // Augmentation du délai
              if (mounted && !_loaded) _load(availableWidth);
            });
          }
        },
      ),
    );

    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseIsSubscribedBloc, PurchaseIsSubscribedState>(
      builder: (context, state) {
        // On affiche la pub UNIQUEMENT si on sait que l'utilisateur n'est PAS abonné.
        Logger.Green.log("BUILDER: AdaptiveBannerAdWidget ${state.isSubscribed} ");
        if (state.isSubscribed == false) {
          return LayoutBuilder(
            builder: (_, constraints) {
              final maxW = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;

              if (!_loaded && maxW > 0) {
                _load(maxW);
              }

              if (!_loaded || _bannerAd == null || _w == null || _h == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: widget.padding,
                child: SizedBox(
                  width: _w,
                  height: _h,
                  child: AdWidget(ad: _bannerAd!),
                ),
              );
            },
          );
        }

        // Pour tous les autres cas (abonné ou statut inconnu), on n'affiche rien.
        return const SizedBox.shrink();
      },
    );
  }
}
