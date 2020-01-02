// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.firebase_in_app_messaging;

import android.os.Handler;
import android.os.Looper;
import com.google.firebase.inappmessaging.FirebaseInAppMessaging;
import com.google.firebase.inappmessaging.FirebaseInAppMessagingClickListener;
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayCallbacks;
import com.google.firebase.inappmessaging.FirebaseInAppMessagingDisplayErrorListener;
import com.google.firebase.inappmessaging.FirebaseInAppMessagingImpressionListener;
import com.google.firebase.inappmessaging.model.Action;
import com.google.firebase.inappmessaging.model.Button;
import com.google.firebase.inappmessaging.model.InAppMessage;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.HashMap;
import java.util.Map;
import javax.annotation.Nonnull;

/** FirebaseInAppMessagingPlugin */
public class FirebaseInAppMessagingPlugin implements FlutterPlugin, MethodCallHandler {
  private final FirebaseInAppMessaging instance;
  private MethodChannel channel;

  private static MethodChannel setup(BinaryMessenger binaryMessenger) {
    final MethodChannel channel =
        new MethodChannel(binaryMessenger, "plugins.flutter.io/firebase_in_app_messaging");
    channel.setMethodCallHandler(new FirebaseInAppMessagingPlugin());
    return channel;
  }

  public static void registerWith(Registrar registrar) {
    setup(registrar.messenger());
  }

  public FirebaseInAppMessagingPlugin() {
    instance = FirebaseInAppMessaging.getInstance();
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    BinaryMessenger binaryMessenger = binding.getFlutterEngine().getDartExecutor();
    channel = setup(binaryMessenger);
    setupListener();
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "triggerEvent":
        {
          String eventName = call.argument("eventName");
          instance.triggerEvent(eventName);
          result.success(null);
          break;
        }
      case "setMessagesSuppressed":
        {
          Boolean suppress = (Boolean) call.arguments;
          instance.setMessagesSuppressed(suppress);
          result.success(null);
          break;
        }
      case "setAutomaticDataCollectionEnabled":
        {
          Boolean enabled = (Boolean) call.arguments;
          instance.setAutomaticDataCollectionEnabled(enabled);
          result.success(null);
          break;
        }
      default:
        {
          result.notImplemented();
          break;
        }
    }
  }

  @Nonnull
  private Map<String, Object> getMapFromInAppMessage(InAppMessage message, Action action) {
    Map<String, Object> content = new HashMap<>();
    content.put("messageID", message.getCampaignMetadata().getCampaignId());
    content.put("campaignName", message.getCampaignMetadata().getCampaignName());
    Map<String, Object> actionData = new HashMap<>();
    if (action != null) {
      Button actionButton = action.getButton();
      actionData.put("actionText", actionButton == null ? "" : actionButton.getText());
      actionData.put("actionURL", action.getActionUrl() == null ? "" : action.getActionUrl());
    }
    content.put("action", actionData);
    return content;
  }

  private void setupListener() {

    final Handler mHandler = new Handler(Looper.getMainLooper());

    instance.addClickListener(
        new FirebaseInAppMessagingClickListener() {
          @Override
          public void messageClicked(InAppMessage inAppMessage, Action action) {
            final Map<String, Object> data = getMapFromInAppMessage(inAppMessage, action);
            mHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onImpression", data);
                  }
                });
          }
        });

    instance.addDisplayErrorListener(
        new FirebaseInAppMessagingDisplayErrorListener() {
          @Override
          public void displayErrorEncountered(
              InAppMessage inAppMessage,
              FirebaseInAppMessagingDisplayCallbacks.InAppMessagingErrorReason
                  inAppMessagingErrorReason) {
            Map<String, Object> exception = new HashMap<>();
            exception.put("code", inAppMessagingErrorReason.name());
            exception.put("message", "");
            exception.put(
                "details",
                String.format("messageID: %s", inAppMessage.getCampaignMetadata().getCampaignId()));
            channel.invokeMethod("onError", exception);
          }
        });

    instance.addImpressionListener(
        new FirebaseInAppMessagingImpressionListener() {
          @Override
          public void impressionDetected(InAppMessage inAppMessage) {
            final Map<String, Object> data = getMapFromInAppMessage(inAppMessage, null);
            mHandler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    channel.invokeMethod("onImpression", data);
                  }
                });
          }
        });
  }
}
