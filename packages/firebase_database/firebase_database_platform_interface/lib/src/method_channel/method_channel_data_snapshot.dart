// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

/// Represents a query over the data at a particular location.
class MethodChannelDataSnapshot extends DataSnapshotPlatform {
  MethodChannelDataSnapshot(
    this._ref,
    this._data,
  ) : super(_ref, _data);

  DatabaseReferencePlatform _ref;

  final Map<String, dynamic> _data;

  @override
  DataSnapshotPlatform child(String childPath) {
    Object? childValue = value;
    final chunks = childPath.split('/').toList();

    while (childValue != null && chunks.isNotEmpty) {
      final c = chunks.removeAt(0);
      if (childValue is List) {
        final index = int.tryParse(c);
        if (index == null || index < 0 || index > childValue.length - 1) {
          return MethodChannelDataSnapshot(
            _ref.child(childPath),
            <String, dynamic>{
              'key': _ref.child(childPath).key,
              'value': null,
              'priority': null,
              'childKeys': [],
            },
          );
        }
        childValue = childValue[index];
        continue;
      }

      if (childValue is Map) {
        childValue = childValue[c];
      }
    }

    if (childValue == null) {
      return MethodChannelDataSnapshot(
        _ref.child(childPath),
        <String, dynamic>{
          'key': _ref.child(childPath).key,
          'value': null,
          'priority': null,
          'childKeys': [],
        },
      );
    }

    return MethodChannelDataSnapshot(
      _ref.child(childPath),
      <String, dynamic>{
        'key': _ref.child(childPath).key,
        'value': childValue,
        'priority': null,
        'childKeys': _childKeysFromValue(childValue),
      },
    );
  }

  @override
  Iterable<DataSnapshotPlatform> get children {
    List<String> _childKeys = List<String>.from(_data['childKeys']);

    return Iterable<DataSnapshotPlatform>.generate(_childKeys.length,
        (int index) {
      String childKey = _childKeys[index];

      dynamic childValue;
      if (value != null) {
        if (value is Map<Object?, Object?>) {
          childValue = (value! as Map)[childKey];
        } else if (value is List<Object?>) {
          childValue = (value! as List)[int.parse(childKey)];
        }
      }

      return MethodChannelDataSnapshot(
        _ref.child(childKey),
        <String, dynamic>{
          'key': childKey,
          'value': childValue,
          'priority': null,
          'childKeys': _childKeysFromValue(childValue),
        },
      );
    });
  }
}

List<String> _childKeysFromValue(Object? value) {
  List<String> childChildKeys = [];
  if (value is Map) {
    childChildKeys = List<String>.from(value.keys.toList());
  } else if (value is List) {
    childChildKeys = List<String>.generate(
      value.length,
      (int index) => '${index - 1}',
    );
  }
  return childChildKeys;
}
