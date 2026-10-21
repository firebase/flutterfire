// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_web/firebase_database_web.dart';
import 'package:firebase_database_web/src/interop/database.dart'
    as database_interop;
import 'package:firebase_database_web/src/interop/database_interop.dart'
    as database_js;
import 'package:flutter_test/flutter_test.dart';

class _FakeReference extends Fake implements DatabaseReferencePlatform {
  _FakeReference(this.path);

  @override
  final String path;

  @override
  DatabaseReferencePlatform child(String childPath) =>
      _FakeReference('$path/$childPath');
}

/// Minimal stand-in for the JS `DataSnapshot` object.
JSObject _fakeSnapshot(String key,
    [Map<String, JSObject> children = const {}]) {
  final snapshot = JSObject();
  snapshot['key'] = key.toJS;
  snapshot['val'] = (() => key.toJS).toJS;
  snapshot['child'] = ((JSString path) => children[path.toDart]!).toJS;
  return snapshot;
}

void main() {
  test('child() returns a snapshot whose ref is the child reference', () {
    final jsSnapshot = _fakeSnapshot('messages', {'a': _fakeSnapshot('a')});
    final snapshot = DataSnapshotWeb(
      _FakeReference('messages'),
      database_interop.DataSnapshot.getInstance(
        jsSnapshot as database_js.DataSnapshotJsImpl,
      ),
    );

    final child = snapshot.child('a');

    expect(child.key, 'a');
    expect(child.ref.path, 'messages/a');
  });
}
