// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_messaging;

class FirebaseMessaging extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirebaseMessagingPlatform] to avoid
  // creating a [MethodChannelFirebaseMessaging] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseMessagingPlatform _delegatePackingProperty;

  FirebaseMessagingPlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty =
          FirebaseMessagingPlatform.instanceFor(app: app);
    }
    return _delegatePackingProperty;
  }

  /// The [FirebaseApp] for this current [FirebaseMessaging] instance.
  FirebaseApp app;

  FirebaseMessaging._({this.app})
      : super(app.name, 'plugins.flutter.io/firebase_messaging');

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseMessaging get instance {
    return FirebaseMessaging._(app: Firebase.app());
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing Messaging is deprecated, use 'FirebaseMessaging.instance' instead")
  factory FirebaseMessaging() {
    return FirebaseMessaging.instance;
  }

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  Future<bool> requestNotificationPermissions() {
    return _delegate.requestNotificationPermissions();
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return _delegate.onIosSettingsRegistered;
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure() {
    // TODO args
    return _delegate.configure();
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return _delegate.onTokenRefresh;
  }

  /// Returns the FCM token.
  Future<String> getToken() {
    return _delegate.getToken();
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    // TODO validate
    return _delegate.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    // TODO validate
    return _delegate.unsubscribeFromTopic(topic);
  }

  /// Resets Instance ID and revokes all tokens. In iOS, it also unregisters from remote notifications.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging auto-init is enabled.
  ///
  /// returns true if the operations executed successfully and false if an error ocurred
  Future<bool> deleteInstanceID() {
    return _delegate.deleteInstanceID();
  }

  /// Determine whether FCM auto-initialization is enabled or disabled.
  Future<bool> autoInitEnabled() {
    return _delegate.autoInitEnabled();
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    assert(enabled != null);
    return _delegate.setAutoInitEnabled(enabled);
  }
}
