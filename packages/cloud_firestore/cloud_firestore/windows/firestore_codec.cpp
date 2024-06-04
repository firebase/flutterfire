// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firestore_codec.h"

#include <map>
#include <memory>
#include <optional>
#include <string>

#include "cloud_firestore_plugin.h"
#include "firebase/app.h"
#include "firebase/firestore.h"
#include "firebase/firestore/field_path.h"
#include "firebase/firestore/field_value.h"
#include "firebase/firestore/geo_point.h"
#include "firebase/firestore/timestamp.h"

using firebase::Timestamp;
using firebase::firestore::DocumentReference;
using firebase::firestore::FieldPath;
using firebase::firestore::FieldValue;
using firebase::firestore::Firestore;
using firebase::firestore::GeoPoint;

using flutter::CustomEncodableValue;
using flutter::EncodableValue;

cloud_firestore_windows::FirestoreCodec::FirestoreCodec() {}

union DoubleToBytes {
  double value;
  uint8_t bytes[sizeof(double)];
};

void cloud_firestore_windows::FirestoreCodec::WriteValue(
    const flutter::EncodableValue& value,
    flutter::ByteStreamWriter* stream) const {
  if (std::holds_alternative<CustomEncodableValue>(value)) {
    const CustomEncodableValue& custom_value =
        std::get<CustomEncodableValue>(value);
    if (custom_value.type() == typeid(Timestamp)) {
      const Timestamp& timestamp = std::any_cast<Timestamp>(custom_value);
      stream->WriteByte(DATA_TYPE_TIMESTAMP);
      stream->WriteInt64(timestamp.seconds());
      stream->WriteInt32(timestamp.nanoseconds());
    } else if (custom_value.type() == typeid(GeoPoint)) {
      const GeoPoint& geopoint = std::any_cast<GeoPoint>(custom_value);
      stream->WriteByte(DATA_TYPE_GEO_POINT);
      stream->WriteAlignment(8);
      DoubleToBytes converterLatitude;
      converterLatitude.value = geopoint.latitude();
      stream->WriteBytes(converterLatitude.bytes, 8);
      DoubleToBytes converterLongitude;
      converterLongitude.value = geopoint.longitude();
      stream->WriteBytes(converterLongitude.bytes, 8);
    } else if (custom_value.type() == typeid(DocumentReference)) {
      const DocumentReference& reference =
          std::any_cast<DocumentReference>(custom_value);
      stream->WriteByte(DATA_TYPE_DOCUMENT_REFERENCE);
      const Firestore* firestore = reference.firestore();
      std::string appName = firestore->app()->name();
      std::string databaseUrl = "(default)";
      flutter::StandardCodecSerializer::WriteValue(appName, stream);
      flutter::StandardCodecSerializer::WriteValue(reference.path(), stream);
      flutter::StandardCodecSerializer::WriteValue(databaseUrl, stream);
    } else if (custom_value.type() ==
               typeid(double)) {  // Assuming Double is standard C++ double
      const double& myDouble = std::any_cast<double>(custom_value);
      if (std::isnan(myDouble)) {
        stream->WriteByte(DATA_TYPE_NAN);
      } else if (myDouble == std::numeric_limits<double>::infinity()) {
        stream->WriteByte(DATA_TYPE_INFINITY);
      } else if (myDouble == -std::numeric_limits<double>::infinity()) {
        stream->WriteByte(DATA_TYPE_NEGATIVE_INFINITY);
      } else {
        flutter::StandardCodecSerializer::WriteValue(custom_value, stream);
      }
    }
  } else {
    flutter::StandardCodecSerializer::WriteValue(value, stream);
  }
}

flutter::EncodableValue
cloud_firestore_windows::FirestoreCodec::ReadValueOfType(
    uint8_t type, flutter::ByteStreamReader* stream) const {
  switch (type) {
    case DATA_TYPE_DATE_TIME: {
      int64_t value;
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&value),
                        8);  // Read 8 bytes into value

      return CustomEncodableValue(
          FieldValue::Timestamp(Timestamp(value / 1000, 0)));
    }

    case DATA_TYPE_TIMESTAMP: {
      int64_t seconds;
      int nanoseconds;

      stream->ReadBytes(reinterpret_cast<uint8_t*>(&seconds), 8);
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&nanoseconds), 4);

      return CustomEncodableValue(
          FieldValue::Timestamp(Timestamp(seconds, nanoseconds)));
    }
    case DATA_TYPE_DOCUMENT_REFERENCE: {
      auto customValue =
          std::get<CustomEncodableValue>(FirestoreCodec::ReadValue(stream));

      Firestore* firestoreRef = std::any_cast<Firestore*>(customValue);

      std::string path =
          std::get<std::string>(FirestoreCodec::ReadValue(stream));

      DocumentReference reference = firestoreRef->Document(path);
      return CustomEncodableValue(reference);
    }
    case DATA_TYPE_GEO_POINT: {
      double latitude;
      double longitude;

      stream->ReadAlignment(8);
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&latitude), 8);
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&longitude), 8);

      return CustomEncodableValue(
          FieldValue::GeoPoint(GeoPoint(latitude, longitude)));
    }

    case DATA_TYPE_FIELD_PATH: {
      size_t length = flutter::StandardCodecSerializer::ReadSize(stream);
      std::vector<std::string> array;

      for (uint32_t i = 0; i < length; ++i) {
        array.push_back(
            std::get<std::string>(FirestoreCodec::ReadValue(stream)));
      }

      FieldPath fieldPath(array);
      return CustomEncodableValue(fieldPath);
    }

    case DATA_TYPE_BLOB: {
      // Assume that readSize and ReadBytes are defined to read the blob's size
      // and data
      size_t length = flutter::StandardCodecSerializer::ReadSize(stream);
      std::vector<uint8_t> blobData(length);
      stream->ReadBytes(blobData.data(), length);

      return CustomEncodableValue(FieldValue::Blob(blobData.data(), length));
    }

    case DATA_TYPE_ARRAY_UNION: {
      auto customValue =
          std::get<flutter::EncodableList>(FirestoreCodec::ReadValue(stream));
      std::vector<FieldValue> arrayUnionValue;

      for (auto& value : customValue) {
        arrayUnionValue.push_back(
            cloud_firestore_windows::CloudFirestorePlugin::ConvertToFieldValue(
                value));
      }
      return CustomEncodableValue(FieldValue::ArrayUnion(arrayUnionValue));
    }

    case DATA_TYPE_ARRAY_REMOVE: {
      auto customValue =
          std::get<flutter::EncodableList>(FirestoreCodec::ReadValue(stream));
      std::vector<FieldValue> arrayRemoveValue;

      for (auto& value : customValue) {
        arrayRemoveValue.push_back(
            cloud_firestore_windows::CloudFirestorePlugin::ConvertToFieldValue(
                value));
      }
      return CustomEncodableValue(FieldValue::ArrayRemove(arrayRemoveValue));
    }

    case DATA_TYPE_DELETE: {
      return CustomEncodableValue(FieldValue::Delete());
    }

    case DATA_TYPE_SERVER_TIMESTAMP: {
      return CustomEncodableValue(FieldValue::ServerTimestamp());
    }

    case DATA_TYPE_INCREMENT_DOUBLE: {
      double incrementValue =
          std::get<double>(FirestoreCodec::ReadValue(stream));
      return CustomEncodableValue(FieldValue::Increment(incrementValue));
    }

    case DATA_TYPE_INCREMENT_INTEGER: {
      int incrementValue = std::get<int>(FirestoreCodec::ReadValue(stream));
      return CustomEncodableValue(FieldValue::Increment(incrementValue));
    }

    case DATA_TYPE_DOCUMENT_ID: {
      return CustomEncodableValue(FieldPath::DocumentId());
    }

    case DATA_TYPE_FIRESTORE_INSTANCE: {
      std::string appName =
          std::get<std::string>(FirestoreCodec::ReadValue(stream));
      std::string databaseUrl =
          std::get<std::string>(FirestoreCodec::ReadValue(stream));
      const firebase::firestore::Settings& settings =
          std::any_cast<firebase::firestore::Settings>(
              std::get<CustomEncodableValue>(
                  FirestoreCodec::ReadValue(stream)));

      if (CloudFirestorePlugin::firestoreInstances_.find(appName) !=
          CloudFirestorePlugin::firestoreInstances_.end()) {
        return CustomEncodableValue(
            CloudFirestorePlugin::firestoreInstances_[appName].get());
      }

      firebase::App* app = firebase::App::GetInstance(appName.c_str());

      Firestore* firestore = Firestore::GetInstance(app);
      firestore->set_settings(settings);

      CloudFirestorePlugin::firestoreInstances_[appName] =
          std::unique_ptr<firebase::firestore::Firestore>(firestore);

      return CustomEncodableValue(firestore);
    }

      // case DATA_TYPE_FIRESTORE_QUERY: {
      //   return CustomEncodableValue(ReadFirestoreQuery(stream));
      // }

    case DATA_TYPE_FIRESTORE_SETTINGS: {
      flutter::EncodableMap settingsMap =
          std::get<flutter::EncodableMap>(FirestoreCodec::ReadValue(stream));

      firebase::firestore::Settings settings;

      std::map<std::string, flutter::EncodableValue> map;

      for (const auto& kv : settingsMap) {
        if (std::holds_alternative<std::string>(kv.first)) {
          std::string key = std::get<std::string>(kv.first);

          if (!std::holds_alternative<std::monostate>(kv.second)) {
            map[key] = kv.second;
          }
        } else {
          // Handle or skip non-string keys
          // You may throw an exception or handle this some other way
          throw std::runtime_error("Unsupported key type");
        }
      }

      if (map.count("persistenceEnabled")) {
        bool persistEnabled = std::get<bool>(map["persistenceEnabled"]);

        // This is the maximum amount of cache allowed. We use the same number
        // on android.
        int64_t size = 104857600;

        if (map.count("cacheSizeBytes")) {
          int64_t cacheSizeBytes = std::get<int64_t>(map["cacheSizeBytes"]);
          if (cacheSizeBytes != -1) {
            size = cacheSizeBytes;
          }
        }

        if (persistEnabled) {
          settings.set_cache_size_bytes(size);
        }
      }

      if (map.count("host")) {
        settings.set_host(std::get<std::string>(map["host"]));

        settings.set_ssl_enabled(false);
      }

      return CustomEncodableValue(settings);
    }

    case DATA_TYPE_NAN: {
      double myNaN = std::nan("1");
      return CustomEncodableValue(myNaN);
    }

    case DATA_TYPE_INFINITY: {
      return CustomEncodableValue(std::numeric_limits<double>::infinity());
    }

    case DATA_TYPE_NEGATIVE_INFINITY: {
      return CustomEncodableValue(-std::numeric_limits<double>::infinity());
    }
  }
  return flutter::StandardCodecSerializer::ReadValueOfType(type, stream);
}
