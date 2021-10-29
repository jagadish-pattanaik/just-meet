import 'package:google_mobile_ads/google_mobile_ads.dart';
//ca-app-pub-3940256099942544/1033173712 - test interstitial
//ca-app-pub-8291736987357865/5803371039
//ca-app-pub-3940256099942544/5224354917 - test rewarded
//ca-app-pub-8291736987357865/8883751945
class AdHelper {
  InterstitialAd _interstitialAd;
  RewardedAd _rewardedAd;

  void interstitialAdload () {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            this._interstitialAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) =>
                  print('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                print('$ad onAdDismissedFullScreenContent.');
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                ad.dispose();
              },
              onAdImpression: (InterstitialAd ad) {
                interstitialAdload();
                print('$ad impression occurred.');
              }
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            interstitialAdload();
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  void rewardedAdLoad() {
    RewardedAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        request: AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
    onAdLoaded: (RewardedAd ad) {
    print('$ad loaded.');
    // Keep a reference to the ad so you can show it later.
    this._rewardedAd = ad;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad)
      {
        print('$ad impression occurred.');
        rewardedAdLoad();
      }
    );
    },
    onAdFailedToLoad: (LoadAdError error) {
      rewardedAdLoad();
    print('RewardedAd failed to load: $error');
    },
    )
    );
  }

  void showInterstitialAd() {
    _interstitialAd.show();
  }

  void adsDispose() {
    _interstitialAd.dispose();
    _rewardedAd.dispose();
  }

  void showRewardedAd(reward) {
    _rewardedAd.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {
      // Reward the user for watching an ad.
      reward();
    });
  }

  void showNoRewarded() {
    _rewardedAd.show(onUserEarnedReward: (RewardedAd ad, RewardItem rewardItem) {});
  }
}