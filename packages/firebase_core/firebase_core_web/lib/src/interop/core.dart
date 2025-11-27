// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

import 'core_interop.dart' as firebase_interop;

export 'app.dart';
export 'app_interop.dart';
export 'core_interop.dart';

List<App> get apps => firebase_interop
    .getApps()
    .toDart
    .cast<AppJsImpl>()
    .map(App.getInstance)
    .toList();

App initializeApp({
  String? apiKey,
  String? authDomain,
  String? databaseURL,
  String? projectId,
  String? storageBucket,
  String? messagingSenderId,
  String? name,
  String? measurementId,
  String? appId,
}) {
  name ??= defaultFirebaseAppName;

  return App.getInstance(
    firebase_interop.initializeApp(
      firebase_interop.FirebaseOptions(
        apiKey: apiKey?.toJS,
        authDomain: authDomain?.toJS,
        databaseURL: databaseURL?.toJS,
        projectId: projectId?.toJS,
        storageBucket: storageBucket?.toJS,
        messagingSenderId: messagingSenderId?.toJS,
        measurementId: measurementId?.toJS,
        appId: appId?.toJS,
      ),
      name.toJS,
    ),
  );
}

App app([String? name]) {
  return App.getInstance(
    name != null
        ? firebase_interop.getApp(name.toJS)
        : firebase_interop.getApp(),
  );
}

void registerVersion(String libraryKeyOrName, String version,
    [String? variant]) {
  firebase_interop.registerVersion(
    libraryKeyOrName.toJS,
    version.toJS,
    variant?.toJS,
  );
}

class FirebaseError {
  final String code;
  final String message;
  final String name;
  final String stack;
  final dynamic serverResponse;

  FirebaseError({
    required this.code,
    required this.message,
    required this.name,
    required this.stack,
    required this.serverResponse,
  });
}
