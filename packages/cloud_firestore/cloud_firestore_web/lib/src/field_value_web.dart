// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

/// Implementation of [FieldValuePlatform] that is compatible with
/// firestore web plugin
class FieldValueWeb extends FieldValuePlatform {
  /// The js-interop delegate for this [FieldValuePlatform]
  web.FieldValue data;

  /// Constructor.
  FieldValueWeb(this.data) : super();
}
