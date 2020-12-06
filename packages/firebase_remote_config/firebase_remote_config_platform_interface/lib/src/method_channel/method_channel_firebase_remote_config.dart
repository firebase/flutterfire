import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter/services.dart';

class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {

  static MethodChannelFirebaseRemoteConfig get instance {
    return MethodChannelFirebaseRemoteConfig._();
  }

  static const MethodChannel channel = MethodChannel('plugins.flutter.io/firebase_remote_config');

  MethodChannelFirebaseRemoteConfig._() : super(null);
}
