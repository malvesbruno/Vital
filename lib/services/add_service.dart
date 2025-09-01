// app_open_ad_manager.dart
import 'dart:io';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';


// serviço de anúncio 

class AppOpenAdManager {
  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3137295951622134/9776666054' // teste Android
      : 'ca-app-pub-3137295951622134/9776666054'; // teste iOS

  AppOpenAd? _appOpenAd;
  bool _isShowing = false;
  DateTime? _loadTime;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _loadTime = DateTime.now();
        },
        onAdFailedToLoad: (err) => print('AppOpenAd failed to load: $err'),
      ),
    );
  }

  bool get isAdAvailable {
    return _appOpenAd != null &&
        DateTime.now().difference(_loadTime!).inHours < 4;
  }

  Future<void> showAd() {
    final completer = Completer<void>();

    if (_appOpenAd == null) {
      completer.complete();
      return completer.future;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowing = false;
        _appOpenAd = null;
        loadAd(); // pré-carrega novo anúncio
        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowing = false;
        _appOpenAd = null;
        completer.complete();
      },
    );

    _isShowing = true;
    _appOpenAd!.show();

    return completer.future;
  }
}
