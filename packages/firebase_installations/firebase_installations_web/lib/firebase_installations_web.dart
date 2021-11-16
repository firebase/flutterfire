// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_installations_web;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_installations_platform_interface/firebase_installations_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/guard.dart';
import 'src/interop/installations.dart' as installations_interop;

class FirebaseInstallationsWeb extends FirebaseInstallationsPlatform {
  /// The entry point for the [FirebaseInstallationsWeb] class.
  FirebaseInstallationsWeb({FirebaseApp? app}) : super(app);

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseInstallationsWeb._()
      : _webInstallations = null,
        super(null);

  /// Instance of installations from the web plugin.
  installations_interop.Installations? _webInstallations;

  /// Lazily initialize [_webFunctions] on first method call
  installations_interop.Installations get _delegate {
    return _webInstallations ??= installations_interop
        .getInstallationsInstance(core_interop.app(app?.name));
  }

  /// Create the default instance of the [FirebaseInstallationsPlatform] as a [FirebaseInstallationsWeb]
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('installations');
    FirebaseInstallationsPlatform.instance = FirebaseInstallationsWeb.instance;
  }

  /// Returns an instance of [FirebaseInstallationsWeb].
  static FirebaseInstallationsWeb get instance {
    return FirebaseInstallationsWeb._();
  }

  @override
  FirebaseInstallationsPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseInstallationsWeb(app: app);
  }

  @override
  Future<void> delete() async {
    return guard(() => _delegate.delete());
  }

  @override
  Future<String> getId() async {
    return guard(() => _delegate.getId());
  }

  @override
  Future<String> getToken(bool forceRefresh) async {
    return guard(() => _delegate.getToken(forceRefresh));
  }

  @override
  Stream<String> get idTokenChanges {
    return guard(() => _delegate.onIdChange);
  }
}
