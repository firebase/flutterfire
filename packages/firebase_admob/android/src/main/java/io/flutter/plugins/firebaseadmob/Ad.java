package io.flutter.plugins.firebaseadmob;

import android.content.Context;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdView;

abstract class Ad {
  interface AdListenerCallbackHandler {
    void onAdLoaded(Ad ad);
  }

  static class BannerAd extends Ad {
    private final AdView bannerView;
    private final com.google.android.gms.ads.AdRequest request;

    BannerAd(final String adUnitId,
             final AdRequest request,
             final AdSize adSize,
             final Context context,
             final AdListenerCallbackHandler callbackHandler) {
      bannerView = new AdView(context);
      bannerView.setAdUnitId(adUnitId);
      bannerView.setAdSize(adSize.adSize);
      bannerView.setAdListener(createAdListener(callbackHandler, this));
      this.request = request.request;
    }

    @Override
    void load() {
      bannerView.loadAd(request);
    }

    @Override
    void dispose() {

    }
  }

  private static AdListener createAdListener(final AdListenerCallbackHandler callbackHandler,
                                             final Ad ad) {
    return new AdListener() {
      @Override
      public void onAdLoaded() {
        callbackHandler.onAdLoaded(ad);
      }
    };
  }

  abstract void load();
  abstract void dispose();
}
