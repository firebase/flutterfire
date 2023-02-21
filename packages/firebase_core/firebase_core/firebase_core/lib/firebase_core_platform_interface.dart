import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'firebase_core_method_channel.dart';

abstract class FirebaseCorePlatform extends PlatformInterface {
  /// Constructs a FirebaseCorePlatform.
  FirebaseCorePlatform() : super(token: _token);

  static final Object _token = Object();

  static FirebaseCorePlatform _instance = MethodChannelFirebaseCore();

  /// The default instance of [FirebaseCorePlatform] to use.
  ///
  /// Defaults to [MethodChannelFirebaseCore].
  static FirebaseCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FirebaseCorePlatform] when
  /// they register themselves.
  static set instance(FirebaseCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
