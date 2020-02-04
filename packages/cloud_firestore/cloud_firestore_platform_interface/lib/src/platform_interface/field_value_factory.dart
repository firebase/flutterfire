// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/src/method_channel/method_channel_field_value_factory.dart';

/// An interface for a factory that is used to build [FieldValuePlatform] according to
/// Platform (web or mobile)
abstract class FieldValueFactoryPlatform extends PlatformInterface {
  /// Constructor to initialize the PlatformInterface base class
  FieldValueFactoryPlatform() : super(token: _token);

  /// Current instance of [FieldValueFactoryPlatform]
  static FieldValueFactoryPlatform get instance => _instance;

  static FieldValueFactoryPlatform _instance = MethodChannelFieldValueFactory();

  /// Sets the default instance of [FieldValueFactoryPlatform] which is used to build
  /// [FieldValuePlatform] items
  static set instance(FieldValueFactoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [FieldValueFactoryPlatform].
  ///
  /// This is used by the app-facing [FieldValueFactory] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(FieldValueFactoryPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Returns a special value that tells the server to union the given elements
  /// with any array value that already exists on the server.
  ///
  /// Each specified element that doesn't already exist in the array will be
  /// added to the end. If the field being modified is not already an array it
  /// will be overwritten with an array containing exactly the specified
  /// elements.
  FieldValuePlatform arrayUnion(List<dynamic> elements) {
    throw UnimplementedError("arrayUnion() is not implemented");
  }

  /// Returns a special value that tells the server to remove the given
  /// elements from any array value that already exists on the server.
  ///
  /// All instances of each element specified will be removed from the array.
  /// If the field being modified is not already an array it will be overwritten
  /// with an empty array.
  FieldValuePlatform arrayRemove(List<dynamic> elements) {
    throw UnimplementedError("arrayRemove() is not implemented");
  }

  /// Returns a sentinel for use with update() to mark a field for deletion.
  FieldValuePlatform delete() {
    throw UnimplementedError("delete() is not implemented");
  }

  /// Returns a sentinel for use with set() or update() to include a
  /// server-generated timestamp in the written data.
  FieldValuePlatform serverTimestamp() {
    throw UnimplementedError("serverTimestamp() is not implemented");
  }

  /// Returns a special value for use with set() or update() that tells the
  /// server to increment the field’s current value by the given value.
  FieldValuePlatform increment(num value) {
    throw UnimplementedError("increment() is not implemented");
  }
}

/// This is a cross-platform representation of a FieldValue.
///
/// Each concrete platform implementation will extend this class,
/// and add any relevant methods or values to it, so it works as
/// expected for the target platform.
///
/// This is exposed to plugin users, so they can correctly type the
/// results of calling FieldValueFactory instances, but you should
/// never "peek" inside subclasses of this.
///
/// Just treat it as a "black box".
abstract class FieldValuePlatform extends PlatformInterface {
  static final Object _token = Object();

  /// Constructor
  FieldValuePlatform() : super(token: _token);
}
