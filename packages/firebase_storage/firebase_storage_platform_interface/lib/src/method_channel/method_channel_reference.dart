// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

import '../../firebase_storage_platform_interface.dart';
import 'method_channel_firebase_storage.dart';
import 'method_channel_list_result.dart';
import 'method_channel_task.dart';
import 'utils/exception.dart';

/// An implementation of [ReferencePlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelReference extends ReferencePlatform {
  /// Creates a [ReferencePlatform] that is implemented using [MethodChannel].
  MethodChannelReference(FirebaseStoragePlatform storage, String path)
      : super(storage, path);

  @override
  Future<void> delete() async {
    try {
      await MethodChannelFirebaseStorage.channel
          .invokeMethod('Reference#delete', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<String> getDownloadURL() async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>(
              'Reference#getDownloadURL', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
      });

      return data['downloadURL'];
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<FullMetadata> getMetadata() async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>(
              'Reference#getMetadata', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
      });

      return FullMetadata(data);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<ListResultPlatform> list(ListOptions options) async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>('Reference#list', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
        'options': <String, dynamic>{
          'maxResults': options?.maxResults ?? 1000,
          'pageToken': options?.pageToken,
        },
      });

      return MethodChannelListResult(
        storage,
        nextPageToken: data['nextPageToken'],
        items: List.from(data['items']),
        prefixes: List.from(data['prefixes']),
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<ListResultPlatform> listAll() async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>(
              'Reference#listAll', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
      });
      return MethodChannelListResult(
        storage,
        nextPageToken: data['nextPageToken'],
        items: List.from(data['items']),
        prefixes: List.from(data['prefixes']),
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<Uint8List> getData(int maxSize) {
    try {
      return MethodChannelFirebaseStorage.channel
          .invokeMethod<Uint8List>('Reference#getData', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
        'maxSize': maxSize,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  TaskPlatform putData(Uint8List data, [SettableMetadata metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    MethodChannelFirebaseStorage.taskObservers[handle] =
        StreamController<TaskSnapshotPlatform>.broadcast();
    return MethodChannelPutTask(handle, storage, fullPath, data, metadata);
  }

  @override
  TaskPlatform putBlob(dynamic data, [SettableMetadata metadata]) {
    throw UnimplementedError(
        'putBlob() is not supported on native platforms. Use [put], [putFile] or [putString] instead.');
  }

  @override
  TaskPlatform putFile(File file, [SettableMetadata metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    MethodChannelFirebaseStorage.taskObservers[handle] =
        StreamController<TaskSnapshotPlatform>.broadcast();
    return MethodChannelPutFileTask(handle, storage, fullPath, file, metadata);
  }

  TaskPlatform putString(String data, PutStringFormat format,
      [SettableMetadata metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    MethodChannelFirebaseStorage.taskObservers[handle] =
        StreamController<TaskSnapshotPlatform>.broadcast();
    return MethodChannelPutStringTask(
        handle, storage, fullPath, data, format, metadata);
  }

  Future<FullMetadata> updateMetadata(SettableMetadata metadata) async {
    try {
      Map<String, dynamic> data = await MethodChannelFirebaseStorage.channel
          .invokeMapMethod<String, dynamic>(
              'Reference#updateMetadata', <String, dynamic>{
        'appName': storage.app.name,
        'maxOperationRetryTime': storage.maxOperationRetryTime,
        'maxUploadRetryTime': storage.maxUploadRetryTime,
        'maxDownloadRetryTime': storage.maxDownloadRetryTime,
        'bucket': storage.bucket,
        'path': fullPath,
        'metadata': metadata.asMap(),
      });

      return FullMetadata(data);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  TaskPlatform writeToFile(File file) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    MethodChannelFirebaseStorage.taskObservers[handle] =
        StreamController<TaskSnapshotPlatform>.broadcast();
    return MethodChannelDownloadTask(handle, storage, fullPath, file);
  }
}
