// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../firebase_messaging.dart';

/// The [FirebaseMessaging] entry point.
///
/// To get a new instance, call [FirebaseMessaging.instance].
class FirebaseMessaging extends FirebasePluginPlatform {
  // Cached and lazily loaded instance of [FirebaseMessagingPlatform] to avoid
  // creating a [MethodChannelFirebaseMessaging] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseMessagingPlatform? _delegatePackingProperty;

  static Map<String, FirebaseMessaging> _firebaseMessagingInstances = {};

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
    FirebaseApp defaultAppInstance = Firebase.app();
    return FirebaseMessaging._instanceFor(app: defaultAppInstance);
  }

  //  Messaging does not yet support multiple Firebase Apps. Default app only.
  /// Returns an instance using a specified [FirebaseApp].
  factory FirebaseMessaging._instanceFor({required FirebaseApp app}) {
    return _firebaseMessagingInstances.putIfAbsent(app.name, () {
      return FirebaseMessaging._(app: app);
    });
  }

  /// Returns a Stream that is called when an incoming FCM payload is received whilst
  /// the Flutter instance is in the foreground.
  ///
  /// The Stream contains the [RemoteMessage].
  ///
  /// To handle messages whilst the app is in the background or terminated,
  /// see [onBackgroundMessage].
  static Stream<RemoteMessage> get onMessage =>
      FirebaseMessagingPlatform.onMessage.stream;

  /// Returns a [Stream] that is called when a user presses a notification message displayed
  /// via FCM.
  ///
  /// A Stream event will be sent if the app has opened from a background state
  /// (not terminated).
  ///
  /// If your app is opened via a notification whilst the app is terminated,
  /// see [getInitialMessage].
  static Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessagingPlatform.onMessageOpenedApp.stream;

  // ignore: use_setters_to_change_properties
  /// Set a message handler function which is called when the app is in the
  /// background or terminated.
  ///
  /// This provided handler must be a top-level function and cannot be
  /// anonymous otherwise an [ArgumentError] will be thrown.
  // ignore: use_setters_to_change_properties
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
  /// Once the [RemoteMessage] has been consumed, it will be removed and further
  /// calls to [getInitialMessage] will be `null`.
  ///
  /// This should be used to determine whether specific notification interaction
  /// should open the app with a specific purpose (e.g. opening a chat message,
  /// specific screen etc).
  ///
  /// on Android, if the message was received in the foreground, and the notification was
  /// pressed whilst the app is in a background/terminated state, this will return `null`.
  Future<RemoteMessage?> getInitialMessage() {
    return _delegate.getInitialMessage();
  }

  /// Removes access to an FCM token previously authorized.
  ///
  /// Messages sent by the server to this token will fail.
  Future<void> deleteToken() {
    return _delegate.deleteToken();
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

  /// Returns the default FCM token for this device.
  ///
  /// On web, a [vapidKey] is required.
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

  Future<bool> isSupported() {
    return _delegate.isSupported();
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
  ///  - On Android, a [NotificationSettings] class will be returned with the
  ///    value of [NotificationSettings.authorizationStatus] indicating whether
  ///    the app has notifications enabled or blocked in the system settings.
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

    /// Request permission for an option indicating the system should display a button for in-app notification settings.
    /// Defaults to `false`.
    ///
    /// iOS/macOS only.
    bool providesAppNotificationSettings = false,
  }) {
    return _delegate.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
      providesAppNotificationSettings: providesAppNotificationSettings,
    );
  }

  /// Send a new [RemoteMessage] to the FCM server. Android only.
  /// Firebase will decommission in June 2024: https://firebase.google.com/docs/reference/android/com/google/firebase/messaging/FirebaseMessaging#send
  @Deprecated(
      'This will be removed in a future release. Firebase will decommission in June 2024')
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

  /// Enables or disables Firebase Cloud Messaging message delivery metrics export to BigQuery for Android.
  ///
  /// On iOS, you need to follow [this guide](https://firebase.google.com/docs/cloud-messaging/understand-delivery?platform=ios#enable_delivery_data_export_for_background_notifications)
  /// in order to export metrics to BigQuery.
  /// On Web, you need to setup a [service worker](https://firebase.google.com/docs/cloud-messaging/js/client) and call `experimentalSetDeliveryMetricsExportedToBigQueryEnabled(messaging, true)`
  Future<void> setDeliveryMetricsExportToBigQuery(bool enabled) async {
    return _delegate.setDeliveryMetricsExportToBigQuery(enabled);
  }

  /// Sets the presentation options for Apple notifications when received in
  /// the foreground.
  ///
  /// By default, on Apple devices notification messages are only shown when
  /// the application is in the background or terminated. Calling this method
  /// updates these options to allow customizing notification presentation behavior whilst
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
