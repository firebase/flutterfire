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

  /// Returns a Stream that is called when an incoming FCM payload is received whilst
  /// the Flutter instance is in the foreground.
  ///
  /// The Stream contains the [RemoteMessage].
  ///
  /// To handle messages whilst the app is in the background or terminated,
  /// see [onBackgroundMessage].
  static Stream<RemoteMessage> get onMessage {
    Stream<RemoteMessage> onMessageStream = FirebaseMessagingPlatform.onMessage;

    StreamController<RemoteMessage> streamController;
    streamController = StreamController<RemoteMessage>.broadcast(onListen: () {
      onMessageStream.pipe(streamController);
    });

    return streamController.stream;
  }

  /// Returns a Stream that is called when a message being sent to FCM (via [sendMessage])
  /// has successfully been sent or fails.
  ///
  /// The Stream contains a [String] representing a message ID. If sending failed,
  /// the [SentMessage] will contain an [error] property containing a [FirebaseException].
  ///
  /// See [onSendError] to handle sending failures.
  static Stream<SentMessage> get onMessageSent {
    Stream<SentMessage> onMessageSentStream =
        FirebaseMessagingPlatform.onMessageSent;

    StreamController<SentMessage> streamController;
    streamController = StreamController<SentMessage>.broadcast(onListen: () {
      onMessageSentStream.pipe(streamController);
    });

    return streamController.stream;
  }

  /// Returns a [Stream] that is called when a user presses a notification displayed
  /// via FCM.
  ///
  /// A Stream event will be sent if the app has opened from a background state
  /// (not terminated).
  ///
  /// If your app is opened via a notification whilst the app is terminated,
  /// see [initialNotification].
  static Stream<RemoteMessage> get onNotificationOpenedApp {
    Stream<RemoteMessage> onNotificationOpenedAppStream =
        FirebaseMessagingPlatform.onNotificationOpenedApp;

    StreamController<RemoteMessage> streamController;
    streamController = StreamController<RemoteMessage>.broadcast(onListen: () {
      onNotificationOpenedAppStream.pipe(streamController);
    });

    return streamController.stream;
  }

  /// Returns a Stream which is called when the FCM server deletes pending messages.
  ///
  /// This may be due to:
  ///
  /// 1.  Too many messages stored on the FCM server. This can occur when an
  /// app's servers sends many non-collapsible messages to FCM servers while
  /// the device is offline.
  ///
  /// 2. he device hasn't connected in a long time and the app server has recently
  /// (within the last 4 weeks) sent a message to the app on that device.
  static Stream<void> get onDeletedMessages {
    Stream<void> onDeletedMessagesStream =
        FirebaseMessagingPlatform.onDeletedMessages;

    StreamController<void> streamController;
    streamController = StreamController<void>.broadcast(onListen: () {
      onDeletedMessagesStream.pipe(streamController);
    });

    return streamController.stream;
  }

  /// Set a message handler function which is called when the app is in the
  /// background or terminated.
  ///
  /// This provided handler must be a top-level function and cannot be
  /// anonymous otherwise an [ArgumentError] will be thrown.
  static void onBackgroundMessage(BackgroundMessageHandler handler) {
    FirebaseMessagingPlatform.onBackgroundMessage = handler;
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

  /// On iOS, it is possible to get the users APNs token.
  ///
  /// This may be required if you want to send messages to your iOS/MacOS devices
  /// without using the FCM service.
  ///
  /// On Android & web, this returns `null`.
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
    /// critical alerts during the App Store review process or your may be
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

  /// Resets Instance ID and revokes all tokens.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging
  /// auto-init is enabled.
  ///
  /// Returns `true` if the operations executed successfully and `false` if
  /// an error occurred.
  @Deprecated('Use [deleteToken] instead.')
  Future<bool> deleteInstanceID() async {
    try {
      await deleteToken();
      return true;
    } catch (e) {
      return false;
    }
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
