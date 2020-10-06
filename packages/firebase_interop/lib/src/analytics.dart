import 'interop/analytics_interop.dart' as analytics_interop;
import 'js.dart';
import 'utils.dart';

class Analytics extends JsObjectWrapper<analytics_interop.AnalyticsJsImpl> {
  static final _expando = Expando<Analytics>();

  static Analytics getInstance(analytics_interop.AnalyticsJsImpl jsObject) {
    if (jsObject == null) {
      return null;
    }
    return _expando[jsObject] ??= Analytics._fromJsObject(jsObject);
  }

  Analytics._fromJsObject(analytics_interop.AnalyticsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  void logEvent(String eventName, Map<dynamic, dynamic> eventParams,
      [AnalyticsCallOptions options]) {
    if (options != null) {
      jsObject.logEvent(eventName, jsify(eventParams), options.jsObject);
    } else {
      jsObject.logEvent(eventName, jsify(eventParams));
    }
  }

  void setAnalyticsCollectionEnabled(bool enabled) {
    jsObject.setAnalyticsCollectionEnabled(enabled);
  }

  void setCurrentScreen(String screenName, [AnalyticsCallOptions options]) {
    if (options != null) {
      jsObject.setCurrentScreen(screenName, options.jsObject);
    } else {
      jsObject.setCurrentScreen(screenName);
    }
  }

  void setUserId(String id, [AnalyticsCallOptions options]) {
    if (options != null) {
      jsObject.setUserId(id, options.jsObject);
    } else {
      jsObject.setUserId(id);
    }
  }

  void setUserProperties(Map<String, String> properties,
      [AnalyticsCallOptions options]) {
    if (options != null) {
      jsObject.setUserProperties(jsify(properties), options.jsObject);
    } else {
      jsObject.setUserProperties(jsify(properties));
    }
  }
}

class AnalyticsCallOptions
    extends JsObjectWrapper<analytics_interop.AnalyticsCallOptionsJsImpl> {
  AnalyticsCallOptions._fromJsObject(
      analytics_interop.AnalyticsCallOptionsJsImpl jsObject)
      : super.fromJsObject(jsObject);

  bool get global => jsObject.global;
  set global(bool t) {
    jsObject.global = t;
  }
}
