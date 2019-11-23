// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS('firebase')
library firebase_js;

import 'package:js/js.dart';

@JS()
class App {
  external String get name;
  external Options get options;
}

@JS()
@anonymous
class Options {
  external String get apiKey;
  external String get authDomain;
  external String get databaseURL;
  external String get projectId;
  external String get storageBucket;
  external String get messagingSenderId;
  external String get appId;
  external String get measurementId;

  external factory Options({
    String apiKey,
    String authDomain,
    String databaseURL,
    String projectId,
    String storageBucket,
    String messagingSenderId,
    String appId,
    String measurementId,
  });
}

@JS()
external List<App> get apps;

@JS()
external App initializeApp(Options options, String name);

@JS()
external App app(String name);
