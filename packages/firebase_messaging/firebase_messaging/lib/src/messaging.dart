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
  FirebaseMessagingPlatform? _delegatePackingProperty;

  FirebaseMessagingPlatform get _delegate {
    return _delegatePackingProperty ??= FirebaseMessagingPlatform.instanceFor(
        app: app, pluginConstants: pluginConstants);
  }

  /// The [FirebaseApp] for this current [FirebaseMessaging] instance.
  FirebaseApp app;

  FirebaseMessaging._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_messaging');

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseMessaging get instance {
    return FirebaseMessaging._(app: Firebase.app());
  }

  //  Messaging does not yet support multiple Firebase Apps. Default app only.
  /// Returns an instance using a specified [FirebaseApp]
  ///
  /// If [app] is not provided, the default Firebase app will be used.
  // static FirebaseMessaging instanceFor({
  //   FirebaseApp app,
  // }) {
  //   app ??= Firebase.app();
  //   assert(app != null);
  //
  //   String key = '${app.name}';
  //   if (_cachedInstances.containsKey(key)) {
  //     return _cachedInstances[key];
  //   }
  //
  //   FirebaseMessaging newInstance = FirebaseMessaging._(app: app);
  //   _cachedInstances[key] = newInstance;
  //
  //   return newInstance;
  // }
  //
  // static final Map<String, FirebaseMessaging> _cachedInstances = {};

  static final _onMessageController =
      StreamController<RemoteMessage>.broadcast(onListen: () {
    Stream<RemoteMessage> onMessageStream =
        FirebaseMessagingPlatform.onMessage.stream;

    onMessageStream.pipe(_onMessageController);
  });

  /// Returns a Stream that is called when an incoming FCM payload is received whilst
  /// the Flutter instance is in the foreground.
  ///
  /// The Stream contains the [RemoteMessage].
  ///
  /// To handle messages whilst the app is in the background or terminated,
  /// see [onBackgroundMessage].
  static Stream<RemoteMessage> get onMessage => _onMessageController.stream;

  static final _onMessageOpenedAppController =
      StreamController<RemoteMessage>.broadcast(onListen: () {
    Stream<RemoteMessage> onMessageOpenedAppStream =
        FirebaseMessagingPlatform.onMessageOpenedApp.stream;

    onMessageOpenedAppStream.pipe(_onMessageOpenedAppController);
  });

  /// Returns a [Stream] that is called when a user presses a notification message displayed
  /// via FCM.
  ///
  /// A Stream event will be sent if the app has opened from a background state
  /// (not terminated).
  ///
  /// If your app is opened via a notification whilst the app is terminated,
  /// see [getInitialMessage].
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  // ignore: use_setters_to_change_properties
  /// Set a message handler function which is called when the app is in the
  /// background or terminated.
  ///
  /// This provided handler must be a top-level function and cannot be
  /// anonymous otherwise an [ArgumentError] will be thrown.
  static void onBackgroundMessage(BackgroundMessageHandler handler) {
    FirebaseMessagingPlatform.onBackgroundMessage = handler;
  }

  /// Returns whether messaging auto initialization is enabled or disabled for the device.
  bool get isAutoInitEnabled {
    return _delegate.isAutoInitEnabled;
  }

  /// If the application has been opened from a terminated state via a [RemoteMessage]
  /// (containing a [Notification]), it will be returned, otherwise it will be `null`.
  ///
  /// Once the [RemoteMesage] has been consumed, it will be removed and further
  /// calls to [getInitialMessage] will be `null`.
  ///
  /// This should be used to determine whether specific notification interaction
  /// should open the app with a specific purpose (e.g. opening a chat message,
  /// specific screen etc).
  Future<RemoteMessage?> getInitialMessage() {
    return _delegate.getInitialMessage();
  }

  /// Removes access to an FCM token previously authorized with optional [senderId].
  ///
  /// Messages sent by the server to this token will fail.
  Future<void> deleteToken({String? senderId}) {
    return _delegate.deleteToken(senderId: senderId);
  }

  /// On iOS/MacOS, it is possible to get the users APNs token.
  ///
  /// This may be required if you want to send messages to your iOS/MacOS devices
  /// without using the FCM service.
  ///
  /// On Android & web, this returns `null`.
  Future<String?> getAPNSToken() {
    return _delegate.getAPNSToken();
  }

  /// Returns the default FCM token for this device and optionally a [senderId].
  Future<String?> getToken({
    String? vapidKey,
  }) {
    return _delegate.getToken(
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
  ///  - On iOS, a dialog is shown requesting the users permission.
  ///  - On macOS, a notification will appear asking to grant permission.
  ///  - On Android, is it not required to call this method. If called however,
  ///    a [NotificationSettings] class will be returned with
  ///    [NotificationSettings.authorizationStatus] returning
  ///    [AuthorizationStatus.authorized].
  ///  - On Web, a popup requesting the users permission is shown using the native browser API.
  ///
  /// Note that on iOS, if [provisional] is set to `true`, silent notification permissions will be
  /// automatically granted. When notifications are delivered to the device, the
  /// user will be presented with an option to disable notifications, keep receiving
  /// them silently or enable prominent notifications.
  Future<NotificationSettings> requestPermission({
    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS/macOS only.
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
    /// iOS/macOS only.
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

  /// Send a new [RemoteMessage] to the FCM server. Android only.
  Future<void> sendMessage({
    String? to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  }) {
    if (ttl != null) {
      assert(ttl >= 0);
    }
    return _delegate.sendMessage(
      to: to ?? '${app.options.messagingSenderId}@fcm.googleapis.com',
      data: data,
      collapseKey: collapseKey,
      messageId: messageId,
      messageType: messageType,
      ttl: ttl,
    );
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    return _delegate.setAutoInitEnabled(enabled);
  }

  /// Sets the presentation options for Apple notifications when received in
  /// the foreground.
  ///
  /// By default, on Apple devices notification messages are only shown when
  /// the application is in the background or terminated. Calling this method
  /// updates these options to allow customizing notification presentation behaviour whilst
  /// the application is in the foreground.
  ///
  /// Important: The requested permissions and those set by the user take priority
  /// over these settings.
  ///
  /// - [alert] Causes a notification message to display in the foreground, overlaying
  ///   the current application (heads up mode).
  /// - [badge] The application badge count will be updated if the application is
  ///   in the foreground.
  /// - [sound] The device will trigger a sound if the application is in the foreground.
  ///
  /// If all arguments are `false` or are omitted, a notification will not be displayed in the
  /// foreground, however you will still receive events relating to the notification.
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = false,
    bool badge = false,
    bool sound = false,
  }) {
    return _delegate.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// `[a-zA-Z0-9-_.~%]{1,900}`.
  Future<void> subscribeToTopic(String topic) {
    _assertTopicName(topic);
    return _delegate.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    _assertTopicName(topic);
    return _delegate.unsubscribeFromTopic(topic);
  }
}

void _assertTopicName(String topic) {
  bool isValidTopic = RegExp(r'^[a-zA-Z0-9-_.~%]{1,900}$').hasMatch(topic);
  assert(isValidTopic);
}
