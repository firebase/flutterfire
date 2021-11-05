// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'method_channel_database.dart';
import 'utils/exception.dart';

/// Represents a query over the data at a particular location.
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  /// Create a [MethodChannelQuery] from [DatabaseReferencePlatform]
  MethodChannelOnDisconnect(
      {required DatabasePlatform database,
      required DatabaseReferencePlatform ref})
      : super(database: database, ref: ref);

  @override
  Future<void> set(Object? value) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#set',
        <String, Object?>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': ref.path,
          'value': value,
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setWithPriority(Object? value, Object? priority) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#setWithPriority',
        <String, Object?>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': ref.path,
          'value': value,
          'priority': priority
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> remove() => set(null);

  @override
  Future<void> cancel() {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#cancel',
        <String, Object?>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': ref.path
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }

  @override
  Future<void> update(Map<String, Object?> value) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#update',
        <String, Object?>{
          'appName': database.app!.name,
          'databaseURL': database.databaseURL,
          'path': ref.path,
          'value': value
        },
      );
    } catch (e, s) {
      throw convertPlatformException(e, s);
    }
  }
}
