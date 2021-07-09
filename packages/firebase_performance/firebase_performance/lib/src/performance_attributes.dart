// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_performance;

/// Abstract class that allows adding/removing attributes to an object.
abstract class PerformanceAttributes {
  PerformanceAttributes._(this._delegate);

  PerformanceAttributesPlatform _delegate;

  /// Sets a String [value] for the specified attribute with [name].
  ///
  /// Updates the value of the attribute if the attribute already exists.
  /// The maximum number of attributes that can be added are
  /// [maxCustomAttributes]. An attempt to add more than [maxCustomAttributes]
  /// to this object will return without adding the attribute.
  ///
  /// Name of the attribute has max length of [maxAttributeKeyLength]
  /// characters. Value of the attribute has max length of
  /// [maxAttributeValueLength] characters. If the name has a length greater
  /// than [maxAttributeKeyLength] or the value has a length greater than
  /// [maxAttributeValueLength], this method will return without adding
  /// anything.
  ///
  /// If this object has been stopped, this method returns without adding the
  /// attribute.
  Future<void> putAttribute(String name, String value) {
    return _delegate.putAttribute(name, value);
  }

  /// Removes an already added attribute.
  ///
  /// If this object has been stopped, this method returns without removing the
  /// attribute.
  Future<void> removeAttribute(String name) {
    return _delegate.removeAttribute(name);
  }

  /// Returns the value of an attribute.
  ///
  /// Returns `null` if an attribute with this [name] has not been added.
  String? getAttribute(String name) => _delegate.getAttribute(name);

  /// All attributes added.
  Future<Map<String, String>> getAttributes() async {
    return _delegate.getAttributes();
  }
}
