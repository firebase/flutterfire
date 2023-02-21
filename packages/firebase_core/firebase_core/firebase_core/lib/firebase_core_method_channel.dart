import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'firebase_core_platform_interface.dart';

/// An implementation of [FirebaseCorePlatform] that uses method channels.
class MethodChannelFirebaseCore extends FirebaseCorePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('firebase_core');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
