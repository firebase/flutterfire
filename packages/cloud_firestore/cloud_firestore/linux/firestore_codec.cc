// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firestore_codec.h"

#include <cmath>
#include <cstdint>
#include <cstring>
#include <limits>
#include <map>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

#include "firebase/app.h"
#include "firebase/firestore.h"

using firebase::Timestamp;
using firebase::firestore::DocumentReference;
using firebase::firestore::FieldPath;
using firebase::firestore::FieldValue;
using firebase::firestore::Firestore;
using firebase::firestore::GeoPoint;

namespace cloud_firestore_linux {

namespace {

// Boxes a copy of a firebase C++ value inside an FlValue custom. The FlValue
// owns the heap copy and deletes it when the last reference is dropped.
template <typename T>
FlValue* BoxCustom(int type_id, const T& value) {
  return fl_value_new_custom(type_id, new T(value), [](gpointer boxed) {
    delete static_cast<T*>(boxed);
  });
}

template <typename T>
const T& UnboxCustom(FlValue* value) {
  return *static_cast<const T*>(fl_value_get_custom_value(value));
}

// Returns the FlStandardMessageCodec base class so the fallbacks below can
// chain up past the Pigeon-generated subclass without recursing into it.
FlStandardMessageCodecClass* StandardCodecClass() {
  return FL_STANDARD_MESSAGE_CODEC_CLASS(
      g_type_class_peek(fl_standard_message_codec_get_type()));
}

gboolean WriteBytes(GByteArray* buffer, const void* data, size_t length) {
  g_byte_array_append(buffer, static_cast<const guint8*>(data),
                      static_cast<guint>(length));
  return TRUE;
}

void WriteAlignment(GByteArray* buffer, size_t alignment) {
  static const uint8_t zero = 0;
  while (buffer->len % alignment != 0) {
    g_byte_array_append(buffer, &zero, 1);
  }
}

gboolean WriteStringValue(FlStandardMessageCodec* codec, GByteArray* buffer,
                          const std::string& value, GError** error) {
  g_autoptr(FlValue) fl_string = fl_value_new_string(value.c_str());
  return fl_standard_message_codec_write_value(codec, buffer, fl_string, error);
}

gboolean ReadBytes(GBytes* buffer, size_t* offset, void* out, size_t count,
                   GError** error) {
  gsize data_length;
  const uint8_t* data =
      static_cast<const uint8_t*>(g_bytes_get_data(buffer, &data_length));
  if (*offset + count > data_length) {
    g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED,
                "Unexpected end of message");
    return FALSE;
  }
  memcpy(out, data + *offset, count);
  *offset += count;
  return TRUE;
}

void ReadAlignment(size_t* offset, size_t alignment) {
  while (*offset % alignment != 0) {
    (*offset)++;
  }
}

// Reads a full (typed) value using the derived codec so nested Firestore
// customs are decoded too. Returns nullptr on error.
FlValue* ReadNestedValue(FlStandardMessageCodec* codec, GBytes* buffer,
                         size_t* offset, GError** error) {
  return fl_standard_message_codec_read_value(codec, buffer, offset, error);
}

std::string ReadNestedString(FlStandardMessageCodec* codec, GBytes* buffer,
                             size_t* offset, GError** error) {
  g_autoptr(FlValue) value = ReadNestedValue(codec, buffer, offset, error);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return std::string();
  }
  return fl_value_get_string(value);
}

firebase::firestore::Settings SettingsFromFlValueMap(FlValue* settings_map) {
  firebase::firestore::Settings settings;

  std::map<std::string, FlValue*> map;
  if (settings_map != nullptr &&
      fl_value_get_type(settings_map) == FL_VALUE_TYPE_MAP) {
    size_t length = fl_value_get_length(settings_map);
    for (size_t i = 0; i < length; ++i) {
      FlValue* key = fl_value_get_map_key(settings_map, i);
      FlValue* value = fl_value_get_map_value(settings_map, i);
      if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING &&
          fl_value_get_type(value) != FL_VALUE_TYPE_NULL) {
        map[fl_value_get_string(key)] = value;
      }
    }
  }

  if (map.count("persistenceEnabled") != 0) {
    bool persist_enabled = fl_value_get_bool(map["persistenceEnabled"]);

    // This is the maximum amount of cache allowed. We use the same number
    // on android.
    int64_t size = 104857600;

    if (map.count("cacheSizeBytes") != 0) {
      int64_t cache_size_bytes = fl_value_get_int(map["cacheSizeBytes"]);
      if (cache_size_bytes != -1) {
        size = cache_size_bytes;
      }
    }

    if (persist_enabled) {
      settings.set_cache_size_bytes(size);
    }
  }

  if (map.count("host") != 0) {
    settings.set_host(fl_value_get_string(map["host"]));

    // Only allow changing ssl if host is also specified.
    settings.set_ssl_enabled(false);
  }

  return settings;
}

}  // namespace

FlValue* CustomFieldValue(const FieldValue& value) {
  return BoxCustom<FieldValue>(FirestoreCodec::DATA_TYPE_FIELD_VALUE, value);
}

FlValue* CustomFieldPath(const FieldPath& path) {
  return BoxCustom<FieldPath>(FirestoreCodec::DATA_TYPE_FIELD_PATH, path);
}

FlValue* CustomTimestamp(const Timestamp& timestamp) {
  return BoxCustom<Timestamp>(FirestoreCodec::DATA_TYPE_TIMESTAMP, timestamp);
}

FlValue* CustomGeoPoint(const GeoPoint& geo_point) {
  return BoxCustom<GeoPoint>(FirestoreCodec::DATA_TYPE_GEO_POINT, geo_point);
}

FlValue* CustomDocumentReference(const DocumentReference& reference) {
  return BoxCustom<DocumentReference>(
      FirestoreCodec::DATA_TYPE_DOCUMENT_REFERENCE, reference);
}

const FieldValue& GetCustomFieldValue(FlValue* value) {
  return UnboxCustom<FieldValue>(value);
}

const FieldPath& GetCustomFieldPath(FlValue* value) {
  return UnboxCustom<FieldPath>(value);
}

std::map<std::string, std::unique_ptr<Firestore>>& FirestoreInstanceCache() {
  static std::map<std::string, std::unique_ptr<Firestore>> instances;
  return instances;
}

FieldValue ConvertToFieldValue(FlValue* value) {
  switch (fl_value_get_type(value)) {
    case FL_VALUE_TYPE_NULL:
      return FieldValue::Null();
    case FL_VALUE_TYPE_BOOL:
      return FieldValue::Boolean(fl_value_get_bool(value));
    case FL_VALUE_TYPE_INT:
      return FieldValue::Integer(fl_value_get_int(value));
    case FL_VALUE_TYPE_FLOAT:
      return FieldValue::Double(fl_value_get_float(value));
    case FL_VALUE_TYPE_STRING:
      return FieldValue::String(fl_value_get_string(value));
    case FL_VALUE_TYPE_UINT8_LIST:
      // Improvement over Windows (which throws for typed-data lists): a raw
      // Uint8List maps naturally onto a Firestore blob.
      return FieldValue::Blob(fl_value_get_uint8_list(value),
                              fl_value_get_length(value));
    case FL_VALUE_TYPE_LIST: {
      std::vector<FieldValue> converted_list;
      size_t length = fl_value_get_length(value);
      for (size_t i = 0; i < length; ++i) {
        converted_list.push_back(
            ConvertToFieldValue(fl_value_get_list_value(value, i)));
      }
      return FieldValue::Array(converted_list);
    }
    case FL_VALUE_TYPE_MAP:
      return FieldValue::Map(ConvertToMapFieldValue(value));
    case FL_VALUE_TYPE_CUSTOM: {
      switch (fl_value_get_custom_type(value)) {
        case FirestoreCodec::DATA_TYPE_FIELD_VALUE:
          return UnboxCustom<FieldValue>(value);
        case FirestoreCodec::DATA_TYPE_TIMESTAMP:
          return FieldValue::Timestamp(UnboxCustom<Timestamp>(value));
        case FirestoreCodec::DATA_TYPE_GEO_POINT:
          return FieldValue::GeoPoint(UnboxCustom<GeoPoint>(value));
        case FirestoreCodec::DATA_TYPE_DOCUMENT_REFERENCE:
          return FieldValue::Reference(UnboxCustom<DocumentReference>(value));
        default:
          throw std::runtime_error("Unsupported custom FlValue type");
      }
    }
    default:
      // Add more types as needed
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported FlValue type");
  }
}

std::vector<FieldValue> ConvertToFieldValueList(FlValue* list) {
  std::vector<FieldValue> converted_list;
  size_t length = fl_value_get_length(list);
  for (size_t i = 0; i < length; ++i) {
    converted_list.push_back(
        ConvertToFieldValue(fl_value_get_list_value(list, i)));
  }
  return converted_list;
}

firebase::firestore::MapFieldValue ConvertToMapFieldValue(FlValue* map) {
  firebase::firestore::MapFieldValue converted_map;

  size_t length = fl_value_get_length(map);
  for (size_t i = 0; i < length; ++i) {
    FlValue* key = fl_value_get_map_key(map, i);
    if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING) {
      converted_map[fl_value_get_string(key)] =
          ConvertToFieldValue(fl_value_get_map_value(map, i));
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return converted_map;
}

firebase::firestore::MapFieldPathValue ConvertToMapFieldPathValue(
    FlValue* map) {
  firebase::firestore::MapFieldPathValue converted_map;

  size_t length = fl_value_get_length(map);
  for (size_t i = 0; i < length; ++i) {
    FlValue* key = fl_value_get_map_key(map, i);
    FlValue* value = fl_value_get_map_value(map, i);
    if (fl_value_get_type(key) == FL_VALUE_TYPE_STRING) {
      std::vector<std::string> converted_list;
      converted_list.push_back(fl_value_get_string(key));
      converted_map[FieldPath(converted_list)] = ConvertToFieldValue(value);
    } else if (fl_value_get_type(key) == FL_VALUE_TYPE_CUSTOM &&
               fl_value_get_custom_type(key) ==
                   FirestoreCodec::DATA_TYPE_FIELD_PATH) {
      converted_map[UnboxCustom<FieldPath>(key)] = ConvertToFieldValue(value);
    } else {
      // Handle or skip non-string keys
      // You may throw an exception or handle this some other way
      throw std::runtime_error("Unsupported key type");
    }
  }

  return converted_map;
}

std::vector<FieldPath> ConvertToFieldPathVector(FlValue* list) {
  std::vector<FieldPath> field_vector;

  size_t length = fl_value_get_length(list);
  for (size_t i = 0; i < length; ++i) {
    FlValue* field_path = fl_value_get_list_value(list, i);

    std::vector<std::string> converted_list;
    size_t path_length = fl_value_get_length(field_path);
    for (size_t j = 0; j < path_length; ++j) {
      converted_list.push_back(
          fl_value_get_string(fl_value_get_list_value(field_path, j)));
    }

    // Was already converted by the Codec
    field_vector.push_back(FieldPath(converted_list));
  }

  return field_vector;
}

FlValue* ConvertFieldValueToFlValue(const FieldValue& field_value) {
  switch (field_value.type()) {
    case FieldValue::Type::kNull:
      return fl_value_new_null();

    case FieldValue::Type::kBoolean:
      return fl_value_new_bool(field_value.boolean_value());

    case FieldValue::Type::kInteger:
      return fl_value_new_int(field_value.integer_value());

    case FieldValue::Type::kDouble:
      return fl_value_new_float(field_value.double_value());

    case FieldValue::Type::kTimestamp:
      return CustomTimestamp(field_value.timestamp_value());

    case FieldValue::Type::kString:
      return fl_value_new_string(field_value.string_value().c_str());

    case FieldValue::Type::kBlob:
      return fl_value_new_uint8_list(field_value.blob_value(),
                                     field_value.blob_size());

    case FieldValue::Type::kMap: {
      FlValue* map = fl_value_new_map();
      for (const auto& kv : field_value.map_value()) {
        fl_value_set_take(map, fl_value_new_string(kv.first.c_str()),
                          ConvertFieldValueToFlValue(kv.second));
      }
      return map;
    }

    case FieldValue::Type::kArray: {
      FlValue* list = fl_value_new_list();
      for (const auto& item : field_value.array_value()) {
        fl_value_append_take(list, ConvertFieldValueToFlValue(item));
      }
      return list;
    }

    case FieldValue::Type::kGeoPoint:
      return CustomGeoPoint(field_value.geo_point_value());

    case FieldValue::Type::kReference:
      return CustomDocumentReference(field_value.reference_value());

    default:
      return fl_value_new_null();
  }
}

FlValue* ConvertMapFieldValueToFlValue(
    const firebase::firestore::MapFieldValue& map) {
  FlValue* converted_map = fl_value_new_map();
  for (const auto& kv : map) {
    fl_value_set_take(converted_map, fl_value_new_string(kv.first.c_str()),
                      ConvertFieldValueToFlValue(kv.second));
  }
  return converted_map;
}

}  // namespace cloud_firestore_linux

using cloud_firestore_linux::ConvertToFieldValueList;
using cloud_firestore_linux::CustomDocumentReference;
using cloud_firestore_linux::CustomFieldPath;
using cloud_firestore_linux::CustomFieldValue;
using cloud_firestore_linux::FirestoreCodec;
using cloud_firestore_linux::FirestoreInstanceCache;

gboolean firestore_codec_write_value(FlStandardMessageCodec* codec,
                                     GByteArray* buffer, FlValue* value,
                                     GError** error) {
  if (value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {
    switch (fl_value_get_custom_type(value)) {
      case FirestoreCodec::DATA_TYPE_TIMESTAMP: {
        const Timestamp& timestamp =
            *static_cast<const Timestamp*>(fl_value_get_custom_value(value));
        uint8_t type_byte = FirestoreCodec::DATA_TYPE_TIMESTAMP;
        int64_t seconds = timestamp.seconds();
        int32_t nanoseconds = timestamp.nanoseconds();
        g_byte_array_append(buffer, &type_byte, 1);
        cloud_firestore_linux::WriteBytes(buffer, &seconds, sizeof(seconds));
        cloud_firestore_linux::WriteBytes(buffer, &nanoseconds,
                                          sizeof(nanoseconds));
        return TRUE;
      }
      case FirestoreCodec::DATA_TYPE_GEO_POINT: {
        const GeoPoint& geo_point =
            *static_cast<const GeoPoint*>(fl_value_get_custom_value(value));
        uint8_t type_byte = FirestoreCodec::DATA_TYPE_GEO_POINT;
        g_byte_array_append(buffer, &type_byte, 1);
        cloud_firestore_linux::WriteAlignment(buffer, 8);
        double latitude = geo_point.latitude();
        double longitude = geo_point.longitude();
        cloud_firestore_linux::WriteBytes(buffer, &latitude, sizeof(latitude));
        cloud_firestore_linux::WriteBytes(buffer, &longitude,
                                          sizeof(longitude));
        return TRUE;
      }
      case FirestoreCodec::DATA_TYPE_DOCUMENT_REFERENCE: {
        const DocumentReference& reference =
            *static_cast<const DocumentReference*>(
                fl_value_get_custom_value(value));
        uint8_t type_byte = FirestoreCodec::DATA_TYPE_DOCUMENT_REFERENCE;
        g_byte_array_append(buffer, &type_byte, 1);
        const Firestore* firestore = reference.firestore();
        std::string app_name = firestore->app()->name();
        std::string database_url = "(default)";
        if (!cloud_firestore_linux::WriteStringValue(codec, buffer, app_name,
                                                     error) ||
            !cloud_firestore_linux::WriteStringValue(codec, buffer,
                                                     reference.path(), error) ||
            !cloud_firestore_linux::WriteStringValue(codec, buffer,
                                                     database_url, error)) {
          return FALSE;
        }
        return TRUE;
      }
    }
  }

  return cloud_firestore_linux::StandardCodecClass()->write_value(codec, buffer,
                                                                  value, error);
}

FlValue* firestore_codec_read_value_of_type(FlStandardMessageCodec* codec,
                                            GBytes* buffer, size_t* offset,
                                            int type, GError** error) {
  switch (type) {
    case FirestoreCodec::DATA_TYPE_DATE_TIME: {
      int64_t value;
      if (!cloud_firestore_linux::ReadBytes(buffer, offset, &value,
                                            sizeof(value), error)) {
        return nullptr;
      }
      return CustomFieldValue(
          FieldValue::Timestamp(Timestamp(value / 1000, 0)));
    }

    case FirestoreCodec::DATA_TYPE_TIMESTAMP: {
      int64_t seconds;
      int32_t nanoseconds;
      if (!cloud_firestore_linux::ReadBytes(buffer, offset, &seconds,
                                            sizeof(seconds), error) ||
          !cloud_firestore_linux::ReadBytes(buffer, offset, &nanoseconds,
                                            sizeof(nanoseconds), error)) {
        return nullptr;
      }
      return CustomFieldValue(
          FieldValue::Timestamp(Timestamp(seconds, nanoseconds)));
    }

    case FirestoreCodec::DATA_TYPE_DOCUMENT_REFERENCE: {
      g_autoptr(FlValue) firestore_value =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (firestore_value == nullptr ||
          fl_value_get_type(firestore_value) != FL_VALUE_TYPE_CUSTOM ||
          fl_value_get_custom_type(firestore_value) !=
              FirestoreCodec::DATA_TYPE_FIRESTORE_INSTANCE) {
        g_set_error(error, FL_MESSAGE_CODEC_ERROR,
                    FL_MESSAGE_CODEC_ERROR_FAILED,
                    "Expected Firestore instance");
        return nullptr;
      }
      Firestore* firestore = *static_cast<Firestore* const*>(
          fl_value_get_custom_value(firestore_value));

      std::string path =
          cloud_firestore_linux::ReadNestedString(codec, buffer, offset, error);
      if (error != nullptr && *error != nullptr) {
        return nullptr;
      }

      return CustomDocumentReference(firestore->Document(path));
    }

    case FirestoreCodec::DATA_TYPE_GEO_POINT: {
      double latitude;
      double longitude;
      cloud_firestore_linux::ReadAlignment(offset, 8);
      if (!cloud_firestore_linux::ReadBytes(buffer, offset, &latitude,
                                            sizeof(latitude), error) ||
          !cloud_firestore_linux::ReadBytes(buffer, offset, &longitude,
                                            sizeof(longitude), error)) {
        return nullptr;
      }
      return CustomFieldValue(
          FieldValue::GeoPoint(GeoPoint(latitude, longitude)));
    }

    case FirestoreCodec::DATA_TYPE_FIELD_PATH: {
      uint32_t length;
      if (!fl_standard_message_codec_read_size(codec, buffer, offset, &length,
                                               error)) {
        return nullptr;
      }
      std::vector<std::string> array;
      for (uint32_t i = 0; i < length; ++i) {
        array.push_back(cloud_firestore_linux::ReadNestedString(codec, buffer,
                                                                offset, error));
        if (error != nullptr && *error != nullptr) {
          return nullptr;
        }
      }
      return CustomFieldPath(FieldPath(array));
    }

    case FirestoreCodec::DATA_TYPE_BLOB: {
      uint32_t length;
      if (!fl_standard_message_codec_read_size(codec, buffer, offset, &length,
                                               error)) {
        return nullptr;
      }
      std::vector<uint8_t> blob_data(length);
      if (length > 0 && !cloud_firestore_linux::ReadBytes(
                            buffer, offset, blob_data.data(), length, error)) {
        return nullptr;
      }
      return CustomFieldValue(FieldValue::Blob(blob_data.data(), length));
    }

    case FirestoreCodec::DATA_TYPE_ARRAY_UNION: {
      g_autoptr(FlValue) values =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (values == nullptr) {
        return nullptr;
      }
      return CustomFieldValue(
          FieldValue::ArrayUnion(ConvertToFieldValueList(values)));
    }

    case FirestoreCodec::DATA_TYPE_ARRAY_REMOVE: {
      g_autoptr(FlValue) values =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (values == nullptr) {
        return nullptr;
      }
      return CustomFieldValue(
          FieldValue::ArrayRemove(ConvertToFieldValueList(values)));
    }

    case FirestoreCodec::DATA_TYPE_DELETE:
      return CustomFieldValue(FieldValue::Delete());

    case FirestoreCodec::DATA_TYPE_SERVER_TIMESTAMP:
      return CustomFieldValue(FieldValue::ServerTimestamp());

    case FirestoreCodec::DATA_TYPE_INCREMENT_DOUBLE: {
      g_autoptr(FlValue) value =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (value == nullptr) {
        return nullptr;
      }
      return CustomFieldValue(FieldValue::Increment(fl_value_get_float(value)));
    }

    case FirestoreCodec::DATA_TYPE_INCREMENT_INTEGER: {
      g_autoptr(FlValue) value =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (value == nullptr) {
        return nullptr;
      }
      return CustomFieldValue(FieldValue::Increment(fl_value_get_int(value)));
    }

    case FirestoreCodec::DATA_TYPE_DOCUMENT_ID:
      return CustomFieldPath(FieldPath::DocumentId());

    case FirestoreCodec::DATA_TYPE_FIRESTORE_INSTANCE: {
      std::string app_name =
          cloud_firestore_linux::ReadNestedString(codec, buffer, offset, error);
      if (error != nullptr && *error != nullptr) {
        return nullptr;
      }
      std::string database_url =
          cloud_firestore_linux::ReadNestedString(codec, buffer, offset, error);
      if (error != nullptr && *error != nullptr) {
        return nullptr;
      }
      g_autoptr(FlValue) settings_value =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (settings_value == nullptr ||
          fl_value_get_type(settings_value) != FL_VALUE_TYPE_CUSTOM ||
          fl_value_get_custom_type(settings_value) !=
              FirestoreCodec::DATA_TYPE_FIRESTORE_SETTINGS) {
        g_set_error(error, FL_MESSAGE_CODEC_ERROR,
                    FL_MESSAGE_CODEC_ERROR_FAILED,
                    "Expected Firestore settings");
        return nullptr;
      }
      const firebase::firestore::Settings& settings =
          *static_cast<const firebase::firestore::Settings*>(
              fl_value_get_custom_value(settings_value));

      // Use composite key matching GetFirestoreFromPigeon to avoid
      // creating a duplicate unique_ptr for the same Firestore instance.
      // See https://github.com/firebase/flutterfire/issues/18028
      std::string cache_key = app_name + "-" + database_url;

      auto& instances = FirestoreInstanceCache();
      if (instances.find(cache_key) == instances.end()) {
        firebase::App* app = firebase::App::GetInstance(app_name.c_str());
        Firestore* firestore =
            Firestore::GetInstance(app, database_url.c_str());
        firestore->set_settings(settings);
        instances[cache_key] = std::unique_ptr<Firestore>(firestore);
      }
      Firestore* firestore = instances[cache_key].get();

      return fl_value_new_custom(FirestoreCodec::DATA_TYPE_FIRESTORE_INSTANCE,
                                 new Firestore*(firestore), [](gpointer boxed) {
                                   delete static_cast<Firestore**>(boxed);
                                 });
    }

    case FirestoreCodec::DATA_TYPE_FIRESTORE_SETTINGS: {
      g_autoptr(FlValue) settings_map =
          cloud_firestore_linux::ReadNestedValue(codec, buffer, offset, error);
      if (settings_map == nullptr) {
        return nullptr;
      }
      firebase::firestore::Settings settings =
          cloud_firestore_linux::SettingsFromFlValueMap(settings_map);
      return fl_value_new_custom(
          FirestoreCodec::DATA_TYPE_FIRESTORE_SETTINGS,
          new firebase::firestore::Settings(settings), [](gpointer boxed) {
            delete static_cast<firebase::firestore::Settings*>(boxed);
          });
    }

    case FirestoreCodec::DATA_TYPE_NAN:
      return fl_value_new_float(std::nan("1"));

    case FirestoreCodec::DATA_TYPE_INFINITY:
      return fl_value_new_float(std::numeric_limits<double>::infinity());

    case FirestoreCodec::DATA_TYPE_NEGATIVE_INFINITY:
      return fl_value_new_float(-std::numeric_limits<double>::infinity());
  }

  return cloud_firestore_linux::StandardCodecClass()->read_value_of_type(
      codec, buffer, offset, type, error);
}
