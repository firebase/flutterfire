// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase.database_interop;

@JS('Query')
abstract class QueryJsImpl {
  external ReferenceJsImpl get ref;

  external bool isEqual(QueryJsImpl other);

  external Object toJSON();

  @override
  external String toString();
}
