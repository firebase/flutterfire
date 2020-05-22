import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

/// Web implementation for [FirebaseAnalyticsPlatform]
class FirebaseAnalyticsWeb extends FirebaseAnalyticsPlatform {
  /// Instance of Analytics from the web plugin.
  final firebase.Analytics _analytics;

  /// A constructor that allows tests to override the firebase.Analytics object.
  FirebaseAnalyticsWeb({@visibleForTesting firebase.Analytics analytics})
      : _analytics = analytics ?? firebase.analytics();

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseAnalyticsPlatform.instance = FirebaseAnalyticsWeb();
  }

  @override
  Future<void> logEvent({
    String name,
    Map<String, dynamic> parameters,
  }) {
    _analytics.logEvent(name, parameters);
    return Future<void>.value();
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    _analytics.setAnalyticsCollectionEnabled(enabled);
    return Future<void>.value();
  }

  @override
  Future<void> setUserId(String id) {
    _analytics.setUserId(id);
    return Future<void>.value();
  }

  @override
  Future<void> setCurrentScreen({
    String screenName,
    String screenClassOverride,
  }) {
    _analytics.setCurrentScreen(screenName);
    return Future<void>.value();
  }

  @override
  Future<void> setUserProperty({
    String name,
    String value,
  }) {
    _analytics.setUserProperties({name: value});
    return Future<void>.value();
  }
}
