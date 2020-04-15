package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdView;

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

    abstract Activity getActivity();

    void show(double anchorOffset, double horizontalCenterOffset, final AnchorType anchorType) {
      dispose();

        final LinearLayout content = new LinearLayout(getActivity());
        content.setId(viewId);
        content.setOrientation(LinearLayout.VERTICAL);
        content.addView(getView());
        final float scale = getActivity().getResources().getDisplayMetrics().density;

        int left = horizontalCenterOffset > 0 ? (int) (horizontalCenterOffset * scale) : 0;
        int right =
            horizontalCenterOffset < 0 ? (int) (Math.abs(horizontalCenterOffset) * scale) : 0;
        if (anchorType == AnchorType.BOTTOM) {
          content.setPadding(left, 0, right, (int) (anchorOffset * scale));
          content.setGravity(Gravity.BOTTOM);
        } else {
          content.setPadding(left, (int) (anchorOffset * scale), right, 0);
          content.setGravity(Gravity.TOP);
        }

        getActivity().addContentView(
            content,
            new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

      @Override
      public void dispose() {
        final View contentView = getActivity().findViewById(viewId);
        if (contentView == null || !(contentView.getParent() instanceof ViewGroup)) return;

        final ViewGroup contentParent = (ViewGroup) contentView.getParent();
        contentParent.removeView(contentView);
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

    @Override
    Activity getActivity() {
      return activity;
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
