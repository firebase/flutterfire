// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasedynamiclinks;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.TaskCompletionSource;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.dynamiclinks.DynamicLink;
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks;
import com.google.firebase.dynamiclinks.PendingDynamicLinkData;
import com.google.firebase.dynamiclinks.ShortDynamicLink;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import io.flutter.plugins.firebase.core.FlutterFirebasePluginRegistry;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicReference;


public class FirebaseDynamicLinksPlugin
  implements FlutterFirebasePlugin, FlutterPlugin, ActivityAware, MethodCallHandler, NewIntentListener {
  private final AtomicReference<Activity> activity = new AtomicReference<>(null);

  private MethodChannel channel;
  @Nullable
  private BinaryMessenger messenger;

  private final Map<EventChannel, StreamHandler> streamHandlers = new HashMap<>();


  private static final String METHOD_CHANNEL_NAME = "plugins.flutter.io/firebase_dynamic_links";


  private static MethodChannel createChannel(final BinaryMessenger messenger) {
    return new MethodChannel(messenger, "plugins.flutter.io/firebase_dynamic_links");
  }

  private void initInstance(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, METHOD_CHANNEL_NAME);
    channel.setMethodCallHandler(this);
    FlutterFirebasePluginRegistry.registerPlugin(METHOD_CHANNEL_NAME, this);

    this.messenger = messenger;
  }


  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    initInstance(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    channel = null;
    messenger = null;
//TODO add this for listening to events
//    removeEventListeners();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    activity.set(binding.getActivity());
    //TODO make sure I'm using this feature. if not, remove.
    binding.addOnNewIntentListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    detachToActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    activity.set(binding.getActivity());
    binding.addOnNewIntentListener(this);
  }

  private void detachToActivity() {
    activity.set(null);
  }

  @Override
  public void onDetachedFromActivity() {
    detachToActivity();
  }

  static FirebaseDynamicLinks getDynamicLinkInstance(Map<String, Object> arguments) {
    String appName = (String) Objects.requireNonNull(arguments.get(Constants.APP_NAME));
    FirebaseApp app = FirebaseApp.getInstance(appName);

    return FirebaseDynamicLinks.getInstance(app);
  }

  //TODO make sure I'm using this properly
  @Override
  public boolean onNewIntent(Intent intent) {
    FirebaseDynamicLinks.getInstance()
      .getDynamicLink(intent)
      .addOnSuccessListener(
        new OnSuccessListener<PendingDynamicLinkData>() {
          @Override
          public void onSuccess(PendingDynamicLinkData pendingDynamicLinkData) {
            if (pendingDynamicLinkData != null) {
              Map<String, Object> dynamicLink =
                Utils.getMapFromPendingDynamicLinkData(pendingDynamicLinkData);
              channel.invokeMethod("onLinkSuccess", dynamicLink);
            }
          }
        })
      .addOnFailureListener(
        new OnFailureListener() {
          @Override
          public void onFailure(Exception e) {
            Map<String, Object> exception = new HashMap<>();
            exception.put("code", e.getClass().getSimpleName());
            exception.put("message", e.getMessage());
            exception.put("details", null);
            channel.invokeMethod("onLinkError", exception);
          }
        });

    return false;
  }


  @Override
  public void onMethodCall(MethodCall call, @NonNull final MethodChannel.Result result) {
    Task<?> methodCallTask;
    DynamicLink.Builder urlBuilder = setupParameters(call.arguments());
    FirebaseDynamicLinks dynamicLinks = getDynamicLinkInstance(call.arguments());

    switch (call.method) {
      case "DynamicLinkBuilder#buildUrl":
        String url = buildUrl(call.arguments());
        result.success(url);
        return;
      case "DynamicLinkBuilder#buildShortLink":
        methodCallTask = buildShortLink(urlBuilder, call.argument("dynamicLinkParametersOptions"));
        break;
      case "DynamicLinkBuilder#shortenUrl":
        urlBuilder.setLongLink(Uri.parse(call.argument("url")));
        methodCallTask = buildShortLink(urlBuilder, call.argument("dynamicLinkParametersOptions"));
        break;
      case "FirebaseDynamicLinks#getDynamicLink":
      case "FirebaseDynamicLinks#getInitialLink":
        methodCallTask = getDynamicLink(dynamicLinks, call.argument("url"));
        break;
      case "FirebaseDynamicLinks#onLink":
        methodCallTask = registerGetLinkListener(Objects.requireNonNull(call.argument(Constants.APP_NAME)), dynamicLinks);
        break;
      default:
        result.notImplemented();
        return;
    }


    methodCallTask.addOnCompleteListener(
      task -> {
        if (task.isSuccessful()) {
          result.success(task.getResult());
        } else {
          Exception exception = task.getException();
          result.error(
            Constants.DEFAULT_ERROR_CODE,
            exception != null ? exception.getMessage() : null,
            Utils.getExceptionDetails(exception));
        }
      });
  }

  private String buildUrl(Map<String, Object> arguments) {
    DynamicLink.Builder urlBuilder = setupParameters(arguments);

    return urlBuilder.buildDynamicLink().getUri().toString();
  }

  private Task<Map<String, Object>> buildShortLink(DynamicLink.Builder urlBuilder, @Nullable Map<String, Object> dynamicLinkParametersOptions) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        Integer suffix = null;

        if (dynamicLinkParametersOptions != null) {
          Integer shortDynamicLinkPathLength =
            (Integer) dynamicLinkParametersOptions.get("shortDynamicLinkPathLength");
          if (shortDynamicLinkPathLength != null) {
            switch (shortDynamicLinkPathLength) {
              case 0:
                suffix = ShortDynamicLink.Suffix.UNGUESSABLE;
                break;
              case 1:
                suffix = ShortDynamicLink.Suffix.SHORT;
                break;
              default:
                break;
            }
          }
        }

        Map<String, Object> result = new HashMap<>();
        ShortDynamicLink shortLink;
        if (suffix != null) {
          shortLink = Tasks.await(urlBuilder.buildShortDynamicLink(suffix));
        } else {
          shortLink = Tasks.await(urlBuilder.buildShortDynamicLink());
        }
        List<String> warnings = new ArrayList<>();

        for (ShortDynamicLink.Warning warning : shortLink.getWarnings()) {
          warnings.add(warning.getMessage());
        }

        result.put("url", shortLink.getShortLink());
        result.put("warnings", warnings);
        result.put("previewLink", shortLink.getPreviewLink());

        return result;
      }
    );
  }

  private Task<Map<String, Object>> getDynamicLink(FirebaseDynamicLinks dynamicLinks, @Nullable String url) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        PendingDynamicLinkData pendingDynamicLink;

        if (url != null) {
          pendingDynamicLink = Tasks.await(dynamicLinks.getDynamicLink(Uri.parse(url)));
        } else {
          // If there's no activity or initial Intent, then there's no initial dynamic link.
          if (activity.get() == null || activity.get().getIntent() == null) {
            return null;
          }
          pendingDynamicLink = Tasks.await(dynamicLinks.getDynamicLink(activity.get().getIntent()));
        }

        return Utils.getMapFromPendingDynamicLinkData(pendingDynamicLink);
      }
    );
  }

  private DynamicLink.Builder setupParameters(Map<String, Object> arguments) {
    DynamicLink.Builder dynamicLinkBuilder = FirebaseDynamicLinks.getInstance().createDynamicLink();

    String uriPrefix = (String) arguments.get("uriPrefix");
    String link = (String) arguments.get("link");

    dynamicLinkBuilder.setDomainUriPrefix(uriPrefix);
    dynamicLinkBuilder.setLink(Uri.parse(link));

    Map<String, Object> androidParameters = (Map<String, Object>) arguments.get("androidParameters");
    if (androidParameters != null) {
      String packageName = valueFor("packageName", androidParameters);
      String fallbackUrl = valueFor("fallbackUrl", androidParameters);
      Integer minimumVersion = valueFor("minimumVersion", androidParameters);

      DynamicLink.AndroidParameters.Builder builder =
        new DynamicLink.AndroidParameters.Builder(packageName);

      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse(fallbackUrl));
      if (minimumVersion != null) builder.setMinimumVersion(minimumVersion);

      dynamicLinkBuilder.setAndroidParameters(builder.build());
    }

    Map<String, Object> googleAnalyticsParameters = (Map<String, Object>) arguments.get("googleAnalyticsParameters");
    if (googleAnalyticsParameters != null) {
      String campaign = valueFor("campaign", googleAnalyticsParameters);
      String content = valueFor("content", googleAnalyticsParameters);
      String medium = valueFor("medium", googleAnalyticsParameters);
      String source = valueFor("source", googleAnalyticsParameters);
      String term = valueFor("term", googleAnalyticsParameters);

      DynamicLink.GoogleAnalyticsParameters.Builder builder =
        new DynamicLink.GoogleAnalyticsParameters.Builder();

      if (campaign != null) builder.setCampaign(campaign);
      if (content != null) builder.setContent(content);
      if (medium != null) builder.setMedium(medium);
      if (source != null) builder.setSource(source);
      if (term != null) builder.setTerm(term);

      dynamicLinkBuilder.setGoogleAnalyticsParameters(builder.build());
    }

    Map<String, Object> iosParameters = (Map<String, Object>) arguments.get("iosParameters");
    if (iosParameters != null) {
      String bundleId = valueFor("bundleId", iosParameters);
      String appStoreId = valueFor("appStoreId", iosParameters);
      String customScheme = valueFor("customScheme", iosParameters);
      String fallbackUrl = valueFor("fallbackUrl", iosParameters);
      String ipadBundleId = valueFor("ipadBundleId", iosParameters);
      String ipadFallbackUrl = valueFor("ipadFallbackUrl", iosParameters);
      String minimumVersion = valueFor("minimumVersion", iosParameters);

      DynamicLink.IosParameters.Builder builder = new DynamicLink.IosParameters.Builder(bundleId);

      if (appStoreId != null) builder.setAppStoreId(appStoreId);
      if (customScheme != null) builder.setCustomScheme(customScheme);
      if (fallbackUrl != null) builder.setFallbackUrl(Uri.parse(fallbackUrl));
      if (ipadBundleId != null) builder.setIpadBundleId(ipadBundleId);
      if (ipadFallbackUrl != null) builder.setIpadFallbackUrl(Uri.parse(ipadFallbackUrl));
      if (minimumVersion != null) builder.setMinimumVersion(minimumVersion);

      dynamicLinkBuilder.setIosParameters(builder.build());
    }

    Map<String, Object> itunesConnectAnalyticsParameters = (Map<String, Object>)
      arguments.get("itunesConnectAnalyticsParameters");
    if (itunesConnectAnalyticsParameters != null) {
      String affiliateToken = valueFor("affiliateToken", itunesConnectAnalyticsParameters);
      String campaignToken = valueFor("campaignToken", itunesConnectAnalyticsParameters);
      String providerToken = valueFor("providerToken", itunesConnectAnalyticsParameters);

      DynamicLink.ItunesConnectAnalyticsParameters.Builder builder =
        new DynamicLink.ItunesConnectAnalyticsParameters.Builder();

      if (affiliateToken != null) builder.setAffiliateToken(affiliateToken);
      if (campaignToken != null) builder.setCampaignToken(campaignToken);
      if (providerToken != null) builder.setProviderToken(providerToken);

      dynamicLinkBuilder.setItunesConnectAnalyticsParameters(builder.build());
    }

    Map<String, Object> navigationInfoParameters = (Map<String, Object>) arguments.get("navigationInfoParameters");
    if (navigationInfoParameters != null) {
      Boolean forcedRedirectEnabled = valueFor("forcedRedirectEnabled", navigationInfoParameters);

      DynamicLink.NavigationInfoParameters.Builder builder =
        new DynamicLink.NavigationInfoParameters.Builder();

      if (forcedRedirectEnabled != null) builder.setForcedRedirectEnabled(forcedRedirectEnabled);

      dynamicLinkBuilder.setNavigationInfoParameters(builder.build());
    }

    Map<String, Object> socialMetaTagParameters = (Map<String, Object>) arguments.get("socialMetaTagParameters");
    if (socialMetaTagParameters != null) {
      String description = valueFor("description", socialMetaTagParameters);
      String imageUrl = valueFor("imageUrl", socialMetaTagParameters);
      String title = valueFor("title", socialMetaTagParameters);

      DynamicLink.SocialMetaTagParameters.Builder builder =
        new DynamicLink.SocialMetaTagParameters.Builder();

      if (description != null) builder.setDescription(description);
      if (imageUrl != null) builder.setImageUrl(Uri.parse(imageUrl));
      if (title != null) builder.setTitle(title);

      dynamicLinkBuilder.setSocialMetaTagParameters(builder.build());
    }

    return dynamicLinkBuilder;
  }

  private Task<String> registerGetLinkListener(@NonNull String appName, FirebaseDynamicLinks dynamicLinks) {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        final GetLinkStreamHandler handler = new GetLinkStreamHandler(dynamicLinks);
        final String name = METHOD_CHANNEL_NAME + "/get-link/" + appName;
        final EventChannel channel = new EventChannel(messenger, name);
        channel.setStreamHandler(handler);
        streamHandlers.put(channel, handler);
        return name;
      });
  }

  private static <T> T valueFor(String key, Map<String, Object> map) {
    @SuppressWarnings("unchecked")
    T result = (T) map.get(key);
    return result;
  }

  @Override
  public Task<Map<String, Object>> getPluginConstantsForFirebaseApp(FirebaseApp firebaseApp) {
    return null;
  }

  @Override
  public Task<Void> didReinitializeFirebaseCore() {
    return Tasks.call(
      cachedThreadPool,
      () -> {
        removeEventListeners();
        return null;
      });
  }

  private void removeEventListeners(){
    for (EventChannel eventChannel : streamHandlers.keySet()) {
      StreamHandler streamHandler = streamHandlers.get(eventChannel);
      assert streamHandler != null;
      streamHandler.onCancel(null);
      eventChannel.setStreamHandler(null);
    }
    streamHandlers.clear();
  }
}
