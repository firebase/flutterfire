// Copyright 2016 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_STORAGE_REFERENCE_H_
#define FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_STORAGE_REFERENCE_H_

#include <string>
#include <vector>

#include "firebase/future.h"
#include "firebase/internal/common.h"
#include "firebase/storage/metadata.h"

namespace firebase {
namespace storage {

class Controller;
class Listener;
class Storage;

/// @cond FIREBASE_APP_INTERNAL
namespace internal {
class ControllerInternal;
class MetadataInternal;
class StorageInternal;
class StorageReferenceInternalCommon;
class StorageReferenceInternal;
}  // namespace internal
/// @endcond FIREBASE_APP_INTERNAL

#ifndef SWIG
/// Represents a reference to a Cloud Storage object.
/// Developers can upload and download objects, get/set object metadata, and
/// delete an object at a specified path.
#endif  // SWIG
class StorageReference {
 public:
  /// @brief Default constructor. This creates an invalid StorageReference.
  /// Attempting to perform any operations on this reference will fail unless a
  /// valid StorageReference has been assigned to it.
  StorageReference() : internal_(nullptr) {}

  ~StorageReference();

  /// @brief Copy constructor. It's totally okay (and efficient) to copy
  /// StorageReference instances, as they simply point to the same location.
  ///
  /// @param[in] reference StorageReference to copy from.
  StorageReference(const StorageReference& reference);

  /// @brief Copy assignment operator. It's totally okay (and efficient) to copy
  /// StorageReference instances, as they simply point to the same location.
  ///
  /// @param[in] reference StorageReference to copy from.
  ///
  /// @returns Reference to the destination StorageReference.
  StorageReference& operator=(const StorageReference& reference);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
  /// @brief Move constructor. Moving is an efficient operation for
  /// StorageReference instances.
  ///
  /// @param[in] other StorageReference to move data from.
  StorageReference(StorageReference&& other);

  /// @brief Move assignment operator. Moving is an efficient operation for
  /// StorageReference instances.
  ///
  /// @param[in] other StorageReference to move data from.
  ///
  /// @returns Reference to the destination StorageReference.
  StorageReference& operator=(StorageReference&& other);
#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Gets the firebase::storage::Storage instance to which we refer.
  ///
  /// The pointer will remain valid indefinitely.
  ///
  /// @returns The firebase::storage::Storage instance that this
  /// StorageReference refers to.
  Storage* storage();

  /// @brief Gets a reference to a location relative to this one.
  ///
  /// @param[in] path Path relative to this reference's location.
  /// The pointer only needs to be valid during this call.
  ///
  /// @returns Child relative to this location.
  StorageReference Child(const char* path) const;

  /// @brief Gets a reference to a location relative to this one.
  ///
  /// @param[in] path Path relative to this reference's location.
  ///
  /// @returns Child relative to this location.
  StorageReference Child(const std::string& path) const {
    return Child(path.c_str());
  }

  /// @brief Deletes the object at the current path.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded.
  Future<void> Delete();

  /// @brief Returns the result of the most recent call to RemoveValue();
  ///
  /// @returns The result of the most recent call to RemoveValue();
  Future<void> DeleteLastResult();

  /// @brief Return the Google Cloud Storage bucket that holds this object.
  ///
  /// @returns The bucket.
  std::string bucket();

  /// @brief Return the full path of the storage reference, not including
  /// the Google Cloud Storage bucket.
  ///
  /// @returns Full path to the storage reference, not including GCS bucket.
  /// For example, for the reference "gs://bucket/path/to/object.txt", the full
  /// path would be "path/to/object.txt".
  std::string full_path();

  /// @brief Asynchronously downloads the object from this StorageReference.
  ///
  /// A byte array will be allocated large enough to hold the entire file in
  /// memory. Therefore, using this method will impact memory usage of your
  /// process.
  ///
  /// @param[in] path Path to local file on device to download into.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// read operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the number of bytes read.
  Future<size_t> GetFile(const char* path, Listener* listener = nullptr,
                         Controller* controller_out = nullptr);

  /// @brief Returns the result of the most recent call to GetFile();
  ///
  /// @returns The result of the most recent call to GetFile();
  Future<size_t> GetFileLastResult();

  /// @brief Asynchronously downloads the object from this StorageReference.
  ///
  /// A byte array will be allocated large enough to hold the entire file in
  /// memory. Therefore, using this method will impact memory usage of your
  /// process.
  ///
  /// @param[in] buffer A byte buffer to read the data into. This buffer must
  /// be valid for the duration of the transfer.
  /// @param[in] buffer_size The size of the byte buffer.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// read operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the number of bytes read.
  Future<size_t> GetBytes(void* buffer, size_t buffer_size,
                          Listener* listener = nullptr,
                          Controller* controller_out = nullptr);

  /// @brief Returns the result of the most recent call to GetBytes();
  ///
  /// @returns The result of the most recent call to GetBytes();
  Future<size_t> GetBytesLastResult();

  /// @brief Asynchronously retrieves a long lived download URL with a revokable
  /// token.
  ///
  /// This can be used to share the file with others, but can be revoked by a
  /// developer in the Firebase Console if desired.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded and the URL is returned.
  Future<std::string> GetDownloadUrl();

  /// @brief Returns the result of the most recent call to GetDownloadUrl();
  ///
  /// @returns The result of the most recent call to GetDownloadUrl();
  Future<std::string> GetDownloadUrlLastResult();

  /// @brief Retrieves metadata associated with an object at this
  /// StorageReference.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded and the Metadata is returned.
  Future<Metadata> GetMetadata();

  /// @brief Returns the result of the most recent call to GetMetadata();
  ///
  /// @returns The result of the most recent call to GetMetadata();
  Future<Metadata> GetMetadataLastResult();

  /// @brief Updates the metadata associated with this StorageReference.
  ///
  /// @returns A Future result, which will complete when the operation either
  /// succeeds or fails. When the Future is completed, if its Error is
  /// kErrorNone, the operation succeeded and the Metadata is returned.
  Future<Metadata> UpdateMetadata(const Metadata& metadata);

  /// @brief Returns the result of the most recent call to UpdateMetadata();
  ///
  /// @returns The result of the most recent call to UpdateMetadata();
  Future<Metadata> UpdateMetadataLastResult();

  /// @brief Returns the short name of this object.
  ///
  /// @returns the short name of this object.
  std::string name();

  /// @brief Returns a new instance of StorageReference pointing to the parent
  /// location or null if this instance references the root location.
  ///
  /// @returns The parent StorageReference.
  StorageReference GetParent();

  /// @brief Asynchronously uploads data to the currently specified
  /// StorageReference, without additional metadata.
  ///
  /// @param[in] buffer A byte buffer to write data from. This buffer must be
  /// valid for the duration of the transfer.
  /// @param[in] buffer_size The size of the byte buffer.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// write operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the Metadata.
  Future<Metadata> PutBytes(const void* buffer, size_t buffer_size,
                            Listener* listener = nullptr,
                            Controller* controller_out = nullptr);

  /// @brief Asynchronously uploads data to the currently specified
  /// StorageReference, without additional metadata.
  ///
  /// @param[in] buffer A byte buffer to write data from. This buffer must be
  /// valid for the duration of the transfer.
  /// @param[in] buffer_size The number of bytes to write.
  /// @param[in] metadata Metadata containing additional information (MIME type,
  /// etc.) about the object being uploaded.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// write operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the Metadata.
  Future<Metadata> PutBytes(const void* buffer, size_t buffer_size,
                            const Metadata& metadata,
                            Listener* listener = nullptr,
                            Controller* controller_out = nullptr);

  /// @brief Returns the result of the most recent call to PutBytes();
  ///
  /// @returns The result of the most recent call to PutBytes();
  Future<Metadata> PutBytesLastResult();

  /// @brief Asynchronously uploads data to the currently specified
  /// StorageReference, without additional metadata.
  ///
  /// @param[in] path Path to local file on device to upload to Firebase
  /// Storage.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// write operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the Metadata.
  Future<Metadata> PutFile(const char* path, Listener* listener = nullptr,
                           Controller* controller_out = nullptr);

  /// @brief Asynchronously uploads data to the currently specified
  /// StorageReference, without additional metadata.
  ///
  /// @param[in] path Path to local file on device to upload to Firebase
  /// Storage.
  /// @param[in] metadata Metadata containing additional information (MIME type,
  /// etc.) about the object being uploaded.
  /// @param[in] listener A listener that will respond to events on this read
  /// operation. If not nullptr, a listener that will respond to events on this
  /// write operation. The caller is responsible for allocating and deallocating
  /// the listener. The same listener can be used for multiple operations.
  /// @param[out] controller_out Controls the write operation, providing the
  /// ability to pause, resume or cancel an ongoing write operation. If not
  /// nullptr, this method will output a Controller here that you can use to
  /// control the write operation.
  ///
  /// @returns A future that returns the Metadata.
  Future<Metadata> PutFile(const char* path, const Metadata& metadata,
                           Listener* listener = nullptr,
                           Controller* controller_out = nullptr);

  /// @brief Returns the result of the most recent call to PutFile();
  ///
  /// @returns The result of the most recent call to PutFile();
  Future<Metadata> PutFileLastResult();

  /// @brief Returns true if this StorageReference is valid, false if it is not
  /// valid. An invalid StorageReference indicates that the reference is
  /// uninitialized (created with the default constructor) or that there was an
  /// error retrieving the reference.
  ///
  /// @returns true if this StorageReference is valid, false if this
  /// StorageReference is invalid.
  bool is_valid() const;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class Controller;
  friend class internal::ControllerInternal;
  friend class Metadata;
  friend class internal::MetadataInternal;
  friend class Storage;
  friend class internal::StorageReferenceInternal;
  friend class internal::StorageReferenceInternalCommon;

  StorageReference(internal::StorageReferenceInternal* internal);

  internal::StorageReferenceInternal* internal_;
  /// @endcond
};

}  // namespace storage
}  // namespace firebase

#endif  // FIREBASE_STORAGE_SRC_INCLUDE_FIREBASE_STORAGE_STORAGE_REFERENCE_H_
