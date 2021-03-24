// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.app.ActivityManager;
import android.app.KeyguardManager;
import android.content.Context;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.RemoteMessage;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

class FlutterFirebaseMessagingUtils {
  static final String IS_AUTO_INIT_ENABLED = "isAutoInitEnabled";
  static final String SHARED_PREFERENCES_KEY = "io.flutter.firebase.messaging.callback";
  static final String ACTION_REMOTE_MESSAGE = "io.flutter.plugins.firebase.messaging.NOTIFICATION";
  static final String EXTRA_REMOTE_MESSAGE = "notification";
  static final String ACTION_TOKEN = "io.flutter.plugins.firebase.messaging.TOKEN";
  static final String EXTRA_TOKEN = "token";
  static final int JOB_ID = 2020;
  private static final String KEY_COLLAPSE_KEY = "collapseKey";
  private static final String KEY_DATA = "data";
  private static final String KEY_FROM = "from";
  private static final String KEY_MESSAGE_ID = "messageId";
  private static final String KEY_MESSAGE_TYPE = "messageType";
  private static final String KEY_SENT_TIME = "sentTime";
  private static final String KEY_TO = "to";
  private static final String KEY_TTL = "ttl";

  static Map<String, Object> remoteMessageToMap(RemoteMessage remoteMessage) {
    Map<String, Object> messageMap = new HashMap<>();
    Map<String, Object> dataMap = new HashMap<>();

    if (remoteMessage.getCollapseKey() != null) {
      messageMap.put(KEY_COLLAPSE_KEY, remoteMessage.getCollapseKey());
    }

    if (remoteMessage.getFrom() != null) {
      messageMap.put(KEY_FROM, remoteMessage.getFrom());
    }

    if (remoteMessage.getTo() != null) {
      messageMap.put(KEY_TO, remoteMessage.getTo());
    }

    if (remoteMessage.getMessageId() != null) {
      messageMap.put(KEY_MESSAGE_ID, remoteMessage.getMessageId());
    }

    if (remoteMessage.getMessageType() != null) {
      messageMap.put(KEY_MESSAGE_TYPE, remoteMessage.getMessageType());
    }

    if (remoteMessage.getData().size() > 0) {
      Set<Map.Entry<String, String>> entries = remoteMessage.getData().entrySet();
      for (Map.Entry<String, String> entry : entries) {
        dataMap.put(entry.getKey(), entry.getValue());
      }
    }

    messageMap.put(KEY_DATA, dataMap);
    messageMap.put(KEY_TTL, remoteMessage.getTtl());
    messageMap.put(KEY_SENT_TIME, remoteMessage.getSentTime());

    if (remoteMessage.getNotification() != null) {
      messageMap.put(
          "notification", remoteMessageNotificationToMap(remoteMessage.getNotification()));
    }

    return messageMap;
  }

  private static Map<String, Object> remoteMessageNotificationToMap(
      RemoteMessage.Notification notification) {
    Map<String, Object> notificationMap = new HashMap<>();
    Map<String, Object> androidNotificationMap = new HashMap<>();

    if (notification.getTitle() != null) {
      notificationMap.put("title", notification.getTitle());
    }

    if (notification.getTitleLocalizationKey() != null) {
      notificationMap.put("titleLocKey", notification.getTitleLocalizationKey());
    }

    if (notification.getTitleLocalizationArgs() != null) {
      notificationMap.put("titleLocArgs", Arrays.asList(notification.getTitleLocalizationArgs()));
    }

    if (notification.getBody() != null) {
      notificationMap.put("body", notification.getBody());
    }

    if (notification.getBodyLocalizationKey() != null) {
      notificationMap.put("bodyLocKey", notification.getBodyLocalizationKey());
    }

    if (notification.getBodyLocalizationArgs() != null) {
      notificationMap.put("bodyLocArgs", Arrays.asList(notification.getBodyLocalizationArgs()));
    }

    if (notification.getChannelId() != null) {
      androidNotificationMap.put("channelId", notification.getChannelId());
    }

    if (notification.getClickAction() != null) {
      androidNotificationMap.put("clickAction", notification.getClickAction());
    }

    if (notification.getColor() != null) {
      androidNotificationMap.put("color", notification.getColor());
    }

    if (notification.getIcon() != null) {
      androidNotificationMap.put("smallIcon", notification.getIcon());
    }

    if (notification.getImageUrl() != null) {
      androidNotificationMap.put("imageUrl", notification.getImageUrl().toString());
    }

    if (notification.getLink() != null) {
      androidNotificationMap.put("link", notification.getLink().toString());
    }

    if (notification.getNotificationCount() != null) {
      androidNotificationMap.put("count", notification.getNotificationCount());
    }

    if (notification.getNotificationPriority() != null) {
      androidNotificationMap.put("priority", notification.getNotificationPriority());
    }

    if (notification.getSound() != null) {
      androidNotificationMap.put("sound", notification.getSound());
    }

    if (notification.getTicker() != null) {
      androidNotificationMap.put("ticker", notification.getTicker());
    }

    if (notification.getVisibility() != null) {
      androidNotificationMap.put("visibility", notification.getVisibility());
    }

    if (notification.getTag() != null) {
      androidNotificationMap.put("tag", notification.getTag());
    }

    notificationMap.put("android", androidNotificationMap);
    return notificationMap;
  }

  /**
   * Identify if the application is currently in a state where user interaction is possible. This
   * method is called when a remote message is received to determine how the incoming message should
   * be handled.
   *
   * @param context context.
   * @return True if the application is currently in a state where user interaction is possible,
   *     false otherwise.
   */
  static boolean isApplicationForeground(Context context) {
    KeyguardManager keyguardManager =
        (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);

    if (keyguardManager != null && keyguardManager.isKeyguardLocked()) {
      return false;
    }

    ActivityManager activityManager =
        (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
    if (activityManager == null) return false;

    List<ActivityManager.RunningAppProcessInfo> appProcesses =
        activityManager.getRunningAppProcesses();
    if (appProcesses == null) return false;

    final String packageName = context.getPackageName();
    for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
      if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
          && appProcess.processName.equals(packageName)) {
        return true;
      }
    }

    return false;
  }

  // Extracted to handle multi-app support in the future.
  // arguments.get("appName") - to get the Firebase app name.
  static FirebaseMessaging getFirebaseMessagingForArguments(Map<String, Object> arguments) {
    return FirebaseMessaging.getInstance();
  }

  /**
   * Builds an instance of {@link RemoteMessage} from Flutter method channel call arguments.
   *
   * @param arguments Method channel call arguments.
   * @return RemoteMessage
   */
  static RemoteMessage getRemoteMessageForArguments(Map<String, Object> arguments) {
    @SuppressWarnings("unchecked")
    Map<String, Object> messageMap =
        (Map<String, Object>) Objects.requireNonNull(arguments.get("message"));

    String to = (String) Objects.requireNonNull(messageMap.get("to"));
    RemoteMessage.Builder builder = new RemoteMessage.Builder(to);

    String collapseKey = (String) messageMap.get("collapseKey");
    String messageId = (String) messageMap.get("messageId");
    String messageType = (String) messageMap.get("messageType");
    Integer ttl = (Integer) messageMap.get("ttl");

    @SuppressWarnings("unchecked")
    Map<String, String> data = (Map<String, String>) messageMap.get("data");

    if (collapseKey != null) {
      builder.setCollapseKey(collapseKey);
    }

    if (messageType != null) {
      builder.setMessageType(messageType);
    }

    if (messageId != null) {
      builder.setMessageId(messageId);
    }

    if (ttl != null) {
      builder.setTtl(ttl);
    }

    if (data != null) {
      builder.setData(data);
    }

    return builder.build();
  }
}
