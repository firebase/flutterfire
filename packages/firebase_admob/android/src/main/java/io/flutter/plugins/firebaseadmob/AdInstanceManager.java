package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.content.Context;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class AdInstanceManager implements Ad.AdListenerCallbackHandler {
  private Context context;
  private final Map<Integer, Ad> referenceIdToAdMap = new HashMap<>();
  public final Map<String, FirebaseAdMobPlugin.NativeAdFactory> nativeAdFactories = new HashMap<>();
  private final MethodChannel callbackChannel;

  AdInstanceManager(final MethodChannel callbackChannel, final Context context) {
    this.callbackChannel = callbackChannel;
    this.context = context;
  }

  void loadAd(final Integer referenceId, final String className, final List<Object> parameters) {
    final Ad ad = createAd(className, parameters);
    referenceIdToAdMap.put(referenceId, ad);
    ad.load();
  }

  private void sendMethodCall(final Ad ad, final String methodName, final List<Object> arguments) {
    final List<Object> methodCallArgs = new ArrayList<>();
    methodCallArgs.add(referenceIdForAd(ad));
    methodCallArgs.add(arguments);
    callbackChannel.invokeMethod(methodName, methodCallArgs);
  }

  void showAd(final int referenceId, final List<Object> parameters) {
    final Ad ad = referenceIdToAdMap.get(referenceId);

    if (ad instanceof Ad.PlatformViewAd) {
      ((Ad.PlatformViewAd) ad).show((Double) parameters.get(0), (Double) parameters.get(1), (AnchorType) parameters.get(2));
      return;
    } else if (ad instanceof Ad.InterstitialAd) {
      ((Ad.InterstitialAd) ad).show();
    }

    throw new IllegalStateException();
  }

  private int referenceIdForAd(Ad ad) {
    for (final int referenceId : referenceIdToAdMap.keySet()) {
      if (referenceIdToAdMap.get(referenceId) == ad) return referenceId;
    }
    throw new IllegalStateException();
  }

  void disposeAdWithReferenceId(final int referenceId) {
    final Ad ad = referenceIdToAdMap.get(referenceId);
    if (ad == null) return;
    if (ad instanceof Ad.PlatformViewAd) ((Ad.PlatformViewAd) ad).dispose();
    referenceIdToAdMap.remove(referenceId);
  }

  private Ad createAd(final String className, final List<Object> parameters) {
    switch (className) {
      case "BannerAd":
        return new Ad.BannerAd(
            (String) parameters.get(0),
            (AdRequest) parameters.get(1),
            (AdSize) parameters.get(2),
            (Activity) context,
            this);
      case "InterstitialAd":
        return new Ad.InterstitialAd(
            (String) parameters.get(0),
            (AdRequest) parameters.get(1),
            (Activity) context,
            this
        );
      case "NativeAd":
        return new Ad.NativeAd(
            (String) parameters.get(0),
            (AdRequest) parameters.get(1),
            (Activity) context,
            nativeAdFactories.get(parameters.get(2)),
            (Map<String, Object>) parameters.get(3),
            this
        );
    }
    throw new IllegalArgumentException();
  }

  @Override
  public void onAdLoaded(Ad ad) {
    sendMethodCall(ad, "AdListener#onAdLoaded", null);
  }
}
