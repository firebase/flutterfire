// @dart=2.9

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

/// Web implementation for [FirebaseAnalyticsPlatform]
class FirebaseAnalyticsWeb extends FirebaseAnalyticsPlatform {
  /// A constructor that allows tests to override the firebase.Analytics object.
  FirebaseAnalyticsWeb({@visibleForTesting firebase.Analytics analytics})
      : _analytics = analytics ?? firebase.analytics();

  /// Instance of Analytics from the web plugin.
  final firebase.Analytics _analytics;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAnalyticsPlatform.instance = FirebaseAnalyticsWeb();
  }

  @override
  Future<void> logEvent({
    String name,
    Map<String, dynamic> parameters,
  }) async {
    _analytics.logEvent(name, parameters);
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setUserId(String id) async {
    _analytics.setUserId(id);
  }

  @override
  Future<void> setCurrentScreen({
    String screenName,
    String screenClassOverride,
  }) async {
    _analytics.setCurrentScreen(screenName);
  }

  @override
  Future<void> setUserProperty({
    String name,
    String value,
  }) async {
    _analytics.setUserProperties({name: value});
  }
}
