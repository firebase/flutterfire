// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "firebase_storage_utils.h"

#include <algorithm>
#include <cctype>

namespace firebase_storage_desktop {

enum PutStringFormat { Base64 = 1, Base64Url = 2 };

std::string GetStorageErrorCode(firebase::storage::Error storage_error) {
  switch (storage_error) {
    case firebase::storage::kErrorNone:
      return "unknown";
    case firebase::storage::kErrorUnknown:
      return "unknown";
    case firebase::storage::kErrorObjectNotFound:
      return "object-not-found";
    case firebase::storage::kErrorBucketNotFound:
      return "bucket-not-found";
    case firebase::storage::kErrorProjectNotFound:
      return "project-not-found";
    case firebase::storage::kErrorQuotaExceeded:
      return "quota-exceeded";
    case firebase::storage::kErrorUnauthenticated:
      return "unauthenticated";
    case firebase::storage::kErrorUnauthorized:
      return "unauthorized";
    case firebase::storage::kErrorRetryLimitExceeded:
      return "retry-limit-exceeded";
    case firebase::storage::kErrorNonMatchingChecksum:
      return "invalid-checksum";
    case firebase::storage::kErrorDownloadSizeExceeded:
      return "download-size-exceeded";
    case firebase::storage::kErrorCancelled:
      return "canceled";

    default:
      return "unknown";
  }
}

std::string GetStorageErrorMessage(firebase::storage::Error storage_error) {
  switch (storage_error) {
    case firebase::storage::kErrorNone:
      return "An unknown error occurred";
    case firebase::storage::kErrorUnknown:
      return "An unknown error occurred";
    case firebase::storage::kErrorObjectNotFound:
      return "No object exists at the desired reference.";
    case firebase::storage::kErrorBucketNotFound:
      return "No bucket is configured for Firebase Storage.";
    case firebase::storage::kErrorProjectNotFound:
      return "No project is configured for Firebase Storage.";
    case firebase::storage::kErrorQuotaExceeded:
      return "Quota on your Firebase Storage bucket has been exceeded.";
    case firebase::storage::kErrorUnauthenticated:
      return "User is unauthenticated. Authenticate and try again.";
    case firebase::storage::kErrorUnauthorized:
      return "User is not authorized to perform the desired action.";
    case firebase::storage::kErrorRetryLimitExceeded:
      return "The maximum time limit on an operation (upload, download, "
             "delete, etc.) has been exceeded.";
    case firebase::storage::kErrorNonMatchingChecksum:
      return "File on the client does not match the checksum of the file "
             "received by the server.";
    case firebase::storage::kErrorDownloadSizeExceeded:
      return "Size of the downloaded file exceeds the amount of memory "
             "allocated for the download.";
    case firebase::storage::kErrorCancelled:
      return "User cancelled the operation.";

    default:
      return "An unknown error occurred";
  }
}

std::vector<unsigned char> StringToByteData(const std::string& data,
                                            int64_t format) {
  switch (format) {
    case Base64:
      return Base64Decode(data);
    case Base64Url: {
      std::string url_safe_data = data;
      std::replace(url_safe_data.begin(), url_safe_data.end(), '-', '+');
      std::replace(url_safe_data.begin(), url_safe_data.end(), '_', '/');
      return Base64Decode(url_safe_data);
    }
    default:
      return {};  // Return empty vector for unsupported formats
  }
}

std::vector<unsigned char> Base64Decode(const std::string& encoded_string) {
  std::string base64_chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      "abcdefghijklmnopqrstuvwxyz"
      "0123456789+/";
  size_t in_len = encoded_string.size();
  size_t i = 0;
  size_t j = 0;
  size_t in_ = 0;
  unsigned char char_array_4[4], char_array_3[3];
  std::vector<unsigned char> ret;

  while (in_len-- && (encoded_string[in_] != '=') &&
         (isalnum(encoded_string[in_]) || encoded_string[in_] == '+' ||
          encoded_string[in_] == '/')) {
    char_array_4[i++] = encoded_string[in_];
    in_++;
    if (i == 4) {
      for (i = 0; i < 4; i++) {
        char_array_4[i] =
            static_cast<unsigned char>(base64_chars.find(char_array_4[i]));
      }

      char_array_3[0] =
          (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
      char_array_3[1] =
          ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
      char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

      for (i = 0; (i < 3); i++) ret.push_back(char_array_3[i]);
      i = 0;
    }
  }

  if (i) {
    for (j = 0; j < 4; j++)
      char_array_4[j] =
          base64_chars.find(char_array_4[j]) != std::string::npos
              ? static_cast<unsigned char>(base64_chars.find(char_array_4[j]))
              : 0;

    char_array_3[0] = (char_array_4[0] << 2) + ((char_array_4[1] & 0x30) >> 4);
    char_array_3[1] =
        ((char_array_4[1] & 0xf) << 4) + ((char_array_4[2] & 0x3c) >> 2);
    char_array_3[2] = ((char_array_4[2] & 0x3) << 6) + char_array_4[3];

    for (j = 0; (j < i - 1); j++) ret.push_back(char_array_3[j]);
  }

  return ret;
}

}  // namespace firebase_storage_desktop
