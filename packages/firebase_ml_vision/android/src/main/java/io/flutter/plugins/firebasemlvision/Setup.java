package io.flutter.plugins.firebasemlvision;

import io.flutter.plugin.common.MethodChannel;

interface Setup {
  void setup(String modelName, final MethodChannel.Result result);
}
