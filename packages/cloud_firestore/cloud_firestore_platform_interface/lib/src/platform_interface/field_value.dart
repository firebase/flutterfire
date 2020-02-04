// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// A class to define an interface that's required
/// for building platform-specific implementation
abstract class FieldValueInterface {
  /// Implementation instance
  FieldValueInterface get instance;

  /// type of the FieldValue
  FieldValueType get type;

  /// value of the FieldValue
  dynamic get value;
}

/// Platform Interface of a FieldValue; implementation for [FieldValueInterface]
class FieldValuePlatform extends PlatformInterface
    implements FieldValueInterface {

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [FieldValuePlatform].
  ///
  /// This is used by the app-facing [FieldValue] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(FieldValuePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Constructor
  FieldValuePlatform(this.type, this.value) : super(token: _token);

  @override
  FieldValuePlatform get instance => this;

  @override
  final FieldValueType type;

  @override
  final dynamic value;
}
