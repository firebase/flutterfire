// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/messages.pigeon.dart',
    // We export in the lib folder to expose the class to other packages.
    dartTestOut: 'test/pigeon/test_api.dart',
    javaOut:
        '../firebase_storage/android/src/main/java/io/flutter/plugins/firebase/storage/GeneratedAndroidFirebaseStorage.java',
    javaOptions: JavaOptions(
      package: 'io.flutter.plugins.firebase.storage',
      className: 'GeneratedAndroidFirebaseStorage',
    ),
    objcHeaderOut: '../firebase_storage/ios/Classes/messages.g.h',
    objcSourceOut: '../firebase_storage/ios/Classes/messages.g.m',
    cppHeaderOut: '../firebase_storage/windows/messages.g.h',
    cppSourceOut: '../firebase_storage/windows/messages.g.cpp',
    cppOptions: CppOptions(namespace: 'firebase_storage_windows'),
  ),
)
class PigeonFirebaseApp {
  const PigeonFirebaseApp({
    required this.appName,
    required this.tenantId,
  });

  final String appName;
  final String? tenantId;
}

/// The type of operation that generated the action code from calling
/// [TaskState].
enum PigeonTaskState {
  /// Indicates the task has been paused by the user.
  paused,

  /// Indicates the task is currently in-progress.
  running,

  /// Indicates the task has successfully completed.
  success,

  /// Indicates the task was canceled.
  canceled,

  /// Indicates the task failed with an error.
  error,
}

class PigeonStorageReference {
  const PigeonStorageReference({
    required this.bucket,
    required this.fullPath,
    required this.name,
  });

  final String bucket;
  final String fullPath;
  final String name;
}

class PigeonFullMetaData {
  const PigeonFullMetaData({
    required this.metadata,
  });
  final Map<String?, Object?>? metadata;
}

class PigeonListOptions {
  const PigeonListOptions({
    this.maxResults,
    this.pageToken,
  });

  /// If set, limits the total number of `prefixes` and `items` to return.
  ///
  /// The default and maximum maxResults is 1000.
  final int? maxResults;

  /// The nextPageToken from a previous call to list().
  ///
  /// If provided, listing is resumed from the previous position.
  final String? pageToken;
}

class PigeonSettableMetadata {
  /// Creates a new [PigeonSettableMetadata] instance.
  PigeonSettableMetadata({
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
    this.customMetadata,
  });

  /// Served as the 'Cache-Control' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control.
  final String? cacheControl;

  /// Served as the 'Content-Disposition' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition.
  final String? contentDisposition;

  /// Served as the 'Content-Encoding' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Encoding.
  final String? contentEncoding;

  /// Served as the 'Content-Language' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Language.
  final String? contentLanguage;

  /// Served as the 'Content-Type' header on object download.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type.
  final String? contentType;

  /// Additional user-defined custom metadata.
  final Map<String?, String?>? customMetadata;
}

class PigeonTaskSnapShot {
  const PigeonTaskSnapShot({
    required this.bytesTransferred,
    required this.metadata,
    required this.state,
    required this.totalBytes,
  });

  final int bytesTransferred;
  final PigeonFullMetaData? metadata;
  final PigeonTaskState state;
  final int totalBytes;
}

class PigeonListResult {
  const PigeonListResult({
    required this.items,
    required this.pageToken,
    required this.prefixs,
  });

  final List<PigeonStorageReference?> items;
  final String? pageToken;
  final List<PigeonStorageReference?> prefixs;
}

@HostApi(dartHostTestHandler: 'TestFirebaseStorageHostApi')
abstract class FirebaseStorageHostApi {
  @async
  PigeonStorageReference getReferencebyPath(
    PigeonFirebaseApp app,
    String path,
    String? bucket,
  );
  @async
  void setMaxOperationRetryTime(
    PigeonFirebaseApp app,
    int time,
  );
  @async
  void setMaxUploadRetryTime(
    PigeonFirebaseApp app,
    int time,
  );
  @async
  void setMaxDownloadRetryTime(
    PigeonFirebaseApp app,
    int time,
  );

  @async
  void useStorageEmulator(
    PigeonFirebaseApp app,
    String host,
    int port,
  );

  // APIs for Reference class

  @async
  void referenceDelete(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
  );

  @async
  String referenceGetDownloadURL(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
  );

  @async
  PigeonFullMetaData referenceGetMetaData(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
  );

  @async
  PigeonListResult referenceList(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    PigeonListOptions options,
  );

  @async
  PigeonListResult referenceListAll(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
  );

  @async
  Uint8List? referenceGetData(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    int maxSize,
  );

  // TODO figure out how to manage the UploadTask and DownloadTask
  @async
  String referencePutData(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    Uint8List data,
    PigeonSettableMetadata settableMetaData,
    int handle,
  );

  @async
  String refrencePutString(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    String data,
    int format,
    PigeonSettableMetadata settableMetaData,
    int handle,
  );

  @async
  String referencePutFile(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    String filePath,
    PigeonSettableMetadata settableMetaData,
    int handle,
  );

  @async
  String referenceDownloadFile(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    String filePath,
    int handle,
  );

  @async
  PigeonFullMetaData referenceUpdateMetadata(
    PigeonFirebaseApp app,
    PigeonStorageReference reference,
    PigeonSettableMetadata metadata,
  );

  // APIs for Task class
  @async
  Map<String, Object> taskPause(
    PigeonFirebaseApp app,
    int handle,
  );

  @async
  Map<String, Object> taskResume(
    PigeonFirebaseApp app,
    int handle,
  );

  @async
  Map<String, Object> taskCancel(
    PigeonFirebaseApp app,
    int handle,
  );
}
