// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.formats.UnifiedNativeAdView;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
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
import io.flutter.plugin.common.StandardMethodCodec;
import java.util.HashMap;
import java.util.List;
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

  private AdInstanceManager instanceManager;
  private Context applicationContext;
  private Activity activity;
  // This is always null when not using v2 embedding.
  private FlutterPluginBinding pluginBinding;
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
    plugin.initializePlugin(registrar.context(), registrar.activity(), registrar.messenger());
    registrar.publish(plugin);
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
      final Context applicationContext, final Activity activity, final BinaryMessenger messenger) {
    FirebaseApp.initializeApp(applicationContext);
    this.applicationContext = applicationContext;
    this.activity = activity;

    final MethodChannel channel =
        new MethodChannel(
            messenger,
            "plugins.flutter.io/firebase_admob",
            new StandardMethodCodec(new FirebaseAdMobMessageCodec()));
    instanceManager = new AdInstanceManager(channel, activity);

    channel.setMethodCallHandler(this);
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
    instanceManager = null;
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
    instanceManager = null;
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    if (activity == null) {
      result.error("no_activity", "firebase_admob plugin requires a foreground activity", null);
      return;
    }

    switch (call.method) {
      case "INITIALIZE":
        MobileAds.initialize(
            applicationContext,
            new OnInitializationCompleteListener() {
              @Override
              public void onInitializationComplete(InitializationStatus initializationStatus) {
                result.success(null);
              }
            });
        break;
      case "LOAD": {
        final List<Object> arguments = (List<Object>) call.arguments;
        instanceManager.loadAd(
            (Integer) arguments.get(0), (String) arguments.get(1), (List<Object>) arguments.get(2));
        result.success(null);
        break;
      }
      case "SHOW": {
        final List<Object> arguments = (List<Object>) call.arguments;
        instanceManager.showAd((Integer) arguments.get(0), (List<Object>) arguments.get(1));
        break;
      }
      case "DISPOSE":
        instanceManager.disposeAdWithReferenceId((Integer) call.arguments);
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }
}
