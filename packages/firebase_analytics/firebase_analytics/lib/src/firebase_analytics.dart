// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../firebase_analytics.dart';

/// Firebase Analytics API.
class FirebaseAnalytics extends FirebasePluginPlatform {
  FirebaseAnalytics._({
    required this.app,
    this.webOptions,
  }) : super(app.name, 'plugins.flutter.io/firebase_analytics');

  static Map<String, FirebaseAnalytics> _firebaseAnalyticsInstances = {};

  final Map<String, dynamic>? webOptions;

  // Cached and lazily loaded instance of [FirebaseAnalyticsPlatform] to avoid
  // creating a [MethodChannelFirebaseAnalytics] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseAnalyticsPlatform? _delegatePackingProperty;

  FirebaseAnalyticsPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseAnalyticsPlatform.instanceFor(app: app, webOptions: webOptions);
  }

  /// Returns an instance using a specified [FirebaseApp].
  ///
  /// Note; multi-app support is only supported on web.
  factory FirebaseAnalytics.instanceFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) {
    if (kIsWeb || app.name == defaultFirebaseAppName) {
      return _firebaseAnalyticsInstances.putIfAbsent(app.name, () {
        return FirebaseAnalytics._(app: app, webOptions: webOptions);
      });
    }

    throw PlatformException(
      code: 'default-app',
      message: 'Analytics has multi-app support for web only.',
    );
  }

  /// The [FirebaseApp] for this current [FirebaseAnalytics] instance.
  FirebaseApp app;

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseAnalytics get instance {
    FirebaseApp defaultAppInstance = Firebase.app();
    return FirebaseAnalytics.instanceFor(app: defaultAppInstance);
  }

  Future<bool> isSupported() {
    return _delegate.isSupported();
  }

  /// Retrieves the app instance id from the service, or null if consent has
  /// been denied.
  Future<String?> get appInstanceId {
    return _delegate.getAppInstanceId();
  }

  /// Retrieves the session id from the client. Returns null if
  /// analyticsStorageConsentGranted is false or session is expired.
  Future<int?> getSessionId() {
    return _delegate.getSessionId();
  }

  /// Logs a custom Flutter Analytics event with the given [name] and event
  /// [parameters].
  ///
  /// The event can have up to 25 [parameters]. Events with the same [name] must
  /// have the same [parameters]. Up to 500 event names are supported.
  ///
  /// The [name] of the event. Should contain 1 to 40 alphanumeric characters or
  /// underscores. The name must start with an alphabetic character. Some event
  /// names are reserved. See [FirebaseAnalytics.Event][1] for the list of
  /// reserved event names. The "firebase_", "google_" and "ga_" prefixes are
  /// reserved and should not be used. Note that event names are case-sensitive
  /// and that logging two events whose names differ only in case will result in
  /// two distinct events.
  ///
  /// The map of event [parameters]. Passing null indicates that the event has
  /// no parameters. Parameter names can be up to 40 characters long and must
  /// start with an alphabetic character and contain only alphanumeric
  /// characters and underscores. String, long and double param types are
  /// supported. String parameter values can be up to 100 characters long. The
  /// "firebase_", "google_" and "ga_" prefixes are reserved and should not be
  /// used for parameter names.
  ///
  /// See also:
  ///
  ///   * https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
  ///   * https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
  ///
  /// [1]: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {
    _logEventNameValidation(name);

    _assertParameterTypesAreCorrect(parameters);

    await _delegate.logEvent(
      name: name,
      parameters: parameters,
      callOptions: callOptions,
    );
  }

  /// Sets the applicable end user consent state.
  /// By default, no consent mode values are set.
  ///
  /// - [adStorageConsentGranted] - Enables storage, such as cookies, related to advertising. (Platform: Android, iOS, Web)
  /// - [analyticsStorageConsentGranted] - Enables storage, such as cookies, related to analytics (for example, visit duration). (Platform: Android, iOS, Web)
  /// - [adPersonalizationSignalsConsentGranted] - Sets consent for personalized advertising. (Platform: Android, iOS, Web)
  /// - [adUserDataConsentGranted] - Sets consent for sending user data to Google for advertising purposes. (Platform: Android, iOS, Web)
  /// - [functionalityStorageConsentGranted] - Enables storage that supports the functionality of the website or app such as language settings. (Platform: Web)
  /// - [personalizationStorageConsentGranted] - Enables storage related to personalization such as video recommendations. (Platform: Web)
  /// - [securityStorageConsentGranted] - Enables storage related to security such as authentication functionality, fraud prevention, and other user protection. (Platform: Web)
  ///
  /// Default consents can be set according to the platform:
  /// - [iOS][1]
  /// - [Android][2]
  /// - [Web][3]
  ///
  /// [1]: https://developers.google.com/tag-platform/security/guides/app-consent?platform=ios#default-consent
  /// [2]: https://developers.google.com/tag-platform/security/guides/app-consent?platform=android#default-consent
  /// [3]: https://firebase.google.com/docs/reference/js/analytics.md#setconsent_1697027
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
    bool? adUserDataConsentGranted,
    bool? functionalityStorageConsentGranted,
    bool? personalizationStorageConsentGranted,
    bool? securityStorageConsentGranted,
  }) async {
    await _delegate.setConsent(
      adStorageConsentGranted: adStorageConsentGranted,
      analyticsStorageConsentGranted: analyticsStorageConsentGranted,
      adPersonalizationSignalsConsentGranted:
          adPersonalizationSignalsConsentGranted,
      adUserDataConsentGranted: adUserDataConsentGranted,
      functionalityStorageConsentGranted: functionalityStorageConsentGranted,
      personalizationStorageConsentGranted:
          personalizationStorageConsentGranted,
      securityStorageConsentGranted: securityStorageConsentGranted,
    );
  }

  /// Adds parameters that will be set on every event logged from the SDK, including automatic ones.
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) async {
    defaultParameters?.forEach((key, value) {
      assert(
        value is String || value is num || value == null,
        "'string', 'null' or 'number' must be set as the value of the parameter: $key",
      );
    });
    await _delegate.setDefaultEventParameters(defaultParameters);
  }

  /// Sets whether analytics collection is enabled for this app on this device.
  ///
  /// This setting is persisted across app sessions. By default it is enabled.
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _delegate.setAnalyticsCollectionEnabled(enabled);
  }

  /// Sets the user ID property.
  ///
  /// Setting a null [id] removes the user id.
  ///
  /// This feature must be used in accordance with [Google's Privacy Policy][1].
  ///
  /// [1]: https://www.google.com/policies/privacy/
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    await _delegate.setUserId(id: id, callOptions: callOptions);
  }

  static final RegExp _nonAlphaNumeric = RegExp('[^a-zA-Z0-9_]');
  static final RegExp _alpha = RegExp('[a-zA-Z]');

  /// Sets a user property to a given value.
  ///
  /// Up to 25 user property names are supported. Once set, user property
  /// values persist throughout the app lifecycle and across sessions.
  ///
  /// [name] is the name of the user property to set. Should contain 1 to 24
  /// alphanumeric characters or underscores and must start with an alphabetic
  /// character. The "firebase_" prefix is reserved and should not be used for
  /// user property names.
  ///
  /// Setting a null [value] removes the user property.
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (name.isEmpty ||
        name.length > 24 ||
        name.indexOf(_alpha) != 0 ||
        name.contains(_nonAlphaNumeric)) {
      throw ArgumentError.value(
        name,
        'name',
        'must contain 1 to 24 alphanumeric characters.',
      );
    }

    if (name.startsWith('firebase_')) {
      throw ArgumentError.value(name, 'name', '"firebase_" prefix is reserved');
    }

    await _delegate.setUserProperty(
      name: name,
      value: value,
      callOptions: callOptions,
    );
  }

  /// Clears all analytics data for this app from the device and resets the app instance id.
  Future<void> resetAnalyticsData() async {
    await _delegate.resetAnalyticsData();
  }

  /// Logs the standard `add_payment_info` event.
  ///
  /// This event signifies that a user has submitted their payment information
  /// to your app.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#ADD_PAYMENT_INFO
  Future<void> logAddPaymentInfo({
    String? coupon,
    String? currency,
    String? paymentType,
    double? value,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'add_payment_info',
      parameters: filterOutNulls({
        _COUPON: coupon,
        _CURRENCY: currency,
        _PAYMENT_TYPE: paymentType,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `add_shipping_info` event.
  ///
  /// This event signifies that a user has submitted their shipping information
  /// to your app.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#ADD_PAYMENT_INFO
  Future<void> logAddShippingInfo({
    String? coupon,
    String? currency,
    double? value,
    String? shippingTier,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'add_shipping_info',
      parameters: filterOutNulls({
        _COUPON: coupon,
        _CURRENCY: currency,
        _SHIPPING_TIER: shippingTier,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `add_to_cart` event.
  ///
  /// This event signifies that an item was added to a cart for purchase. Note: If you supply the
  /// [value] parameter, you must also supply the [currency] parameter so that
  /// revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#ADD_TO_CART
  Future<void> logAddToCart({
    List<AnalyticsEventItem>? items,
    double? value,
    String? currency,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'add_to_cart',
      parameters: filterOutNulls(<String, Object?>{
        _ITEMS: _marshalItems(items),
        _VALUE: value,
        _CURRENCY: currency,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `add_to_wishlist` event.
  ///
  /// This event signifies that an item was added to a wishlist. Use this event
  /// to identify popular gift items in your app. Note: If you supply the
  /// [value] parameter, you must also supply the [currency] parameter so that
  /// revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#ADD_TO_WISHLIST
  Future<void> logAddToWishlist({
    List<AnalyticsEventItem>? items,
    double? value,
    String? currency,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'add_to_wishlist',
      parameters: filterOutNulls(<String, Object?>{
        _ITEMS: _marshalItems(items),
        _VALUE: value,
        _CURRENCY: currency,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `ad_impression` event.
  ///
  /// This event signifies when a user sees an ad impression. Note: If you supply
  /// the [value] parameter, you must also supply the [currency] parameter so that
  /// revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#AD_IMPRESSION
  Future<void> logAdImpression({
    String? adPlatform,
    String? adSource,
    String? adFormat,
    String? adUnitName,
    double? value,
    String? currency,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'ad_impression',
      parameters: filterOutNulls(<String, Object?>{
        _AD_PLATFORM: adPlatform,
        _AD_SOURCE: adSource,
        _AD_FORMAT: adFormat,
        _AD_UNIT_NAME: adUnitName,
        _VALUE: value,
        _CURRENCY: currency,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `app_open` event.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#APP_OPEN
  Future<void> logAppOpen({
    AnalyticsCallOptions? callOptions,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'app_open',
      parameters: parameters,
      callOptions: callOptions,
    );
  }

  /// Logs the standard `begin_checkout` event.
  ///
  /// This event signifies that a user has begun the process of checking out.
  /// Note: If you supply the [value] parameter, you must also supply the [currency]
  /// parameter so that revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#BEGIN_CHECKOUT
  Future<void> logBeginCheckout({
    double? value,
    String? currency,
    List<AnalyticsEventItem>? items,
    String? coupon,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'begin_checkout',
      parameters: filterOutNulls(<String, Object?>{
        _VALUE: value,
        _CURRENCY: currency,
        _ITEMS: _marshalItems(items),
        _COUPON: coupon,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `campaign_details` event.
  ///
  /// Log this event to supply the referral details of a re-engagement campaign.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#CAMPAIGN_DETAILS
  Future<void> logCampaignDetails({
    required String source,
    required String medium,
    required String campaign,
    String? term,
    String? content,
    String? aclid,
    String? cp1,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'campaign_details',
      parameters: filterOutNulls(<String, Object?>{
        _SOURCE: source,
        _MEDIUM: medium,
        _CAMPAIGN: campaign,
        _TERM: term,
        _CONTENT: content,
        _ACLID: aclid,
        _CP1: cp1,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `earn_virtual_currency` event.
  ///
  /// This event tracks the awarding of virtual currency in your app. Log this
  /// along with [logSpendVirtualCurrency] to better understand your virtual
  /// economy.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#EARN_VIRTUAL_CURRENCY
  Future<void> logEarnVirtualCurrency({
    required String virtualCurrencyName,
    required num value,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'earn_virtual_currency',
      parameters: filterOutNulls(<String, Object?>{
        _VIRTUAL_CURRENCY_NAME: virtualCurrencyName,
        _VALUE: value,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `generate_lead` event.
  ///
  /// Log this event when a lead has been generated in the app to understand
  /// the efficacy of your install and re-engagement campaigns. Note: If you
  /// supply the [value] parameter, you must also supply the [currency]
  /// parameter so that revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#GENERATE_LEAD
  Future<void> logGenerateLead({
    String? currency,
    double? value,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'generate_lead',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _VALUE: value,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `join_group` event.
  ///
  /// Log this event when a user joins a group such as a guild, team or family.
  /// Use this event to analyze how popular certain groups or social features
  /// are in your app.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#JOIN_GROUP
  Future<void> logJoinGroup({
    required String groupId,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'join_group',
      parameters: filterOutNulls(<String, Object?>{
        _GROUP_ID: groupId,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `level_up` event.
  ///
  /// This event signifies that a player has leveled up in your gaming app. It
  /// can help you gauge the level distribution of your userbase and help you
  /// identify certain levels that are difficult to pass.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#LEVEL_UP
  Future<void> logLevelUp({
    required int level,
    String? character,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'level_up',
      parameters: filterOutNulls(<String, Object?>{
        _LEVEL: level,
        _CHARACTER: character,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `level_start` event.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#LEVEL_START
  Future<void> logLevelStart({
    required String levelName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'level_start',
      parameters: filterOutNulls(<String, Object?>{
        _LEVEL_NAME: levelName,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `level_end` event.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#LEVEL_END
  Future<void> logLevelEnd({
    required String levelName,
    int? success,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'level_end',
      parameters: filterOutNulls(<String, Object?>{
        _LEVEL_NAME: levelName,
        _SUCCESS: success,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `login` event.
  ///
  /// Apps with a login feature can report this event to signify that a user
  /// has logged in.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#LOGIN
  Future<void> logLogin({
    String? loginMethod,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'login',
      parameters: filterOutNulls(<String, Object?>{
        _METHOD: loginMethod,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `post_score` event.
  ///
  /// Log this event when the user posts a score in your gaming app. This event
  /// can help you understand how users are actually performing in your game
  /// and it can help you correlate high scores with certain audiences or
  /// behaviors.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#POST_SCORE
  Future<void> logPostScore({
    required int score,
    int? level,
    String? character,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'post_score',
      parameters: filterOutNulls(<String, Object?>{
        _SCORE: score,
        _LEVEL: level,
        _CHARACTER: character,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `purchase` event.
  ///
  /// This event signifies that an item(s) was purchased by a user.
  /// Note: This is different from the in-app purchase event,
  /// which is reported automatically for Google Play-based apps.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#PURCHASE
  Future<void> logPurchase({
    String? currency,
    String? coupon,
    double? value,
    List<AnalyticsEventItem>? items,
    double? tax,
    double? shipping,
    String? transactionId,
    String? affiliation,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'purchase',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _COUPON: coupon,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        _TAX: tax,
        _SHIPPING: shipping,
        _TRANSACTION_ID: transactionId,
        _AFFILIATION: affiliation,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `remove_from_cart` event.
  ///
  /// This event signifies that an item(s) was removed from a cart.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#REMOVE_FROM_CART
  Future<void> logRemoveFromCart({
    String? currency,
    double? value,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'remove_from_cart',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `screen_view` event.
  ///
  /// This event signifies a screen view. Use this when a screen transition occurs.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SCREEN_VIEW
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'screen_view',
      parameters: filterOutNulls(<String, Object?>{
        _SCREEN_CLASS: screenClass,
        _SCREEN_NAME: screenName,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `select_item` event.
  ///
  /// This event signifies that an item was selected by a user from a list.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SELECT_ITEM
  Future<void> logSelectItem({
    String? itemListId,
    String? itemListName,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'select_item',
      parameters: filterOutNulls(<String, Object?>{
        _ITEM_LIST_ID: itemListId,
        _ITEM_LIST_NAME: itemListName,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `select_promotion` event.
  ///
  /// This event signifies that a user has selected a promotion offer.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SELECT_PROMOTION
  Future<void> logSelectPromotion({
    String? creativeName,
    String? creativeSlot,
    List<AnalyticsEventItem>? items,
    String? locationId,
    String? promotionId,
    String? promotionName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'select_promotion',
      parameters: filterOutNulls(<String, Object?>{
        _CREATIVE_NAME: creativeName,
        _CREATIVE_SLOT: creativeSlot,
        _ITEMS: _marshalItems(items),
        _LOCATION_ID: locationId,
        _PROMOTION_ID: promotionId,
        _PROMOTION_NAME: promotionName,
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `view_cart` event.
  ///
  /// This event signifies that a user has viewed their cart. Use this to analyze your purchase funnel.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#VIEW_CART
  Future<void> logViewCart({
    String? currency,
    double? value,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'view_cart',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `search` event.
  ///
  /// Apps that support search features can use this event to contextualize
  /// search operations by supplying the appropriate, corresponding parameters.
  /// This event can help you identify the most popular content in your app.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SEARCH
  Future<void> logSearch({
    required String searchTerm,
    int? numberOfNights,
    int? numberOfRooms,
    int? numberOfPassengers,
    String? origin,
    String? destination,
    String? startDate,
    String? endDate,
    String? travelClass,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'search',
      parameters: filterOutNulls(
        <String, Object?>{
          _SEARCH_TERM: searchTerm,
          _NUMBER_OF_NIGHTS: numberOfNights,
          _NUMBER_OF_ROOMS: numberOfRooms,
          _NUMBER_OF_PASSENGERS: numberOfPassengers,
          _ORIGIN: origin,
          _DESTINATION: destination,
          _START_DATE: startDate,
          _END_DATE: endDate,
          _TRAVEL_CLASS: travelClass,
          if (parameters != null) ...parameters,
        },
      ),
      callOptions: callOptions,
    );
  }

  /// Logs the standard `select_content` event.
  ///
  /// This general purpose event signifies that a user has selected some
  /// content of a certain type in an app. The content can be any object in
  /// your app. This event can help you identify popular content and categories
  /// of content in your app.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SELECT_CONTENT
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'select_content',
      parameters: filterOutNulls(<String, Object?>{
        _CONTENT_TYPE: contentType,
        _ITEM_ID: itemId,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `share` event.
  ///
  /// Apps with social features can log the Share event to identify the most
  /// viral content.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SHARE
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'share',
      parameters: filterOutNulls(<String, Object?>{
        _CONTENT_TYPE: contentType,
        _ITEM_ID: itemId,
        _METHOD: method,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `sign_up` event.
  ///
  /// This event indicates that a user has signed up for an account in your
  /// app. The parameter signifies the method by which the user signed up. Use
  /// this event to understand the different behaviors between logged in and
  /// logged out users.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SIGN_UP
  Future<void> logSignUp({
    required String signUpMethod,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'sign_up',
      parameters: filterOutNulls(<String, Object?>{
        _METHOD: signUpMethod,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `spend_virtual_currency` event.
  ///
  /// This event tracks the sale of virtual goods in your app and can help you
  /// identify which virtual goods are the most popular objects of purchase.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#SPEND_VIRTUAL_CURRENCY
  Future<void> logSpendVirtualCurrency({
    required String itemName,
    required String virtualCurrencyName,
    required num value,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'spend_virtual_currency',
      parameters: filterOutNulls(<String, Object?>{
        _ITEM_NAME: itemName,
        _VIRTUAL_CURRENCY_NAME: virtualCurrencyName,
        _VALUE: value,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `tutorial_begin` event.
  ///
  /// This event signifies the start of the on-boarding process in your app.
  /// Use this in a funnel with [logTutorialComplete] to understand how many
  /// users complete this process and move on to the full app experience.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#TUTORIAL_BEGIN
  Future<void> logTutorialBegin({
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'tutorial_begin',
      parameters: parameters,
    );
  }

  /// Logs the standard `tutorial_complete` event.
  ///
  /// Use this event to signify the user's completion of your app's on-boarding
  /// process. Add this to a funnel with [logTutorialBegin] to gauge the
  /// completion rate of your on-boarding process.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#TUTORIAL_COMPLETE
  Future<void> logTutorialComplete({
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'tutorial_complete',
      parameters: parameters,
    );
  }

  /// Logs the standard `unlock_achievement` event with a given achievement
  /// [id].
  ///
  /// Log this event when the user has unlocked an achievement in your game.
  /// Since achievements generally represent the breadth of a gaming
  /// experience, this event can help you understand how many users are
  /// experiencing all that your game has to offer.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#UNLOCK_ACHIEVEMENT
  Future<void> logUnlockAchievement({
    required String id,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'unlock_achievement',
      parameters: filterOutNulls(<String, Object?>{
        _ACHIEVEMENT_ID: id,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `view_item` event.
  ///
  /// This event signifies that some content was shown to the user. This
  /// content may be a product, a webpage or just a simple image or text. Use
  /// the appropriate parameters to contextualize the event. Use this event to
  /// discover the most popular items viewed in your app. Note: If you supply
  /// the [value] parameter, you must also supply the [currency] parameter so
  /// that revenue metrics can be computed accurately.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#VIEW_ITEM
  Future<void> logViewItem({
    String? currency,
    double? value,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
  }) {
    _requireValueAndCurrencyTogether(value, currency);

    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'view_item',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _VALUE: value,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `view_item_list` event.
  ///
  /// Log this event when the user has been presented with a list of items of a
  /// certain category.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#VIEW_ITEM_LIST
  Future<void> logViewItemList({
    List<AnalyticsEventItem>? items,
    String? itemListId,
    String? itemListName,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'view_item_list',
      parameters: filterOutNulls(<String, Object?>{
        _ITEMS: _marshalItems(items),
        _ITEM_LIST_ID: itemListId,
        _ITEM_LIST_NAME: itemListName,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `view_promotion` event.
  ///
  /// This event signifies that a promotion was shown to a user.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#VIEW_PROMOTION
  Future<void> logViewPromotion({
    String? creativeName,
    String? creativeSlot,
    List<AnalyticsEventItem>? items,
    String? locationId,
    String? promotionId,
    String? promotionName,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'view_promotion',
      parameters: filterOutNulls(<String, Object?>{
        _CREATIVE_NAME: creativeName,
        _CREATIVE_SLOT: creativeSlot,
        _ITEMS: _marshalItems(items),
        _LOCATION_ID: locationId,
        _PROMOTION_ID: promotionId,
        _PROMOTION_NAME: promotionName,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `view_search_results` event.
  ///
  /// Log this event when the user has been presented with the results of a
  /// search.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#VIEW_SEARCH_RESULTS
  Future<void> logViewSearchResults({
    required String searchTerm,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);

    return _delegate.logEvent(
      name: 'view_search_results',
      parameters: filterOutNulls(<String, Object?>{
        _SEARCH_TERM: searchTerm,
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `refund` event.
  ///
  /// This event signifies that a refund was issued.
  ///
  /// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html#REFUND
  Future<void> logRefund({
    String? currency,
    String? coupon,
    double? value,
    double? tax,
    double? shipping,
    String? transactionId,
    String? affiliation,
    List<AnalyticsEventItem>? items,
    Map<String, Object>? parameters,
  }) {
    _assertParameterTypesAreCorrect(parameters);
    _assertItemsParameterTypesAreCorrect(items);

    return _delegate.logEvent(
      name: 'refund',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _COUPON: coupon,
        _VALUE: value,
        _TAX: tax,
        _SHIPPING: shipping,
        _TRANSACTION_ID: transactionId,
        _AFFILIATION: affiliation,
        _ITEMS: _marshalItems(items),
        if (parameters != null) ...parameters,
      }),
    );
  }

  /// Logs the standard `in_app_purchase` event.
  ///
  /// This event signifies that an item(s) was purchased by a user.
  ///
  /// This API supports manually logging in-app purchase events on iOS and Android.
  /// This is especially useful in cases where purchases happen outside the native
  /// billing systems (e.g. custom payment flows).
  Future<void> logInAppPurchase({
    String? currency,
    bool? freeTrial,
    double? price,
    bool? priceIsDiscounted,
    String? productID,
    String? productName,
    int? quantity,
    bool? subscription,
    num? value,
  }) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError('logInAppPurchase() is only supported on iOS.');
    }
    return _delegate.logEvent(
      name: 'in_app_purchase',
      parameters: filterOutNulls(<String, Object?>{
        _CURRENCY: currency,
        _FREE_TRIAL: freeTrial,
        _PRICE: price,
        _PRICE_IS_DISCOUNTED: priceIsDiscounted,
        _PRODUCT_ID: productID,
        _PRODUCT_NAME: productName,
        _QUANTITY: quantity,
        _SUBSCRIPTION: subscription,
        _VALUE: value,
      }),
    );
  }

  /// Sets the duration of inactivity that terminates the current session.
  ///
  /// The default value is 1800000 milliseconds (30 minutes).
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    await _delegate.setSessionTimeoutDuration(timeout);
  }

  /// Initiates on-device conversion measurement given a user email address.
  /// Requires Firebase iOS SDK 12.0.0+ with FirebaseAnalytics dependency, otherwise it is a no-op.
  ///
  /// Only available on iOS.
  Future<void> initiateOnDeviceConversionMeasurementWithEmailAddress(
    String emailAddress,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError(
        'initiateOnDeviceConversionMeasurementWithEmailAddress() is only supported on iOS.',
      );
    }
    await _delegate.initiateOnDeviceConversionMeasurement(
      emailAddress: emailAddress,
    );
  }

  /// Initiates on-device conversion measurement given a user phone number in E.164 format.
  /// Requires Firebase iOS SDK 12.0.0+ with FirebaseAnalytics dependency, otherwise it is a no-op.
  ///
  /// Only available on iOS.
  Future<void> initiateOnDeviceConversionMeasurementWithPhoneNumber(
    String phoneNumber,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError(
        'initiateOnDeviceConversionMeasurementWithPhoneNumber() is only supported on iOS.',
      );
    }
    await _delegate.initiateOnDeviceConversionMeasurement(
      phoneNumber: phoneNumber,
    );
  }

  /// Initiates on-device conversion measurement given a sha256-hashed, UTF8 encoded, user email address.
  /// Requires Firebase iOS SDK 12.0.0+ with FirebaseAnalytics dependency, otherwise it is a no-op.
  ///
  /// Only available on iOS.
  Future<void> initiateOnDeviceConversionMeasurementWithHashedEmailAddress(
    String hashedEmailAddress,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError(
        'initiateOnDeviceConversionMeasurementWithHashedEmailAddress() is only supported on iOS.',
      );
    }
    await _delegate.initiateOnDeviceConversionMeasurement(
      hashedEmailAddress: hashedEmailAddress,
    );
  }

  /// Initiates on-device conversion measurement given a sha256-hashed, UTF8 encoded, phone number in E.164 format.
  /// Requires Firebase iOS SDK 12.0.0+ with FirebaseAnalytics dependency, otherwise it is a no-op.
  ///
  /// Only available on iOS.
  Future<void> initiateOnDeviceConversionMeasurementWithHashedPhoneNumber(
    String hashedPhoneNumber,
  ) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnimplementedError(
        'initiateOnDeviceConversionMeasurementWithHashedPhoneNumber() is only supported on iOS.',
      );
    }
    await _delegate.initiateOnDeviceConversionMeasurement(
      hashedPhoneNumber: hashedPhoneNumber,
    );
  }
}

/// Creates a new map containing all of the key/value pairs from [parameters]
/// except those whose value is `null`.
@visibleForTesting
Map<String, Object> filterOutNulls(Map<String, Object?> parameters) {
  final Map<String, Object> filtered = <String, Object>{};
  parameters.forEach((String key, Object? value) {
    if (value != null) {
      filtered[key] = value;
    }
  });
  return filtered;
}

@visibleForTesting
const String valueAndCurrencyMustBeTogetherError = 'If you supply the "value" '
    'parameter, you must also supply the "currency" parameter.';

void _requireValueAndCurrencyTogether(double? value, String? currency) {
  if (value != null && currency == null) {
    throw ArgumentError(valueAndCurrencyMustBeTogetherError);
  }
}

void _logEventNameValidation(String name) {
  if (_reservedEventNames.contains(name)) {
    throw ArgumentError.value(
      name,
      'name',
      'Event name is reserved and cannot be used',
    );
  }

  const String kReservedPrefix = 'firebase_';

  if (name.startsWith(kReservedPrefix)) {
    throw ArgumentError.value(
      name,
      'name',
      'Prefix "$kReservedPrefix" is reserved and cannot be used.',
    );
  }
}

List<Map<String, dynamic>>? _marshalItems(List<AnalyticsEventItem>? items) {
  if (items == null) return null;

  return items.map((AnalyticsEventItem item) => item.asMap()).toList();
}

void _assertParameterTypesAreCorrect(
  Map<String, Object>? parameters,
) =>
    parameters?.forEach((key, value) {
      assert(
        value is String || value is num,
        "'string' OR 'number' must be set as the value of the parameter: $key. $value found instead",
      );
    });

void _assertItemsParameterTypesAreCorrect(List<AnalyticsEventItem>? items) =>
    items?.forEach((item) {
      _assertParameterTypesAreCorrect(item.parameters);
    });

/// Reserved event names that cannot be used.
///
/// See: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event.html
const List<String> _reservedEventNames = <String>[
  'ad_activeview',
  'ad_click',
  'ad_exposure',
  'ad_query',
  'ad_reward',
  'adunit_exposure',
  'app_background',
  'app_clear_data',
  'app_exception',
  'app_remove',
  'app_store_refund',
  'app_store_subscription_cancel',
  'app_store_subscription_convert',
  'app_store_subscription_renew',
  'app_uninstall',
  'app_update',
  'app_upgrade',
  'dynamic_link_app_open',
  'dynamic_link_app_update',
  'dynamic_link_first_open',
  'error',
  'first_open',
  'first_visit',
  'in_app_purchase',
  'notification_dismiss',
  'notification_foreground',
  'notification_open',
  'notification_receive',
  'os_update',
  'session_start',
  'session_start_with_rollout',
  'user_engagement',
];

// The following constants are defined in:
//
// https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Param.html

/// Game achievement ID.
const String _ACHIEVEMENT_ID = 'achievement_id';

/// `CAMPAIGN_DETAILS` click ID.
const String _ACLID = 'aclid';

/// `CAMPAIGN_DETAILS` name; used for keyword analysis to identify a specific
/// product promotion or strategic campaign.
const String _CAMPAIGN = 'campaign';

/// Character used in game.
const String _CHARACTER = 'character';

/// `CAMPAIGN_DETAILS` content; used for A/B testing and content-targeted ads to
/// differentiate ads or links that point to the same URL.
const String _CONTENT = 'content';

/// Type of content selected.
const String _CONTENT_TYPE = 'content_type';

/// Coupon code for a purchasable item.
const String _COUPON = 'coupon';

/// `CAMPAIGN_DETAILS` custom parameter.
const String _CP1 = 'cp1';

/// Purchase currency in 3 letter ISO_4217 format.
const String _CURRENCY = 'currency';

/// Flight or Travel destination.
const String _DESTINATION = 'destination';

/// The arrival date, check-out date, or rental end date for the item.
const String _END_DATE = 'end_date';

/// Group/clan/guild id.
const String _GROUP_ID = 'group_id';

const String _ITEMS = 'items';

/// Item ID.
const String _ITEM_ID = 'item_id';

/// The location associated with the event.
const String _LOCATION_ID = 'location_id';

/// The ID of the list in which the item was presented to the user
const String _ITEM_LIST_ID = 'item_list_id';

/// The ID of the list in which the item was presented to the user
const String _ITEM_LIST_NAME = 'item_list_name';

/// The name of a creative used in a promotional spot.
const String _CREATIVE_NAME = 'creative_name';

/// The name of a creative slot.
const String _CREATIVE_SLOT = 'creative_slot';

/// The store or affiliation from which this transaction occurred.
const String _AFFILIATION = 'affiliation';

/// The index of an item in a list.
// const String _INDEX = 'index';

/// Item name (String).
const String _ITEM_NAME = 'item_name';

/// Level in game (long).
const String _LEVEL = 'level';

/// The name of a level in a game (String).
const String _LEVEL_NAME = 'level_name';

/// The result of an operation (long).
const String _SUCCESS = 'success';

/// `CAMPAIGN_DETAILS` medium; used to identify a medium such as email or
/// cost-per-click (cpc).
const String _MEDIUM = 'medium';

/// Number of nights staying at hotel (long).
const String _NUMBER_OF_NIGHTS = 'number_of_nights';

/// Number of passengers traveling (long).
const String _NUMBER_OF_PASSENGERS = 'number_of_passengers';

const String _PAYMENT_TYPE = 'payment_type';

/// Number of rooms for travel events (long).
const String _NUMBER_OF_ROOMS = 'number_of_rooms';

/// Flight or Travel origin.
const String _ORIGIN = 'origin';

/// Score in game (long).
const String _SCORE = 'score';

/// The search string/keywords used.
const String _SEARCH_TERM = 'search_term';

/// Shipping cost (double).
const String _SHIPPING = 'shipping';

/// Shipping tier (string).
const String _SHIPPING_TIER = 'shipping_tier';

/// A particular approach used in an operation; for example, "facebook" or
/// "email" in the context of a sign_up or login event.
const String _METHOD = 'method';

/// `CAMPAIGN_DETAILS` source; used to identify a search engine, newsletter, or
/// other source.
const String _SOURCE = 'source';

/// The departure date, check-in date, or rental start date for the item.
const String _START_DATE = 'start_date';

/// Tax amount (double).
const String _TAX = 'tax';

/// `CAMPAIGN_DETAILS` term; used with paid search to supply the keywords for
/// ads.
const String _TERM = 'term';

/// A single ID for a ecommerce group transaction.
const String _TRANSACTION_ID = 'transaction_id';

/// Travel class.
const String _TRAVEL_CLASS = 'travel_class';

/// A context-specific numeric value which is accumulated automatically for
/// each event type.
const String _VALUE = 'value';

/// Name of virtual currency type.
const String _VIRTUAL_CURRENCY_NAME = 'virtual_currency_name';

/// Name of ad platform.
const String _AD_PLATFORM = 'ad_platform';

/// Name of ad source.
const String _AD_SOURCE = 'ad_source';

/// Name of ad format.
const String _AD_FORMAT = 'ad_format';

/// Name of ad unit name.
const String _AD_UNIT_NAME = 'ad_unit_name';

/// Name of screen class
const String _SCREEN_CLASS = 'screen_class';

/// Name of screen name
const String _SCREEN_NAME = 'screen_name';

/// The ID of a product promotion
const String _PROMOTION_ID = 'promotion_id';

/// The name of a product promotion
const String _PROMOTION_NAME = 'promotion_name';

/// Whether the purchase is a free trial
const String _FREE_TRIAL = 'free_trial';

/// The price of the item
const String _PRICE = 'price';

/// Whether the price is discounted
const String _PRICE_IS_DISCOUNTED = 'price_is_discounted';

/// The ID of the product
const String _PRODUCT_ID = 'product_id';

/// The name of the product
const String _PRODUCT_NAME = 'product_name';

/// The quantity of the product
const String _QUANTITY = 'quantity';

/// Whether the purchase is a subscription
const String _SUBSCRIPTION = 'subscription';
