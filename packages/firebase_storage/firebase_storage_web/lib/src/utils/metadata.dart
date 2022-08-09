// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';

import '../interop/storage.dart' as storage_interop;

/// Converts FullMetadata coming from the JS Interop layer to FullMetadata for the plugin.
FullMetadata fbFullMetadataToFullMetadata(
    storage_interop.FullMetadata metadata) {
  return FullMetadata({
    'bucket': metadata.bucket,
    'cacheControl': metadata.cacheControl,
    'contentDisposition': metadata.contentDisposition,
    'contentEncoding': metadata.contentEncoding,
    'contentLanguage': metadata.contentLanguage,
    'contentType': metadata.contentType,
    'customMetadata': metadata.customMetadata,
    'fullPath': metadata.fullPath,
    'generation': metadata.generation,
    'md5Hash': metadata.md5Hash,
    'metageneration': metadata.metageneration,
    'name': metadata.name,
    'size': metadata.size,
    'creationTimeMillis': metadata.timeCreated!.millisecondsSinceEpoch,
    'updatedTimeMillis': metadata.updated!.millisecondsSinceEpoch,
  });
}

/// Converts SettableMetadata from the plugin to SettableMetadata for the JS Interop layer.
storage_interop.SettableMetadata settableMetadataToFbSettableMetadata(
    SettableMetadata metadata) {
  return storage_interop.SettableMetadata(
    cacheControl: metadata.cacheControl,
    contentDisposition: metadata.contentDisposition,
    contentEncoding: metadata.contentEncoding,
    contentLanguage: metadata.contentLanguage,
    contentType: metadata.contentType,
    customMetadata: metadata.customMetadata,
  );
}

/// Converts SettableMetadata from the plugin and an additional MD5 hash (as String) to an UploadMetadata for the JS Interop layer.
storage_interop.UploadMetadata settableMetadataToFbUploadMetadata(
    SettableMetadata metadata,
    {String? md5Hash}) {
  return storage_interop.UploadMetadata(
    cacheControl: metadata.cacheControl,
    contentDisposition: metadata.contentDisposition,
    contentEncoding: metadata.contentEncoding,
    contentLanguage: metadata.contentLanguage,
    contentType: metadata.contentType,
    customMetadata: metadata.customMetadata,
    md5Hash: md5Hash,
  );
}

Map<PutStringFormat, String> _putStringFormatToFbStringFormat = {
  PutStringFormat.base64: storage_interop.StringFormat.BASE64,
  PutStringFormat.base64Url: storage_interop.StringFormat.BASE64URL,
  PutStringFormat.dataUrl: storage_interop.StringFormat.DATA_URL,
  PutStringFormat.raw: storage_interop.StringFormat.RAW,
};

/// Converts PutStringFormat from the plugin to the correct StringFormat for the JS interop layer.
String? putStringFormatToString(PutStringFormat format) {
  return _putStringFormatToFbStringFormat[format];
}
