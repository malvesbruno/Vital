import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//anuncio intersticial

class InterstitialAdService {
  static final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3137295951622134/5974215471' // seu ID real do intersticial
      : 'ca-app-pub-3940256099942544/4411468910'; // teste iOS, troque se for usar

  static InterstitialAd? _interstitialAd;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Erro ao carregar interstitial: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showAd({Function()? onAdClosed}) {
    if (_interstitialAd == null) {
      print('Interstitial não disponível.');
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadAd(); // Pré-carrega outro
        if (onAdClosed != null) onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Erro ao exibir interstitial: $error');
        ad.dispose();
        loadAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
