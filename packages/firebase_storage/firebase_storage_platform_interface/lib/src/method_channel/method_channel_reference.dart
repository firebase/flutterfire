// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../firebase_storage_platform_interface.dart';
import '../pigeon/messages.pigeon.dart';
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

  /// FirebaseApp pigeon instance
  PigeonStorageFirebaseApp get pigeonFirebaseApp {
    return PigeonStorageFirebaseApp(
      appName: storage.app.name,
      bucket: storage.bucket,
    );
  }

  /// Default of FirebaseReference pigeon instance
  PigeonStorageReference get pigeonReference {
    return PigeonStorageReference(
      bucket: storage.bucket,
      fullPath: fullPath,
      name: name,
    );
  }

  @override
  Future<void> delete() async {
    try {
      await MethodChannelFirebaseStorage.pigeonChannel
          .referenceDelete(pigeonFirebaseApp, pigeonReference);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<String> getDownloadURL() async {
    try {
      String url = await MethodChannelFirebaseStorage.pigeonChannel
          .referenceGetDownloadURL(pigeonFirebaseApp, pigeonReference);
      return url;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  /// Convert a [PigeonFullMetaData] to [FullMetadata]
  static FullMetadata convertMetadata(PigeonFullMetaData pigeonMetadata) {
    Map<String, dynamic> _metadata = <String, dynamic>{};
    pigeonMetadata.metadata?.forEach((key, value) {
      if (key != null) {
        _metadata[key] = value;
      }
    });
    return FullMetadata(_metadata);
  }

  @override
  Future<FullMetadata> getMetadata() async {
    try {
      PigeonFullMetaData metaData = await MethodChannelFirebaseStorage
          .pigeonChannel
          .referenceGetMetaData(pigeonFirebaseApp, pigeonReference);
      return convertMetadata(metaData);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  /// Convert a [ListOptions] to [PigeonListOptions]
  static PigeonListOptions convertOptions(ListOptions? options) {
    if (options == null) {
      return PigeonListOptions(maxResults: 1000);
    }
    return PigeonListOptions(
      maxResults: options.maxResults ?? 1000,
      pageToken: options.pageToken,
    );
  }

  /// Convert a [PigeonListResult] to [ListResultPlatform]
  ListResultPlatform convertListReference(
      PigeonListResult pigeonReferenceList) {
    List<String> referencePaths = [];
    for (final reference in pigeonReferenceList.items) {
      referencePaths.add(reference!.fullPath);
    }
    List<String> prefixPaths = [];
    for (final prefix in pigeonReferenceList.prefixs) {
      prefixPaths.add(prefix!.fullPath);
    }
    return MethodChannelListResult(
      storage,
      nextPageToken: pigeonReferenceList.pageToken,
      items: referencePaths,
      prefixes: prefixPaths,
    );
  }

  @override
  Future<ListResultPlatform> list([ListOptions? options]) async {
    try {
      PigeonListOptions pigeonOptions = convertOptions(options);
      PigeonListResult pigeonReferenceList = await MethodChannelFirebaseStorage
          .pigeonChannel
          .referenceList(pigeonFirebaseApp, pigeonReference, pigeonOptions);
      return convertListReference(pigeonReferenceList);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<ListResultPlatform> listAll() async {
    try {
      PigeonListResult pigeonReferenceList = await MethodChannelFirebaseStorage
          .pigeonChannel
          .referenceListAll(pigeonFirebaseApp, pigeonReference);
      return convertListReference(pigeonReferenceList);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<Uint8List?> getData(int maxSize) async {
    try {
      return await MethodChannelFirebaseStorage.pigeonChannel
          .referenceGetData(pigeonFirebaseApp, pigeonReference, maxSize);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  TaskPlatform putData(Uint8List data, [SettableMetadata? metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    return MethodChannelPutTask(handle, storage, fullPath, data, metadata);
  }

  @override
  TaskPlatform putBlob(dynamic data, [SettableMetadata? metadata]) {
    throw UnimplementedError(
        'putBlob() is not supported on native platforms. Use [put], [putFile] or [putString] instead.');
  }

  @override
  TaskPlatform putFile(File file, [SettableMetadata? metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    return MethodChannelPutFileTask(handle, storage, fullPath, file, metadata);
  }

  @override
  TaskPlatform putString(String data, PutStringFormat format,
      [SettableMetadata? metadata]) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    return MethodChannelPutStringTask(
        handle, storage, fullPath, data, format, metadata);
  }

  /// Convert a [SettableMetadata] to [PigeonSettableMetadata]
  PigeonSettableMetadata convertToPigeonMetaData(SettableMetadata data) {
    return PigeonSettableMetadata(
      cacheControl: data.cacheControl,
      contentDisposition: data.contentDisposition,
      contentEncoding: data.contentEncoding,
      contentLanguage: data.contentLanguage,
      contentType: data.contentType,
      customMetadata: data.customMetadata,
    );
  }

  @override
  Future<FullMetadata> updateMetadata(SettableMetadata metadata) async {
    try {
      PigeonFullMetaData updatedMetaData = await MethodChannelFirebaseStorage
          .pigeonChannel
          .referenceUpdateMetadata(pigeonFirebaseApp, pigeonReference,
              convertToPigeonMetaData(metadata));
      return convertMetadata(updatedMetaData);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  TaskPlatform writeToFile(File file) {
    int handle = MethodChannelFirebaseStorage.nextMethodChannelHandleId;
    return MethodChannelDownloadTask(handle, storage, fullPath, file);
  }
}
