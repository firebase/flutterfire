package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;

import java.util.Map;

import io.flutter.plugin.platform.PlatformView;

abstract class Ad {
  final com.google.android.gms.ads.AdRequest request;
  final Activity activity;

  interface AdListenerCallbackHandler {
    void onAdLoaded(Ad ad);
  }

  static abstract class PlatformViewAd extends Ad implements PlatformView {
    private final int viewId;

    PlatformViewAd(final AdRequest request, final Activity activity) {
      super(request, activity);
      this.viewId = hashCode();
    }

    void show(double anchorOffset, double horizontalCenterOffset, final AnchorType anchorType) {
      dispose();

        final LinearLayout adViewParent = new LinearLayout(activity);
        adViewParent.setId(viewId);
        adViewParent.setOrientation(LinearLayout.VERTICAL);
        adViewParent.addView(getView());
        final float scale = activity.getResources().getDisplayMetrics().density;

        int left = horizontalCenterOffset > 0 ? (int) (horizontalCenterOffset * scale) : 0;
        int right =
            horizontalCenterOffset < 0 ? (int) (Math.abs(horizontalCenterOffset) * scale) : 0;
        if (anchorType == AnchorType.BOTTOM) {
          adViewParent.setPadding(left, 0, right, (int) (anchorOffset * scale));
          adViewParent.setGravity(Gravity.BOTTOM);
        } else {
          adViewParent.setPadding(left, (int) (anchorOffset * scale), right, 0);
          adViewParent.setGravity(Gravity.TOP);
        }

        activity.addContentView(
            adViewParent,
            new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

      @Override
      public void dispose() {
        final LinearLayout adViewParent = activity.findViewById(viewId);
        if (adViewParent == null) return;

        final ViewGroup rootView = (ViewGroup) adViewParent.getParent();
        rootView.removeView(adViewParent);
        adViewParent.removeView(getView());
      }
  }

  static abstract class FullScreenAd extends Ad {
    FullScreenAd(final AdRequest request, final Activity activity) {
      super(request, activity);
    }

    abstract void show();
  }

  static class BannerAd extends PlatformViewAd {
    private final AdView bannerView;
    private final com.google.android.gms.ads.AdRequest request;
    private final Activity activity;

    BannerAd(
        final String adUnitId,
        final AdRequest request,
        final AdSize adSize,
        final Activity activity,
        final AdListenerCallbackHandler callbackHandler) {
      super(request, activity);
      bannerView = new AdView(activity);
      bannerView.setAdUnitId(adUnitId);
      bannerView.setAdSize(adSize.adSize);
      bannerView.setAdListener(createAdListener(callbackHandler, this));
      this.request = request.request;
      this.activity = activity;
    }

    @Override
    void load() {
      bannerView.loadAd(request);
    }

    @Override
    public View getView() {
      return bannerView;
    }
  }

  static class InterstitialAd extends FullScreenAd {
    private final com.google.android.gms.ads.InterstitialAd interstitialAd;

    InterstitialAd(
        final String adUnitId,
        final AdRequest request,
        final Activity activity,
        final AdListenerCallbackHandler callbackHandler) {
      super(request, activity);
      interstitialAd = new com.google.android.gms.ads.InterstitialAd(activity);
      interstitialAd.setAdUnitId(adUnitId);
      interstitialAd.setAdListener(createAdListener(callbackHandler, this));
    }

    @Override
    void load() {
      interstitialAd.loadAd(request);
    }

    @Override
    void show() {
      interstitialAd.show();
    }
  }

  static class NativeAd extends PlatformViewAd implements UnifiedNativeAd.OnUnifiedNativeAdLoadedListener {
    private final AdLoader adLoader;
    private final FirebaseAdMobPlugin.NativeAdFactory nativeAdFactory;
    private final Map<String, Object> customOptions;
    private final AdListenerCallbackHandler callbackHandler;
    private UnifiedNativeAdView adView;

    NativeAd(
        final String adUnitId,
        final AdRequest request,
        final Activity activity,
        final FirebaseAdMobPlugin.NativeAdFactory nativeAdFactory,
        final Map<String, Object> customOptions,
        final AdListenerCallbackHandler callbackHandler) {
      super(request, activity);
      adLoader = new AdLoader.Builder(activity, adUnitId)
          .forUnifiedNativeAd(this)
          .withAdListener(Ad.createAdListener(callbackHandler, this))
          .build();
      this.nativeAdFactory = nativeAdFactory;
      this.customOptions = customOptions;
      this.callbackHandler = callbackHandler;
    }

    @Override
    void load() {
      adLoader.loadAd(request);
    }

    @Override
    public View getView() {
      return adView;
    }

    @Override
    public void onUnifiedNativeAdLoaded(final UnifiedNativeAd unifiedNativeAd) {
      adView = nativeAdFactory.createNativeAd(unifiedNativeAd, customOptions);
    }
  }

  private static AdListener createAdListener(
      final AdListenerCallbackHandler callbackHandler, final Ad ad) {
    return new AdListener() {
      @Override
      public void onAdLoaded() {
        callbackHandler.onAdLoaded(ad);
      }
    };
  }

  Ad(final AdRequest request, final Activity activity) {
    this.request = request.request;
    this.activity = activity;
  }

  abstract void load();
}
