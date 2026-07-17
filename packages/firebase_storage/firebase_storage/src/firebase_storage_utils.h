// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef FIREBASE_STORAGE_SRC_FIREBASE_STORAGE_UTILS_H_
#define FIREBASE_STORAGE_SRC_FIREBASE_STORAGE_UTILS_H_

#include <cstdint>
#include <string>
#include <vector>

#include "firebase/storage/common.h"

// Platform-agnostic helpers shared between the Windows and Linux
// implementations of the firebase_storage plugin. These only depend on the
// Firebase C++ SDK and the standard library (no flutter:: or FlValue types).
namespace firebase_storage_desktop {

// Maps a Firebase Storage C++ SDK error to the FlutterFire error code string.
std::string GetStorageErrorCode(firebase::storage::Error storage_error);

// Maps a Firebase Storage C++ SDK error to a human readable error message.
std::string GetStorageErrorMessage(firebase::storage::Error storage_error);

// Decodes putString data (base64 / base64url formats) into raw bytes.
std::vector<unsigned char> StringToByteData(const std::string& data,
                                            int64_t format);

// Decodes a base64 string into raw bytes.
std::vector<unsigned char> Base64Decode(const std::string& encoded_string);

}  // namespace firebase_storage_desktop

#endif  // FIREBASE_STORAGE_SRC_FIREBASE_STORAGE_UTILS_H_
