/*
 * Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FIRESTORE_CODEC_H_
#define FIRESTORE_CODEC_H_

#include <flutter_linux/flutter_linux.h>

#include <cstddef>
#include <cstdint>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "firebase/firestore.h"
#include "firebase/firestore/field_path.h"
#include "firebase/firestore/field_value.h"
#include "firebase/firestore/geo_point.h"

namespace cloud_firestore_linux {

// Extension of the Pigeon-generated CloudFirestoreMessageCodec that
// (de)serializes the Firestore-specific wire types used by the Dart
// FirestoreMessageCodec (FieldValue sentinels, Timestamp, GeoPoint,
// DocumentReference, Blob, FieldPath, Firestore instance, Settings and
// special doubles). This mirrors windows/firestore_codec.cpp: the generated
// codec in messages.g.cc chains its unknown-type fallbacks into
// firestore_codec_write_value / firestore_codec_read_value_of_type below.
class FirestoreCodec {
 public:
  // Wire bytes used by the Dart FirestoreMessageCodec. These double as the
  // FlValue custom type ids used to carry the decoded firebase C++ objects
  // through FlValue trees (except the ids marked "in-memory only").
  static constexpr uint8_t DATA_TYPE_DATE_TIME = 180;
  static constexpr uint8_t DATA_TYPE_GEO_POINT = 181;
  static constexpr uint8_t DATA_TYPE_DOCUMENT_REFERENCE = 182;
  static constexpr uint8_t DATA_TYPE_BLOB = 183;
  static constexpr uint8_t DATA_TYPE_ARRAY_UNION = 184;
  static constexpr uint8_t DATA_TYPE_ARRAY_REMOVE = 185;
  static constexpr uint8_t DATA_TYPE_DELETE = 186;
  static constexpr uint8_t DATA_TYPE_SERVER_TIMESTAMP = 187;
  static constexpr uint8_t DATA_TYPE_TIMESTAMP = 188;
  static constexpr uint8_t DATA_TYPE_INCREMENT_DOUBLE = 189;
  static constexpr uint8_t DATA_TYPE_INCREMENT_INTEGER = 190;
  static constexpr uint8_t DATA_TYPE_DOCUMENT_ID = 191;
  static constexpr uint8_t DATA_TYPE_FIELD_PATH = 192;
  static constexpr uint8_t DATA_TYPE_NAN = 193;
  static constexpr uint8_t DATA_TYPE_INFINITY = 194;
  static constexpr uint8_t DATA_TYPE_NEGATIVE_INFINITY = 195;
  static constexpr uint8_t DATA_TYPE_FIRESTORE_INSTANCE = 196;
  static constexpr uint8_t DATA_TYPE_FIRESTORE_QUERY = 197;
  static constexpr uint8_t DATA_TYPE_FIRESTORE_SETTINGS = 198;
  // In-memory only FlValue custom id (never a wire byte): a decoded
  // firebase::firestore::FieldValue (sentinels, blobs, timestamps, ...).
  static constexpr uint8_t DATA_TYPE_FIELD_VALUE = 199;
};

// Creates FlValue customs carrying firebase C++ objects (transfer full).
FlValue* CustomFieldValue(const firebase::firestore::FieldValue& value);
FlValue* CustomFieldPath(const firebase::firestore::FieldPath& path);
FlValue* CustomTimestamp(const firebase::Timestamp& timestamp);
FlValue* CustomGeoPoint(const firebase::firestore::GeoPoint& geo_point);
FlValue* CustomDocumentReference(
    const firebase::firestore::DocumentReference& reference);
FlValue* CustomBlob(const uint8_t* data, size_t size);

// Accessors for the FlValue customs above. The FlValue must have the matching
// custom type id.
const firebase::firestore::FieldValue& GetCustomFieldValue(FlValue* value);
const firebase::firestore::FieldPath& GetCustomFieldPath(FlValue* value);

// Converts an FlValue tree (possibly containing the customs above) into
// firebase::firestore values. Ported from the equivalent helpers in
// windows/cloud_firestore_plugin.cpp.
firebase::firestore::FieldValue ConvertToFieldValue(FlValue* value);
std::vector<firebase::firestore::FieldValue> ConvertToFieldValueList(
    FlValue* list);
firebase::firestore::MapFieldValue ConvertToMapFieldValue(FlValue* map);
firebase::firestore::MapFieldPathValue ConvertToMapFieldPathValue(FlValue* map);
std::vector<firebase::firestore::FieldPath> ConvertToFieldPathVector(
    FlValue* list);

// Converts firebase::firestore values into an FlValue tree containing the
// customs above (transfer full).
FlValue* ConvertFieldValueToFlValue(
    const firebase::firestore::FieldValue& field_value);
FlValue* ConvertMapFieldValueToFlValue(
    const firebase::firestore::MapFieldValue& map);

// Cache of Firestore instances keyed by "<appName>-<databaseUrl>", shared
// between the codec (DATA_TYPE_FIRESTORE_INSTANCE) and the plugin
// (GetFirestoreFromPigeon / Terminate). Mirrors
// CloudFirestorePlugin::firestoreInstances_ on Windows.
std::map<std::string, std::unique_ptr<firebase::firestore::Firestore>>&
FirestoreInstanceCache();

}  // namespace cloud_firestore_linux

G_BEGIN_DECLS

// Fallbacks chained from the Pigeon-generated CloudFirestoreMessageCodec in
// messages.g.cc (see the generate:pigeon:linux post-processing step). They
// handle the Firestore wire types and delegate everything else to
// FlStandardMessageCodec.
gboolean firestore_codec_write_value(FlStandardMessageCodec* codec,
                                     GByteArray* buffer, FlValue* value,
                                     GError** error);
FlValue* firestore_codec_read_value_of_type(FlStandardMessageCodec* codec,
                                            GBytes* buffer, size_t* offset,
                                            int type, GError** error);

G_END_DECLS

#endif  // FIRESTORE_CODEC_H_
