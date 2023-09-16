#include "firestore_codec.h"

#include "firebase/app.h"
#include "firebase/firestore/field_value.h"
#include "firebase/firestore/timestamp.h"
#include "firebase/firestore/field_path.h"
#include "firebase/firestore/geo_point.h"
#include "firebase/firestore.h"
#include "cloud_firestore_plugin.h"

#include <map>
#include <optional>
#include <string>
#include <memory>

using firebase::firestore::FieldValue;
using firebase::Timestamp;
using firebase::firestore::FieldPath;
using firebase::firestore::GeoPoint;
using firebase::firestore::DocumentReference;
using firebase::firestore::Firestore;

using flutter::EncodableValue;
using flutter::CustomEncodableValue;


cloud_firestore_windows::FirestoreCodec::FirestoreCodec() {}

void cloud_firestore_windows::FirestoreCodec::WriteValue(
    const flutter::EncodableValue& value,
    flutter::ByteStreamWriter* stream) const {

  if (std::holds_alternative<CustomEncodableValue>(value)) {
    const CustomEncodableValue& custom_value = std::get<CustomEncodableValue>(value);
    if (custom_value.type() == typeid(Timestamp)) {
      const Timestamp& timestamp = std::any_cast<Timestamp>(custom_value);
      stream->WriteByte(DATA_TYPE_TIMESTAMP);
      stream->WriteInt64(timestamp.seconds());
      stream->WriteInt32(timestamp.nanoseconds());
    } else if (custom_value.type() == typeid(GeoPoint)) {
      const GeoPoint& geopoint = std::any_cast<GeoPoint>(custom_value);
      stream->WriteByte(DATA_TYPE_GEO_POINT);
      stream->WriteAlignment(8);
      flutter::StandardCodecSerializer::WriteValue(geopoint.latitude(), stream);
      flutter::StandardCodecSerializer::WriteValue(geopoint.longitude(),
                                                   stream);
    } else if (custom_value.type() == typeid(DocumentReference)) {
      const DocumentReference& reference = std::any_cast<DocumentReference>(custom_value);
      stream->WriteByte(DATA_TYPE_DOCUMENT_REFERENCE);
      const Firestore* firestore = reference.firestore();
      std::string appName = firestore->app()->name();
      flutter::StandardCodecSerializer::WriteValue(appName, stream);
          flutter::StandardCodecSerializer::WriteValue(
                                                       reference.path(), stream);
      flutter::StandardCodecSerializer::WriteValue(nullptr, stream);
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

      return CustomEncodableValue(FieldValue::Timestamp(Timestamp(value, 0)));
    }

    case DATA_TYPE_TIMESTAMP: {
      int64_t seconds;
      int nanoseconds;

      stream->ReadBytes(reinterpret_cast<uint8_t*>(&seconds),
                        8); 
            stream->ReadBytes(reinterpret_cast<uint8_t*>(&nanoseconds), 4); 

      return CustomEncodableValue(
          FieldValue::Timestamp(Timestamp(seconds, nanoseconds)));
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
        array.push_back(std::get<std::string>(FirestoreCodec::ReadValue(stream)));
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
      const std::vector<FieldValue>& arrayUnionValue =
          std::any_cast<std::vector<FieldValue>>(
              std::get<CustomEncodableValue>(
          FirestoreCodec::ReadValue(stream)));
      return CustomEncodableValue(FieldValue::ArrayUnion(arrayUnionValue));
    }

    case DATA_TYPE_ARRAY_REMOVE: {
      const std::vector<FieldValue>& arrayRemoveValue =
          std::any_cast<std::vector<FieldValue>>(std::get<CustomEncodableValue>(
              FirestoreCodec::ReadValue(stream)));
      return CustomEncodableValue(FieldValue::ArrayRemove(arrayRemoveValue));
    }

    case DATA_TYPE_DELETE: {
      return CustomEncodableValue(FieldValue::Delete());
    }

    case DATA_TYPE_SERVER_TIMESTAMP: {
      return CustomEncodableValue(FieldValue::ServerTimestamp());
    }

    case DATA_TYPE_INCREMENT_DOUBLE: {
      double incrementValue = stream->ReadDouble();
      return CustomEncodableValue(FieldValue::Increment(incrementValue));
    }

    case DATA_TYPE_INCREMENT_INTEGER: {
      int incrementValue = stream->ReadInt32();
      return CustomEncodableValue(FieldValue::Increment(incrementValue));
    }

    case DATA_TYPE_DOCUMENT_ID: {
      return CustomEncodableValue(FieldPath::DocumentId());
    }

    case DATA_TYPE_FIRESTORE_INSTANCE: {
      std::string appName = std::get<std::string>(FirestoreCodec::ReadValue(stream));
      std::string databaseUrl = std::get<std::string>(FirestoreCodec::ReadValue(stream));
      const firebase::firestore::Settings& settings =
          std::any_cast<firebase::firestore::Settings>(
              std::get<CustomEncodableValue>(
              FirestoreCodec::ReadValue(stream)));

      // Print out the settings
      std::cout << "Host: " << settings.host() << std::endl;

      if (CloudFirestorePlugin::firestoreInstances_[appName] != nullptr) {
          return CustomEncodableValue(CloudFirestorePlugin::firestoreInstances_[appName]);
      }

        firebase::AppOptions options;

      options.set_database_url(databaseUrl.c_str());

      firebase::App* app =
          firebase::App::Create(options, appName.c_str());

      Firestore* firestore = Firestore::GetInstance(app);

      return CustomEncodableValue(firestore);
    }

    //case DATA_TYPE_FIRESTORE_QUERY: {
    //  return CustomEncodableValue(ReadFirestoreQuery(stream));
    //}

    case DATA_TYPE_FIRESTORE_SETTINGS: {
      flutter::EncodableMap settingsMap =
          std::get<flutter::EncodableMap>(FirestoreCodec::ReadValue(stream));
      return CustomEncodableValue(firebase::firestore::Settings());
    }

    case DATA_TYPE_NAN: {
      return CustomEncodableValue(std::nan(""));
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