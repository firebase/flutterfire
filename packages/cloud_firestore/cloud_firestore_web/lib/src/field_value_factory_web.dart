// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:js/js_util.dart';

import 'package:cloud_firestore_web/src/field_value_web.dart';
import 'package:cloud_firestore_web/src/utils/codec_utility.dart';

/// An implementation of [FieldValueFactoryPlatform] which builds [FieldValuePlatform]
/// instance that is [jsify] friendly
class FieldValueFactoryWeb extends FieldValueFactoryPlatform {
  @override
  FieldValueWeb arrayRemove(List elements) => FieldValueWeb(
      web.FieldValue.arrayRemove(CodecUtility.valueEncode(elements)));

  @override
  FieldValueWeb arrayUnion(List elements) => FieldValueWeb(
      web.FieldValue.arrayUnion(CodecUtility.valueEncode(elements)));

  @override
  FieldValueWeb delete() => FieldValueWeb(web.FieldValue.delete());

  @override
  FieldValueWeb increment(num value) =>
      FieldValueWeb(web.FieldValue.increment(value));

  @override
  FieldValueWeb serverTimestamp() =>
      FieldValueWeb(web.FieldValue.serverTimestamp());
}
