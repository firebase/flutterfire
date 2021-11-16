
import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseInstallations {
  static const MethodChannel _channel = MethodChannel('firebase_installations');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
