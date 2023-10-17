/*
 * Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef FIRESTORE_CODEC_H_
#define FIRESTORE_CODEC_H_

#include <flutter/basic_message_channel.h>
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/standard_message_codec.h>

#include <map>
#include <memory>
#include <optional>
#include <string>

#include "firebase/firestore/field_value.h"

namespace cloud_firestore_windows {
class FirestoreCodec : public flutter::StandardCodecSerializer {
 public:
  static const uint8_t DATA_TYPE_DATE_TIME = 180;
  static const uint8_t DATA_TYPE_GEO_POINT = 181;
  static const uint8_t DATA_TYPE_DOCUMENT_REFERENCE = 182;
  static const uint8_t DATA_TYPE_BLOB = 183;
  static const uint8_t DATA_TYPE_ARRAY_UNION = 184;
  static const uint8_t DATA_TYPE_ARRAY_REMOVE = 185;
  static const uint8_t DATA_TYPE_DELETE = 186;
  static const uint8_t DATA_TYPE_SERVER_TIMESTAMP = 187;
  static const uint8_t DATA_TYPE_TIMESTAMP = 188;
  static const uint8_t DATA_TYPE_INCREMENT_DOUBLE = 189;
  static const uint8_t DATA_TYPE_INCREMENT_INTEGER = 190;
  static const uint8_t DATA_TYPE_DOCUMENT_ID = 191;
  static const uint8_t DATA_TYPE_FIELD_PATH = 192;
  static const uint8_t DATA_TYPE_NAN = 193;
  static const uint8_t DATA_TYPE_INFINITY = 194;
  static const uint8_t DATA_TYPE_NEGATIVE_INFINITY = 195;
  static const uint8_t DATA_TYPE_FIRESTORE_INSTANCE = 196;
  static const uint8_t DATA_TYPE_FIRESTORE_QUERY = 197;
  static const uint8_t DATA_TYPE_FIRESTORE_SETTINGS = 198;

  FirestoreCodec();
  inline static FirestoreCodec& GetInstance() {
    static FirestoreCodec sInstance;
    return sInstance;
  }

  void WriteValue(const flutter::EncodableValue& value,
                  flutter::ByteStreamWriter* stream) const override;

 protected:
  flutter::EncodableValue ReadValueOfType(
      uint8_t type, flutter::ByteStreamReader* stream) const override;
};
}  // namespace cloud_firestore_windows

#endif  // FIRESTORE_CODEC_H_
