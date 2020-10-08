// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_messaging;

/// The [FirebaseMessaging] entry point.
///
/// To get a new instance, call [FirebaseMessaging.instance].
class FirebaseMessaging extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirebaseMessagingPlatform] to avoid
  // creating a [MethodChannelFirebaseMessaging] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseMessagingPlatform _delegatePackingProperty;

  FirebaseMessagingPlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty = FirebaseMessagingPlatform.instanceFor(
          app: app, pluginConstants: pluginConstants);
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

  /// Returns an instance using a specified [FirebaseApp]
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  static FirebaseMessaging instanceFor({
    FirebaseApp app,
  }) {
    app ??= Firebase.app();
    assert(app != null);

    String key = '${app.name}';
    if (_cachedInstances.containsKey(key)) {
      return _cachedInstances[key];
    }

    FirebaseMessaging newInstance = FirebaseMessaging._(app: app);
    _cachedInstances[key] = newInstance;

    return newInstance;
  }

  static final Map<String, FirebaseMessaging> _cachedInstances = {};

  /// Sets up handlers for various messaging events.
  static void configure({
    RemoteMessageHandler onMessage,
    void Function(String messageId) onMessageSent,
    RemoteMessageHandler onNotificationOpenedApp,
    void Function(FirebaseException exception, String messageId) onSendError,
    void Function() onDeletedMessages,
    RemoteMessageHandler onBackgroundMessage,
    RemoteMessageHandler onLaunch, // deprecate
    RemoteMessageHandler onResume, // deprecate
  }) {
    return FirebaseMessagingPlatform.configure(
      onMessage: onMessage,
      onMessageSent: onMessageSent,
      onNotificationOpenedApp: onNotificationOpenedApp,
      onSendError: onSendError,
      onDeletedMessages: onDeletedMessages,
      onBackgroundMessage: onBackgroundMessage,
    );
  }

  // ignore: public_member_api_docs
  @Deprecated(
      "Constructing Messaging is deprecated, use 'FirebaseMessaging.instance' instead")
  factory FirebaseMessaging() {
    return FirebaseMessaging.instance;
  }

  /// Returns whether messaging auto initialization is enabled or disabled for the device.
  bool get isAutoInitEnabled {
    return _delegate.isAutoInitEnabled;
  }

  /// If the application has been opened from a terminated state via a [Notification],
  /// it will be returned, otherwise it will be `null`.
  ///
  /// Once the [Notification] has been consumed, it will be removed and further
  /// calls to [initialNotification] will be `null`.
  ///
  /// This should be used to determine whether specific notification interaction
  /// should open the app with a specific purpose (e.g. opening a chat message,
  /// specific screen etc).
  Notification get initialNotification {
    return _delegate.initialNotification;
  }

  /// Removes access to an FCM token previously authorized by it's scope.
  ///
  /// Messages sent by the server to this token will fail.
  /// authorizedEntity The messaging sender ID. In most cases this will be the current default app.
  /// scope The scope to assign when token will be deleted.
  Future<void> deleteToken({
    String authorizedEntity,
    String scope,
  }) {
    return _delegate.deleteToken(
      authorizedEntity: authorizedEntity ?? app.options.messagingSenderId,
      scope: scope ?? 'FCM',
    );
  }

  /// On iOS, it is possible to get the users APNs token. This may be required
  /// if you want to send messages to your iOS devices without using the FCM service.
  Future<String> getAPNSToken() {
    return _delegate.getAPNSToken();
  }

  /// Returns an FCM token for this device.
  ///
  /// Optionally you can specify a custom authorized entity or scope to tailor
  /// tokens to your own use-case.
  Future<String> getToken({
    String authorizedEntity,
    String scope,
    String vapidKey,
  }) {
    return _delegate.getToken(
      authorizedEntity: authorizedEntity ?? app.options.messagingSenderId,
      scope: scope ?? 'FCM',
      vapidKey: vapidKey,
    );
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return _delegate.onTokenRefresh;
  }

  /// Returns the current [NotificationSettings].
  ///
  /// To request permissions, call [requestPermission].
  Future<NotificationSettings> getNotificationSettings() {
    return _delegate.getNotificationSettings();
  }

  /// Prompts the user for notification permissions.
  ///
  /// On iOS, a dialog is shown requesting the users permission.
  /// If [provisional] is set to `true`, silent notification permissions will be
  /// automatically granted. When notifications are delivered to the device, the
  /// user will be presented with an option to disable notifications, keep receiving
  /// them silently or enable prominent notifications.
  ///
  /// On Android, is it not required to call this method. If called however,
  /// a [NotificationSettings] class will be returned with
  /// [NotificationSettings.authorizationStatus] returning
  /// [AuthorizationStatus.authorized].
  ///
  /// On Web, a popup requesting the users permission is shown using the native
  /// browser API.
  Future<NotificationSettings> requestPermission({
    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS only.
    bool badge = true,

    /// Request permission to display notifications in a CarPlay environment.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool carPlay = false,

    /// Request permission for critical alerts. Defaults to `false`.
    ///
    /// Note; your application must explicitly state reasoning for enabling
    /// crticial alerts during the App Store review process or your may be
    /// rejected.
    ///
    /// iOS only.
    bool criticalAlert = false,

    /// Request permission to provisionally create non-interrupting notifications.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool provisional = false,

    /// Request permission to play sounds. Defaults to `true`.
    ///
    /// iOS only.
    bool sound = true,
  }) {
    return _delegate.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );
  }

  /// Prompts the user for notification permissions.
  ///
  /// On iOS, a dialog is shown requesting the users permission.
  ///
  /// On Android, permissions are not required and `true` is returned.
  ///
  /// On Web, a popup requesting the users permission is shown using the native
  /// browser API.
  @Deprecated(
      "requestNotificationPermissions() is deprecated in favor of requestPermission()")
  Future<bool> requestNotificationPermissions(
      [IosNotificationSettings iosSettings]) async {
    iosSettings ??= const IosNotificationSettings();
    AuthorizationStatus status = (await requestPermission(
      sound: iosSettings.sound,
      alert: iosSettings.alert,
      badge: iosSettings.badge,
      provisional: iosSettings.provisional,
    ))
        .authorizationStatus;

    return status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
  }

  /// Send a new [RemoteMessage] to the FCM server.
  Future<void> sendMessage({
    String senderId,
    Map<String, String> data,
    String collapseKey,
    String messageId,
    String messageType,
    int ttl,
  }) {
    if (ttl != null) {
      assert(ttl >= 0);
    }
    return _delegate.sendMessage(
      senderId:
          senderId ?? '${app.options.messagingSenderId}@fcm.googleapis.com',
      data: data,
      collapseKey: collapseKey,
      messageId: messageId,
      messageType: messageType,
      ttl: ttl,
    );
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    assert(enabled != null);
    return _delegate.setAutoInitEnabled(enabled);
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    _assertTopicName(topic);
    return _delegate.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    _assertTopicName(topic);
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
  @Deprecated(
      "autoInitEnabled() is deprecated. Use [isAutoInitEnabled] instead")
  Future<bool> autoInitEnabled() async {
    return isAutoInitEnabled;
  }
}

_assertTopicName(String topic) {
  assert(topic != null);

  bool isValidTopic = RegExp(r"^[a-zA-Z0-9-_.~%]{1,900}$").hasMatch(topic);

  assert(isValidTopic);
}
