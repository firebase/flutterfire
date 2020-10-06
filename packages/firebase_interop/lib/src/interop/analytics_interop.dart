@JS('firebase.analytics')
library firebase.analytics_interop;

import 'package:js/js.dart';

@JS('Analytics')
abstract class AnalyticsJsImpl {
  external void logEvent(String eventName, Object eventParams,
      [AnalyticsCallOptionsJsImpl options]);
  external void setAnalyticsCollectionEnabled(bool enabled);
  external void setCurrentScreen(String screenName,
      [AnalyticsCallOptionsJsImpl options]);
  external void setUserId(String id, [AnalyticsCallOptionsJsImpl options]);
  external void setUserProperties(Object properties,
      [AnalyticsCallOptionsJsImpl options]);
}

@JS('AnalyticsCallOptions')
@anonymous
class AnalyticsCallOptionsJsImpl {
  external bool get global;
  external set global(bool t);

  external factory AnalyticsCallOptionsJsImpl({bool global});
}
