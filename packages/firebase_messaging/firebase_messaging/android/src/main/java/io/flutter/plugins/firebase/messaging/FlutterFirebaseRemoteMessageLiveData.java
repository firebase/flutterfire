package io.flutter.plugins.firebase.messaging;

import androidx.lifecycle.LiveData;
import com.google.firebase.messaging.RemoteMessage;

public class FlutterFirebaseRemoteMessageLiveData extends LiveData<RemoteMessage> {
  private static FlutterFirebaseRemoteMessageLiveData instance;

  public static FlutterFirebaseRemoteMessageLiveData getInstance() {
    if (instance == null) {
      instance = new FlutterFirebaseRemoteMessageLiveData();
    }
    return instance;
  }

  public void postRemoteMessage(RemoteMessage remoteMessage) {
    postValue(remoteMessage);
  }
}
