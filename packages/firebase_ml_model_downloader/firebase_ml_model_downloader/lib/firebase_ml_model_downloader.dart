
import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseMlModelDownloader {
  static const MethodChannel _channel = MethodChannel('firebase_ml_model_downloader');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
