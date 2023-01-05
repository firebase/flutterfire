// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase.database_interop;

@JS('DataSnapshot')
@anonymous
abstract class DataSnapshotJsImpl {
  external String get key;

  external ReferenceJsImpl get ref;

  external dynamic /* string | num | null*/ get priority;

  external int get size;

  external DataSnapshotJsImpl child(String path);

  external bool exists();

  external dynamic exportVal();

  external bool forEach(void Function(dynamic) action);

  external dynamic getPriority();

  external bool hasChild(String path);

  external bool hasChildren();

  external Object toJSON();

  external dynamic val();
}
