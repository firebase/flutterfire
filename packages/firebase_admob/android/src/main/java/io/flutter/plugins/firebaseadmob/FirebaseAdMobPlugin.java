// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.Gravity;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import com.google.firebase.FirebaseApp;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Flutter plugin accessing Firebase Admob API.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FirebaseAdMobPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  // This the plugin key used in the Embedding V1 generated GeneratedRegistrant.java. This key is
  // used when this plugin publishes it's self in registerWith(registrar).
  private static final String GENERATED_PLUGIN_KEY =
      "io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin";

  private Context applicationContext;
  private MethodChannel channel;
  private Activity activity;
  // This is always null when not using v2 embedding.
  private FlutterPluginBinding pluginBinding;
  private RewardedVideoAdWrapper rewardedWrapper;
  private final Map<String, NativeAdFactory> nativeAdFactories = new HashMap<>();

  /**
   * Interface used to display a {@link com.google.android.gms.ads.formats.UnifiedNativeAd}.
   *
   * <p>Added to a {@link io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin} and creates {@link
   * com.google.android.gms.ads.formats.UnifiedNativeAdView}s from Native Ads created in Dart.
   */
  public interface NativeAdFactory {
    /**
     * Creates a {@link com.google.android.gms.ads.formats.UnifiedNativeAdView} with a {@link
     * com.google.android.gms.ads.formats.UnifiedNativeAd}.
     *
     * @param nativeAd Ad information used to create a {@link
     *     com.google.android.gms.ads.formats.UnifiedNativeAdView}
     * @param customOptions Used to pass additional custom options to create the {@link
     *     com.google.android.gms.ads.formats.UnifiedNativeAdView}. Nullable.
     * @return a {@link com.google.android.gms.ads.formats.UnifiedNativeAdView} that is overlaid on
     *     top of the FlutterView.
     */
    UnifiedNativeAdView createNativeAd(UnifiedNativeAd nativeAd, Map<String, Object> customOptions);
  }

  /**
   * Registers a plugin with the v1 embedding api {@code io.flutter.plugin.common}.
   *
   * <p>Calling this will register the plugin with the passed registrar. However, plugins
   * initialized this way won't react to changes in activity or context.
   *
   * @param registrar connects this plugin's {@link
   *     io.flutter.plugin.common.MethodChannel.MethodCallHandler} to its {@link
   *     io.flutter.plugin.common.BinaryMessenger}.
   */
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background Flutter view tries to register the plugin, there will be no activity from the registrar.
      // We stop the registering process immediately because the firebase_admob requires an activity.
      return;
    }

    final FirebaseAdMobPlugin plugin = new FirebaseAdMobPlugin();
    registrar.publish(plugin);
    plugin.initializePlugin(registrar.context(), registrar.activity(), registrar.messenger());
  }

  /**
   * Adds a {@link io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} used to
   * create {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s from a Native Ad created
   * in Dart.
   *
   * @param registry maintains access to a FirebaseAdMobPlugin instance.
   * @param factoryId a unique identifier for the ad factory. The Native Ad created in Dart includes
   *     a parameter that refers to this.
   * @param nativeAdFactory creates {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s
   *     when Flutter NativeAds are created.
   * @return whether the factoryId is unique and the nativeAdFactory was successfully added.
   */
  public static boolean registerNativeAdFactory(
      PluginRegistry registry, String factoryId, NativeAdFactory nativeAdFactory) {
    final FirebaseAdMobPlugin adMobPlugin = registry.valuePublishedByPlugin(GENERATED_PLUGIN_KEY);
    return registerNativeAdFactory(adMobPlugin, factoryId, nativeAdFactory);
  }

  /**
   * Registers a {@link io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} used
   * to create {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s from a Native Ad
   * created in Dart.
   *
   * @param engine maintains access to a FirebaseAdMobPlugin instance.
   * @param factoryId a unique identifier for the ad factory. The Native Ad created in Dart includes
   *     a parameter that refers to this.
   * @param nativeAdFactory creates {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s
   *     when Flutter NativeAds are created.
   * @return whether the factoryId is unique and the nativeAdFactory was successfully added.
   */
  public static boolean registerNativeAdFactory(
      FlutterEngine engine, String factoryId, NativeAdFactory nativeAdFactory) {
    final FirebaseAdMobPlugin adMobPlugin =
        (FirebaseAdMobPlugin) engine.getPlugins().get(FirebaseAdMobPlugin.class);
    return registerNativeAdFactory(adMobPlugin, factoryId, nativeAdFactory);
  }

  private static boolean registerNativeAdFactory(
      FirebaseAdMobPlugin plugin, String factoryId, NativeAdFactory nativeAdFactory) {
    if (plugin == null) {
      final String message =
          String.format(
              "Could not find a %s instance. The plugin may have not been registered.",
              FirebaseAdMobPlugin.class.getSimpleName());
      throw new IllegalStateException(message);
    }

    return plugin.addNativeAdFactory(factoryId, nativeAdFactory);
  }

  /**
   * Unregisters a {@link io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} used
   * to create {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s from a Native Ad
   * created in Dart.
   *
   * @param registry maintains access to a FirebaseAdMobPlugin instance.
   * @param factoryId a unique identifier for the ad factory. The Native ad created in Dart includes
   *     a parameter that refers to this.
   * @return the previous {@link
   *     io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} associated with this
   *     factoryId, or null if there was none for this factoryId.
   */
  public static NativeAdFactory unregisterNativeAdFactory(
      PluginRegistry registry, String factoryId) {
    final FirebaseAdMobPlugin adMobPlugin = registry.valuePublishedByPlugin(GENERATED_PLUGIN_KEY);
    if (adMobPlugin != null) adMobPlugin.removeNativeAdFactory(factoryId);

    return null;
  }

  /**
   * Unregisters a {@link io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} used
   * to create {@link com.google.android.gms.ads.formats.UnifiedNativeAdView}s from a Native Ad
   * created in Dart.
   *
   * @param engine maintains access to a FirebaseAdMobPlugin instance.
   * @param factoryId a unique identifier for the ad factory. The Native ad created in Dart includes
   *     a parameter that refers to this.
   * @return the previous {@link
   *     io.flutter.plugins.firebaseadmob.FirebaseAdMobPlugin.NativeAdFactory} associated with this
   *     factoryId, or null if there was none for this factoryId.
   */
  public static NativeAdFactory unregisterNativeAdFactory(FlutterEngine engine, String factoryId) {
    final FlutterPlugin adMobPlugin = engine.getPlugins().get(FirebaseAdMobPlugin.class);
    if (adMobPlugin != null) {
      return ((FirebaseAdMobPlugin) adMobPlugin).removeNativeAdFactory(factoryId);
    }

    return null;
  }

  private boolean addNativeAdFactory(String factoryId, NativeAdFactory nativeAdFactory) {
    if (nativeAdFactories.containsKey(factoryId)) {
      final String errorMessage =
          String.format(
              "A NativeAdFactory with the following factoryId already exists: %s", factoryId);
      Log.e(FirebaseAdMobPlugin.class.getSimpleName(), errorMessage);
      return false;
    }

    nativeAdFactories.put(factoryId, nativeAdFactory);
    return true;
  }

  private NativeAdFactory removeNativeAdFactory(String factoryId) {
    return nativeAdFactories.remove(factoryId);
  }

  private void initializePlugin(
      Context applicationContext, Activity activity, BinaryMessenger messenger) {
    this.activity = activity;
    this.applicationContext = applicationContext;
    FirebaseApp.initializeApp(applicationContext);

    this.channel = new MethodChannel(messenger, "plugins.flutter.io/firebase_admob");
    channel.setMethodCallHandler(this);

    rewardedWrapper = new RewardedVideoAdWrapper(activity, channel);
  }

  private void callInitialize(MethodCall call, Result result) {
    String appId = call.argument("appId");
    if (appId == null || appId.isEmpty()) {
      result.error("no_app_id", "a null or empty AdMob appId was provided", null);
      return;
    }
    MobileAds.initialize(applicationContext, appId);
    result.success(Boolean.TRUE);
  }

  private void callLoadNativeAd(Integer id, Activity activity, MethodCall call, Result result) {
    final String adUnitId = call.argument("adUnitId");
    final String factoryId = call.argument("factoryId");

    final NativeAdFactory nativeAdFactory = nativeAdFactories.get(factoryId);

    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error("no_unit_id", "a null or empty adUnitId was provided for ad id=" + id, null);
      return;
    } else if (nativeAdFactory == null) {
      final String errorMessage =
          String.format(
              "There is no non-null %s for the following factoryId: %s",
              NativeAdFactory.class.getSimpleName(), factoryId);
      result.error("no_native_ad_factory", errorMessage, null);
      return;
    }

    final Map<String, Object> customOptions = call.argument("customOptions");

    final MobileAd.Native nativeAd =
        MobileAd.createNative(id, activity, channel, nativeAdFactory, customOptions);

    if (nativeAd.status != MobileAd.Status.CREATED) {
      if (nativeAd.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    final Map<String, Object> targetingInfo = call.argument("targetingInfo");
    nativeAd.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callLoadBannerAd(Integer id, Activity activity, MethodCall call, Result result) {
    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error("no_unit_id", "a null or empty adUnitId was provided for ad id=" + id, null);
      return;
    }

    final Integer width = call.argument("width");
    final Integer height = call.argument("height");
    final String adSizeType = call.argument("adSizeType");

    if (!"AdSizeType.WidthAndHeight".equals(adSizeType)
        && !"AdSizeType.SmartBanner".equals(adSizeType)) {
      String errMsg =
          String.format(
              Locale.ENGLISH,
              "an invalid adSizeType (%s) was provided for banner id=%d",
              adSizeType,
              id);
      result.error("invalid_adsizetype", errMsg, null);
    }

    if ("AdSizeType.WidthAndHeight".equals(adSizeType) && (width <= 0 || height <= 0)) {
      String errMsg =
          String.format(
              Locale.ENGLISH,
              "an invalid AdSize (%d, %d) was provided for banner id=%d",
              width,
              height,
              id);
      result.error("invalid_adsize", errMsg, null);
    }

    AdSize adSize;
    if ("AdSizeType.SmartBanner".equals(adSizeType)) {
      adSize = AdSize.SMART_BANNER;
    } else {
      adSize = new AdSize(width, height);
    }

    MobileAd.Banner banner = MobileAd.createBanner(id, adSize, activity, channel);

    if (banner.status != MobileAd.Status.CREATED) {
      if (banner.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    banner.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callLoadInterstitialAd(MobileAd ad, MethodCall call, Result result) {
    if (ad.status != MobileAd.Status.CREATED) {
      if (ad.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + ad.id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error(
          "no_adunit_id", "a null or empty adUnitId was provided for ad id=" + ad.id, null);
      return;
    }
    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    ad.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callLoadRewardedVideoAd(MethodCall call, Result result) {
    if (rewardedWrapper.getStatus() != RewardedVideoAdWrapper.Status.CREATED
        && rewardedWrapper.getStatus() != RewardedVideoAdWrapper.Status.FAILED) {
      result.success(Boolean.TRUE); // The ad was already loading or loaded.
      return;
    }

    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error(
          "no_ad_unit_id", "a non-empty adUnitId was not provided for rewarded video", null);
      return;
    }

    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    if (targetingInfo == null) {
      result.error(
          "no_targeting_info", "a null targetingInfo object was provided for rewarded video", null);
      return;
    }

    rewardedWrapper.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callShowAd(Integer id, MethodCall call, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("ad_not_loaded", "show failed, the specified ad was not loaded id=" + id, null);
      return;
    }
    final String anchorOffset = call.argument("anchorOffset");
    final String horizontalCenterOffset = call.argument("horizontalCenterOffset");
    final String anchorType = call.argument("anchorType");
    if (anchorOffset != null) {
      ad.anchorOffset = Double.parseDouble(anchorOffset);
    }
    if (anchorType != null) {
      ad.horizontalCenterOffset = Double.parseDouble(horizontalCenterOffset);
    }
    if (anchorType != null) {
      ad.anchorType = "bottom".equals(anchorType) ? Gravity.BOTTOM : Gravity.TOP;
    }

    ad.show();
    result.success(Boolean.TRUE);
  }

  private void callIsAdLoaded(Integer id, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("no_ad_for_id", "isAdLoaded failed, no add exists for id=" + id, null);
      return;
    }
    result.success(ad.status == MobileAd.Status.LOADED ? Boolean.TRUE : Boolean.FALSE);
  }

  private void callShowRewardedVideoAd(Result result) {
    if (rewardedWrapper.getStatus() == RewardedVideoAdWrapper.Status.LOADED) {
      rewardedWrapper.show();
      result.success(Boolean.TRUE);
    } else {
      result.error("ad_not_loaded", "show failed for rewarded video, no ad was loaded", null);
    }
  }

  private void callSetRewardedVideoAdUserId(MethodCall call, Result result) {
    String userId = call.argument("userId");

    rewardedWrapper.setUserId(userId);
    result.success(Boolean.TRUE);
  }

  private void callSetRewardedVideoAdCustomData(MethodCall call, Result result) {
    String customData = call.argument("customData");

    rewardedWrapper.setCustomData(customData);
    result.success(Boolean.TRUE);
  }

  private void callDisposeAd(Integer id, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("no_ad_for_id", "dispose failed, no add exists for id=" + id, null);
      return;
    }

    ad.dispose();
    result.success(Boolean.TRUE);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    initializePlugin(
        pluginBinding.getApplicationContext(),
        binding.getActivity(),
        pluginBinding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    MobileAd.disposeAll();
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    initializePlugin(
        pluginBinding.getApplicationContext(),
        binding.getActivity(),
        pluginBinding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromActivity() {
    MobileAd.disposeAll();
    activity = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (activity == null) {
      result.error("no_activity", "firebase_admob plugin requires a foreground activity", null);
      return;
    }

    Integer id = call.argument("id");

    switch (call.method) {
      case "initialize":
        callInitialize(call, result);
        break;
      case "loadBannerAd":
        callLoadBannerAd(id, activity, call, result);
        break;
      case "loadInterstitialAd":
        callLoadInterstitialAd(MobileAd.createInterstitial(id, activity, channel), call, result);
        break;
      case "loadRewardedVideoAd":
        callLoadRewardedVideoAd(call, result);
        break;
      case "loadNativeAd":
        callLoadNativeAd(id, activity, call, result);
        break;
      case "showAd":
        callShowAd(id, call, result);
        break;
      case "showRewardedVideoAd":
        callShowRewardedVideoAd(result);
        break;
      case "setRewardedVideoAdUserId":
        callSetRewardedVideoAdUserId(call, result);
        break;
      case "setRewardedVideoAdCustomData":
        callSetRewardedVideoAdCustomData(call, result);
        break;
      case "disposeAd":
        callDisposeAd(id, result);
        break;
      case "isAdLoaded":
        callIsAdLoaded(id, result);
        break;
      default:
        result.notImplemented();
    }
  }
}
