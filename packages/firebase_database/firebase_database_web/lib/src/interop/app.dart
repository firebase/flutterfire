// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, comment_references
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_database_web/src/interop/database.dart';

import 'app_interop.dart';

/// A Firebase App holds the initialization information for a collection
/// of services.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.app>.
class App extends core_interop.JsObjectWrapper<AppJsImpl> {
  App._fromJsObject(AppJsImpl jsObject) : super.fromJsObject(jsObject);

  static final _expando = Expando<App>();

  /// Name of the app.
  String get name => jsObject.name;

  /// Options used during [firebase.initializeApp()].
  core_interop.FirebaseOptions get options => jsObject.options;

  /// Creates a new App from a [jsObject].
  static App getInstance(AppJsImpl jsObject) {
    return _expando[jsObject] ??= App._fromJsObject(jsObject);
  }

  /// Deletes the app and frees resources of all App's services.
  Future delete() => core_interop.handleThenable(jsObject.delete());

  /// Returns [Database] service.
  Database database(String? databaseURL) =>
      Database.getInstance(jsObject.database(databaseURL));
}
