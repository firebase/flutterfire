// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:js/js_util.dart';

import 'package:cloud_firestore_web/src/field_value_web.dart';

/// An implementation of [FieldValueFactoryPlatform] which builds [FieldValuePlatform]
/// instance that is [jsify] friendly
class FieldValueFactoryWeb extends FieldValueFactoryPlatform {
  @override
  FieldValuePlatform arrayRemove(List elements) =>
      FieldValueWeb(web.FieldValue.arrayRemove(elements));

  @override
  FieldValuePlatform arrayUnion(List elements) =>
      FieldValueWeb(web.FieldValue.arrayUnion(elements));

  @override
  FieldValuePlatform delete() => FieldValueWeb(web.FieldValue.delete());

  @override
  FieldValuePlatform increment(num value) =>
      FieldValueWeb(web.FieldValue.increment(value));

  @override
  FieldValuePlatform serverTimestamp() =>
      FieldValueWeb(web.FieldValue.serverTimestamp());
}
