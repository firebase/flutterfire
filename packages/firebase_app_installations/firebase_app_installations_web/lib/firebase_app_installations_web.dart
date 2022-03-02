// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_app_installations_web;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_app_installations_platform_interface/firebase_app_installations_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/guard.dart';
import 'src/interop/installations.dart' as installations_interop;

class FirebaseAppInstallationsWeb extends FirebaseAppInstallationsPlatform {
  /// The entry point for the [FirebaseAppInstallationsWeb] class.
  FirebaseAppInstallationsWeb({FirebaseApp? app}) : super(app);

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseAppInstallationsWeb._()
      : _webInstallations = null,
        super(null);

  /// Instance of installations from the web plugin.
  installations_interop.Installations? _webInstallations;

  /// Lazily initialize [_webFunctions] on first method call
  installations_interop.Installations get _delegate {
    return _webInstallations ??= installations_interop
        .getInstallationsInstance(core_interop.app(app?.name));
  }

  /// Create the default instance of the [FirebaseAppInstallationsPlatform] as a [FirebaseAppInstallationsWeb]
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('installations');
    FirebaseAppInstallationsPlatform.instance =
        FirebaseAppInstallationsWeb.instance;
  }

  /// Returns an instance of [FirebaseAppInstallationsWeb].
  static FirebaseAppInstallationsWeb get instance {
    return FirebaseAppInstallationsWeb._();
  }

  @override
  FirebaseAppInstallationsPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseAppInstallationsWeb(app: app);
  }

  @override
  Future<void> delete() async {
    return convertWebExceptions(() => _delegate.delete());
  }

  @override
  Future<String> getId() async {
    return convertWebExceptions(() => _delegate.getId());
  }

  @override
  Future<String> getToken(bool forceRefresh) async {
    return convertWebExceptions(() => _delegate.getToken(forceRefresh));
  }

  @override
  Stream<String> get onIdChange {
    return convertWebExceptions(() => _delegate.onIdChange);
  }
}
