import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:voczilla/core/utils/logger.dart';
import 'package:voczilla/services/admob_service.dart';

import '../../../logic/blocs/user/user_bloc.dart';
import '../../../logic/blocs/user/user_state.dart';

class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets padding;
  const BannerAdWidget({super.key, this.adSize = AdSize.banner, this.padding = EdgeInsets.zero});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _didInitialLoad = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      final userState = context.read<UserBloc>().state;
      bool isSubscribed = false;
      if (userState is UserSessionLoaded) {
        isSubscribed = userState.isSubscribed;
      }

      print('**********************isSubscribed : $isSubscribed');
      if (isSubscribed) {
        return;
      }
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    if (_isAdLoading) {
      return;
    }
    _isAdLoading = true;

    Logger.Green.log('************************************_BannerAdWidgetState _loadBannerAd');
    BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      request: const AdRequest(),
      size: widget.adSize,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            _isAdLoading = false;
            return;
          }
          Logger.Green.log('Banner ad loaded.');
          setState(() {
            _bannerAd?.dispose();
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
          _isAdLoading = false;
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Banner ad failed to load: ${err.message}');
          ad.dispose();
          _isAdLoading = false;
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        bool isSubscribed = false;
        if (state is UserSessionLoaded) {
          isSubscribed = state.isSubscribed;
        }

        if (isSubscribed) {
          return const SizedBox.shrink();
        }

        return _isAdLoaded && _bannerAd != null
            ? SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: Padding(padding: widget.padding, child: AdWidget(ad: _bannerAd!)),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets padding;

  const AdaptiveBannerAdWidget({super.key, this.padding = EdgeInsets.zero});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _didInitialLoad = false;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      final userState = context.read<UserBloc>().state;
      bool isSubscribed = false;
      if (userState is UserSessionLoaded) {
        isSubscribed = userState.isSubscribed;
      }
      if (isSubscribed) {
        return;
      }
      _loadBannerAd();
    }
  }

  void _loadBannerAd() async {
    if (_isAdLoading) {
      return;
    }
    _isAdLoading = true;

    Logger.Green.log('************************************_AdaptiveBannerAdWidgetState _loadBannerAd');

    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      Logger.Red.log('Unable to get anchored adaptive banner ad size.');
      _isAdLoading = false;
      return;
    }

    BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            _isAdLoading = false;
            return;
          }
          Logger.Green.log('Adaptive banner ad loaded.');
          setState(() {
            _bannerAd?.dispose();
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
          });
          _isAdLoading = false;
        },
        onAdFailedToLoad: (ad, err) {
          Logger.Red.log('Adaptive banner ad failed to load: ${err.message}');
          ad.dispose();
          _isAdLoading = false;
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        bool isSubscribed = false;
        if (state is UserSessionLoaded) {
          isSubscribed = state.isSubscribed;
        }

        if (isSubscribed) {
          return const SizedBox.shrink();
        }

        return _isAdLoaded && _bannerAd != null
            ? Padding(
                padding: widget.padding,
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}
