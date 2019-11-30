// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@JS()
library firebase_js;

import 'package:js/js.dart';

/// A Firebase app.
@JS()
class App {
  /// The name of the app.
  external String get name;

  /// The options that the app was configured with.
  external Options get options;
}

/// Options for configuring an app.
@JS()
@anonymous
class Options {
  /// Creates an options JavaScript object.
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

  /// The API key used to authenticate requests.
  external String get apiKey;

  /// Domain for authentication.
  external String get authDomain;

  /// Realtime Database URL.
  external String get databaseURL;

  /// The Google Cloud project ID.
  external String get projectId;

  /// The Google Cloud Storage bucket name.
  external String get storageBucket;

  /// The project number used to configure Messaging.
  external String get messagingSenderId;

  /// The Google App ID that uniquely identifies an app instance.
  external String get appId;

  /// An ID used for analytics.
  external String get measurementId;
}

/// The `firebase` namespace.
@JS()
class FirebaseCore {
  /// Returns a list of initialized apps.
  external List<App> get apps;

  /// Initializes the app named [name] with the given [options].
  external App initializeApp(Options options, String name);

  /// Returns the already-initialized app with the given [name].
  external App app(String name);
}

/// Return the `firebase` object.
@JS()
external FirebaseCore get firebase;
