import 'package:firebase_storage_platform_interface/firebase_storage_platform_interface.dart';
import 'package:firebase/firebase.dart' as fb;

/// Converts FullMetadata coming from the JS Interop layer to FullMetadata for the plugin.
FullMetadata fbFullMetadataToFullMetadata(fb.FullMetadata metadata) {
  if (metadata == null) {
    return null;
  }

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
    // 'metadataGeneration': metadata.metadataGeneration,
    'md5Hash': metadata.md5Hash,
    'metageneration': metadata.metageneration,
    'name': metadata.name,
    'size': metadata.size,
    'creationTimeMillis': metadata.timeCreated.millisecondsSinceEpoch,
    'updatedTimeMillis': metadata.updated.millisecondsSinceEpoch,
  });
}

/// Converts SettableMetadata from the plugin to SettableMetadata for the JS Interop layer.
fb.SettableMetadata settableMetadataToFbSettableMetadata(
    SettableMetadata metadata) {
  if (metadata == null) {
    return null;
  }

  return fb.SettableMetadata(
    cacheControl: metadata.cacheControl,
    contentDisposition: metadata.contentDisposition,
    contentEncoding: metadata.contentEncoding,
    contentLanguage: metadata.contentLanguage,
    contentType: metadata.contentType,
    customMetadata: metadata.customMetadata,
  );
}

/// Converts SettableMetadata from the plugin and an additional MD5 hash (as String) to an UploadMetadata for the JS Interop layer.
fb.UploadMetadata settableMetadataToFbUploadMetadata(SettableMetadata metadata,
    {String md5Hash}) {
  if (metadata == null) {
    return null;
  }

  return fb.UploadMetadata(
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
  PutStringFormat.base64: fb.StringFormat.BASE64,
  PutStringFormat.base64Url: fb.StringFormat.BASE64URL,
  PutStringFormat.dataUrl: fb.StringFormat.DATA_URL,
  PutStringFormat.raw: fb.StringFormat.RAW,
};

/// Converts PutStringFormat from the plugin to the correct StringFormat for the JS interop layer.
String putStringFormatToString(PutStringFormat format) {
  if (format == null) {
    return null;
  }

  return _putStringFormatToFbStringFormat[format];
}
