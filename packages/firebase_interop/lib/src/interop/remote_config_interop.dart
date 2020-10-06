@JS('firebase.remoteConfig')
library firebase.remote_config_interop;

import 'package:js/js.dart';

import 'es6_interop.dart';

@JS('RemoteConfig')
abstract class RemoteConfigJsImpl {
  external SettingsJsImpl get settings;
  external set settings(SettingsJsImpl value);
  external Object get defaultConfig;
  external set defaultConfig(Object value);
  external int get fetchTimeMillis;
  external String get lastFetchStatus;
  external PromiseJsImpl<bool> activate();
  external PromiseJsImpl<void> ensureInitialized();
  external PromiseJsImpl<void> fetch();
  external PromiseJsImpl<bool> fetchAndActivate();
  external dynamic getAll();
  external bool getBoolean(String key);
  external num getNumber(String key);
  external String getString(String key);
  external ValueJsImpl getValue(String key);
  external void setLogLevel(String logLevel);
}

@JS()
@anonymous
abstract class ValueJsImpl {
  external bool asBoolean();
  external num asNumber();
  external String asString();
  external String getSource();
}

@JS()
@anonymous
abstract class SettingsJsImpl {
  external int get minimumFetchIntervalMillis;
  external set minimumFetchIntervalMillis(int value);
  external int get fetchTimeoutMillis;
  external set fetchTimeoutMillis(int value);
}
