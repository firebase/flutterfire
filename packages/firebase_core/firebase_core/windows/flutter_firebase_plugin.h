#pragma once
#ifndef FLUTTER_FIREBASE_PLUGIN_H
#define FLUTTER_FIREBASE_PLUGIN_H

#include <future>
#include <map>
#include <string>

#include "firebase/app.h"
#include "firebase/future.h"
#include <flutter/standard_method_codec.h>

class FlutterFirebasePlugin {
 public:
  virtual ~FlutterFirebasePlugin() {}
  virtual firebase::Future<flutter::EncodableMap> getPluginConstantsForFirebaseApp(firebase::App firebaseApp) = 0;
  virtual firebase::Future<void> didReinitializeFirebaseCore() = 0;
};

#endif