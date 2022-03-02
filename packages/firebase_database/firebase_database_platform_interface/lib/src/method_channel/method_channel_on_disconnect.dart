// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:firebase_database_platform_interface/src/method_channel/utils/utils.dart';

import 'method_channel_database.dart';
import 'utils/exception.dart';

/// Represents a query over the data at a particular location.
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  /// Create a [MethodChannelQuery] from [DatabaseReferencePlatform]
  MethodChannelOnDisconnect({
    required DatabasePlatform database,
    required DatabaseReferencePlatform ref,
  }) : super(database: database, ref: ref);

  @override
  Future<void> set(Object? value) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#set',
        database.getChannelArguments({
          'path': ref.path,
          if (value != null) 'value': transformValue(value),
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#setWithPriority',
        database.getChannelArguments(
          {
            'path': ref.path,
            if (value != null) 'value': transformValue(value),
            if (priority != null) 'priority': priority
          },
        ),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> remove() => set(null);

  @override
  Future<void> cancel() async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#cancel',
        database.getChannelArguments({'path': ref.path}),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) async {
    try {
      await MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#update',
        database.getChannelArguments({
          'path': ref.path,
          'value': transformValue(value),
        }),
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
