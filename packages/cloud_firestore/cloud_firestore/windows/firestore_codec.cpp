#include "firestore_codec.h"

#include "firebase/firestore/field_value.h"
#include "firebase/firestore/timestamp.h"
#include "firebase/firestore/field_path.h"

using firebase::firestore::FieldValue;
using firebase::Timestamp;
using firebase::firestore::FieldPath;

using flutter::EncodableValue;
using flutter::CustomEncodableValue;

cloud_firestore_windows::FirestoreCodec::FirestoreCodec() {}

void cloud_firestore_windows::FirestoreCodec::WriteValue(
    const flutter::EncodableValue& value,
    flutter::ByteStreamWriter* stream) const {}

flutter::EncodableValue
cloud_firestore_windows::FirestoreCodec::ReadValueOfType(
    uint8_t type, flutter::ByteStreamReader* stream) const {
  switch (type) {
    case DATA_TYPE_DATE_TIME: {
      int64_t value;
      // Read 8 bytes into value, this will depend on your stream
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&value),
                        8);  // Read 8 bytes into value

      return CustomEncodableValue(FieldValue::Timestamp(Timestamp::FromTimeT(value)));
    }

    case DATA_TYPE_FIELD_PATH: {
      uint32_t length;  // UInt32 in Objective-C
      stream->ReadBytes(reinterpret_cast<uint8_t*>(&length),
                        4);  // Read 4 bytes into length

      std::vector<std::string> array;  
      array.reserve(length);

      for (uint32_t i = 0; i < length; ++i) {
        auto byte = stream->ReadByte();

        if (byte) {
          std::string byteAsString(1, static_cast<char>(byte));

          array.push_back(byteAsString);
        } else {
          array.push_back(nullptr);
        }
      }

      FieldPath fieldPath(array);

      return CustomEncodableValue(fieldPath);
    }
  }
  return EncodableValue();
}
