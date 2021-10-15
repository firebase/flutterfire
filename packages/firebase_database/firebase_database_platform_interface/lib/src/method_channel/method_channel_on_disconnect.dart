// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// Represents a query over the data at a particular location.
class MethodChannelOnDisconnect extends OnDisconnectPlatform {
  /// Create a [MethodChannelQuery] from [DatabaseReferencePlatform]
  MethodChannelOnDisconnect(
      {required DatabasePlatform database,
      required DatabaseReferencePlatform ref})
      : path = ref.path,
        super(database: database, ref: ref);

  final String path;

  @override
  Future<void> set(dynamic value, {dynamic priority}) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#set',
        <String, dynamic>{
          'appName': database.app?.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'value': value,
          'priority': priority
        },
      );
    } on PlatformException catch (e) {
      throw FirebaseDatabaseException.fromPlatformException(e);
    }
  }

  @override
  Future<void> remove() => set(null);

  @override
  Future<void> cancel() {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#cancel',
        <String, dynamic>{
          'appName': database.app?.name,
          'databaseURL': database.databaseURL,
          'path': path
        },
      );
    } on PlatformException catch (e) {
      throw FirebaseDatabaseException.fromPlatformException(e);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> value) {
    try {
      return MethodChannelDatabase.channel.invokeMethod<void>(
        'OnDisconnect#update',
        <String, dynamic>{
          'appName': database.app?.name,
          'databaseURL': database.databaseURL,
          'path': path,
          'value': value
        },
      );
    } on PlatformException catch (e) {
      throw FirebaseDatabaseException.fromPlatformException(e);
    }
  }
}
