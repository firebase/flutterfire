// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:meta/meta.dart';

import 'default_app_name.dart' if (dart.library.io) 'default_app_name_io.dart';

class FirebaseApp {
  // TODO(jackson): We could assert here that an app with this name was configured previously.
  FirebaseApp({@required this.name}) : assert(name != null);

  /// The name of this app.
  final String name;

  static final String defaultAppName = firebaseDefaultAppName;

  /// A copy of the options for this app. These are non-modifiable.
  ///
  /// This getter is asynchronous because apps can also be configured by native
  /// code.
  Future<FirebaseOptions> get options async {
    final PlatformFirebaseApp app =
        await FirebaseCorePlatform.instance.appNamed(name);
    assert(app != null);
    return app.options;
  }

  /// Returns a previously created FirebaseApp instance with the given name,
  /// or null if no such app exists.
  static Future<FirebaseApp> appNamed(String name) async {
    final PlatformFirebaseApp app =
        await FirebaseCorePlatform.instance.appNamed(name);
    return app == null ? null : FirebaseApp(name: app.name);
  }

  /// Returns the default (first initialized) instance of the FirebaseApp.
  static final FirebaseApp instance = FirebaseApp(name: defaultAppName);

  /// Configures an app with the given [name] and [options].
  ///
  /// Configuring the default app is not currently supported. Plugins that
  /// can interact with the default app should configure it automatically at
  /// plugin registration time.
  ///
  /// Changing the options of a configured app is not supported.
  static Future<FirebaseApp> configure({
    @required String name,
    @required FirebaseOptions options,
  }) async {
    assert(name != null);
    assert(name != defaultAppName);
    assert(options != null);
    assert(options.googleAppID != null);
    final FirebaseApp existingApp = await FirebaseApp.appNamed(name);
    if (existingApp != null) {
      return existingApp;
    }
    await FirebaseCorePlatform.instance.configure(name, options);
    return FirebaseApp(name: name);
  }

  /// Returns a list of all extant FirebaseApp instances, or null if there are
  /// no FirebaseApp instances.
  static Future<List<FirebaseApp>> allApps() async {
    final List<PlatformFirebaseApp> result =
        await FirebaseCorePlatform.instance.allApps();
    return result
        ?.map<FirebaseApp>(
          (PlatformFirebaseApp app) => FirebaseApp(name: app.name),
        )
        ?.toList();
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! FirebaseApp) return false;
    return other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => '$FirebaseApp($name)';
}
