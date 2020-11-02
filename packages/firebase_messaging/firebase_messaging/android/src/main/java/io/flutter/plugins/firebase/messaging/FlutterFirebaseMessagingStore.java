// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebase.messaging;

import android.content.Context;
import android.content.SharedPreferences;
import com.google.firebase.messaging.RemoteMessage;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class FlutterFirebaseMessagingStore {
  private static final String PREFERENCES_FILE = "io.flutter.plugins.firebase.messaging";
  private static final String KEY_NOTIFICATION_IDS = "notification_ids";
  private static final int MAX_SIZE_NOTIFICATIONS = 20;
  private static FlutterFirebaseMessagingStore instance;
  private final String DELIMITER = ",";
  private SharedPreferences preferences;

  public static FlutterFirebaseMessagingStore getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseMessagingStore();
    }
    return instance;
  }

  private SharedPreferences getPreferences() {
    if (preferences == null) {
      preferences =
          ContextHolder.getApplicationContext()
              .getSharedPreferences(PREFERENCES_FILE, Context.MODE_PRIVATE);
    }
    return preferences;
  }

  public void setPreferencesStringValue(String key, String value) {
    getPreferences().edit().putString(key, value).apply();
  }

  public String getPreferencesStringValue(String key, String defaultValue) {
    return getPreferences().getString(key, defaultValue);
  }

  public void storeFirebaseMessage(RemoteMessage remoteMessage) {
    String remoteMessageString =
        new JSONObject(FlutterFirebaseMessagingUtils.remoteMessageToMap(remoteMessage)).toString();
    setPreferencesStringValue(remoteMessage.getMessageId(), remoteMessageString);

    // Save new notification id.
    // Note that this is using a comma delimited string to preserve ordering. We could use a String Set
    // on SharedPreferences but this won't guarantee ordering when we want to remove the oldest added ids.
    String notifications = getPreferencesStringValue(KEY_NOTIFICATION_IDS, "");
    notifications += remoteMessage.getMessageId() + DELIMITER; // append to last

    // Check and remove old notification messages.
    List<String> allNotificationList =
        new ArrayList<>(Arrays.asList(notifications.split(DELIMITER)));
    if (allNotificationList.size() > MAX_SIZE_NOTIFICATIONS) {
      String firstRemoteMessageId = allNotificationList.get(0);
      getPreferences().edit().remove(firstRemoteMessageId).apply();
      notifications = notifications.replace(firstRemoteMessageId + DELIMITER, "");
    }

    setPreferencesStringValue(KEY_NOTIFICATION_IDS, notifications);
  }

  public RemoteMessage getFirebaseMessage(String remoteMessageId) {
    String remoteMessageString = getPreferencesStringValue(remoteMessageId, null);
    if (remoteMessageString != null) {
      try {
        Map<String, Object> argumentsMap = new HashMap<>(1);
        Map<String, Object> messageOutMap = jsonObjectToMap(new JSONObject(remoteMessageString));
        // Add a fake 'to' - as it's required to construct a RemoteMessage instance.
        messageOutMap.put("to", remoteMessageId);
        argumentsMap.put("message", messageOutMap);
        return FlutterFirebaseMessagingUtils.getRemoteMessageForArguments(argumentsMap);
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
    return null;
  }

  public void removeFirebaseMessage(String remoteMessageId) {
    getPreferences().edit().remove(remoteMessageId).apply();
    String notifications = getPreferencesStringValue(KEY_NOTIFICATION_IDS, "");
    if (!notifications.isEmpty()) {
      notifications = notifications.replace(remoteMessageId + DELIMITER, "");
      setPreferencesStringValue(KEY_NOTIFICATION_IDS, notifications);
    }
  }

  private Map<String, Object> jsonObjectToMap(JSONObject jsonObject) throws JSONException {
    Map<String, Object> map = new HashMap<>();
    Iterator<String> keys = jsonObject.keys();
    while (keys.hasNext()) {
      String key = keys.next();
      Object value = jsonObject.get(key);
      if (value instanceof JSONArray) {
        value = jsonArrayToList((JSONArray) value);
      } else if (value instanceof JSONObject) {
        value = jsonObjectToMap((JSONObject) value);
      }
      map.put(key, value);
    }
    return map;
  }

  public List<Object> jsonArrayToList(JSONArray array) throws JSONException {
    List<Object> list = new ArrayList<>();
    for (int i = 0; i < array.length(); i++) {
      Object value = array.get(i);
      if (value instanceof JSONArray) {
        value = jsonArrayToList((JSONArray) value);
      } else if (value instanceof JSONObject) {
        value = jsonObjectToMap((JSONObject) value);
      }
      list.add(value);
    }
    return list;
  }
}
