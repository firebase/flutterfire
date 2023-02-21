/*
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SETTINGS_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SETTINGS_H_

#if defined(__OBJC__)
#include <dispatch/dispatch.h>
#endif

#include <cstdint>
#include <iosfwd>
#include <memory>
#include <string>

namespace firebase {
namespace firestore {

#if !defined(__ANDROID__)
// <SWIG>
// This declaration is guarded by a preprocessor macro because it causes
// problems with name lookup on Android. Android implementation of the public
// API extensively uses function calls of the form `util::Foo` which are
// expected to resolve to `::firebase::util::Foo`. As soon as namespace
// `::firebase::firestore::util` becomes visible, it shadows `::firebase::util`
// (within `::firebase::firestore`), so now all those calls fail to compile
// because they are interpreted as referring to
// `::firebase::firestore::util::Foo`, which doesn't exist. Changing existing
// code is impractical because such usages are numerous.
// </SWIG>
namespace util {
class Executor;
}
#endif

class FirestoreInternal;

/** Settings used to configure a Firestore instance. */
class Settings final {
 public:
  /**
   * Constant to use with `set_cache_size_bytes` to disable garbage collection.
   */
  static constexpr int64_t kCacheSizeUnlimited = -1;

  /**
   * @brief Creates the default settings.
   */
  Settings();

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `Settings` to copy from.
   */
  Settings(const Settings& other) = default;

  /**
   * @brief Move constructor.
   *
   * Moving is more efficient than copying for `Settings`. After being moved
   * from, `Settings` is in a valid but unspecified state.
   *
   * @param[in] other `Settings` to move data from.
   */
  Settings(Settings&& other) = default;

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `Settings` to copy from.
   *
   * @return Reference to the destination `Settings`.
   */
  Settings& operator=(const Settings& other) = default;

  /**
   * @brief Move assignment operator.
   *
   * Moving is more efficient than copying for `Settings`. After being moved
   * from, `Settings` is in a valid but unspecified state.
   *
   * @param[in] other `Settings` to move data from.
   *
   * @return Reference to the destination `Settings`.
   */
  Settings& operator=(Settings&& other) = default;

  /**
   * Gets the host of the Firestore backend to connect to.
   */
  const std::string& host() const { return host_; }

  /**
   * Returns whether to use SSL when communicating.
   */
  bool is_ssl_enabled() const { return ssl_enabled_; }

  /**
   * Returns whether to enable local persistent storage.
   */
  bool is_persistence_enabled() const { return persistence_enabled_; }

  /** Returns cache size for on-disk data. */
  int64_t cache_size_bytes() const { return cache_size_bytes_; }

  /**
   * Sets the host of the Firestore backend. The default is
   * "firestore.googleapis.com".
   *
   * @param host The host string.
   */
  void set_host(std::string host);

  /**
   * Enables or disables SSL for communication.
   *
   * @param enabled Set true to enable SSL for communication.
   */
  void set_ssl_enabled(bool enabled);

  /**
   * Enables or disables local persistent storage.
   *
   * @param enabled Set true to enable local persistent storage.
   */
  void set_persistence_enabled(bool enabled);

  /**
   * Sets an approximate cache size threshold for the on-disk data. If the cache
   * grows beyond this size, Cloud Firestore will start removing data that
   * hasn't been recently used. The size is not a guarantee that the cache will
   * stay below that size, only that if the cache exceeds the given size,
   * cleanup will be attempted.
   *
   * By default, collection is enabled with a cache size of 100 MB. The minimum
   * value is 1 MB.
   */
  void set_cache_size_bytes(int64_t value);

#if defined(__OBJC__) || defined(DOXYGEN)
  /**
   * Returns a dispatch queue that Firestore will use to execute callbacks.
   *
   * The returned dispatch queue is used for all completion handlers and event
   * handlers.
   *
   * If no dispatch queue is explictly set by calling `set_dispatch_queue()`
   * then a dedicated "callback queue" will be used; namely, the main thread
   * will not be used for callbacks unless expliclty set to do so by a call to
   * `set_dispatch_queue()`.
   *
   * @note This method is only available when `__OBJC__` is defined, such as
   * when compiling for iOS or tvOS.
   *
   * @see `set_dispatch_queue(dispatch_queue_t)` for information on how to
   * explicitly set the dispatch queue to use.
   */
  dispatch_queue_t dispatch_queue() const;

  /**
   * Sets the dispatch queue that Firestore will use to execute callbacks.
   *
   * The specified dispatch queue will be used for all completion handlers and
   * event handlers.
   *
   * @param queue The dispatch queue to use.
   *
   * @note This method is only available when `__OBJC__` is defined, such as
   * when compiling for iOS or tvOS.
   *
   * @see `dispatch_queue()` for the "get" counterpart to this method.
   */
  void set_dispatch_queue(dispatch_queue_t queue);
#endif  // defined(__OBJC__) || defined(DOXYGEN)

  /**
   * Returns a string representation of these `Settings` for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of these `Settings` to the given
   * stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out, const Settings& settings);

 private:
  static constexpr int64_t kDefaultCacheSizeBytes = 100 * 1024 * 1024;

  std::string host_;
  bool ssl_enabled_ = true;
  bool persistence_enabled_ = true;
  int64_t cache_size_bytes_ = kDefaultCacheSizeBytes;

  // <SWIG>
  // TODO(varconst): fix Android problems and make these declarations
  // unconditional.
  // </SWIG>
#if !defined(__ANDROID__)
  friend class FirestoreInternal;
  std::unique_ptr<util::Executor> CreateExecutor() const;

  std::shared_ptr<const util::Executor> executor_;
#endif
};

/** Checks `lhs` and `rhs` for equality. */
inline bool operator==(const Settings& lhs, const Settings& rhs) {
  return lhs.host() == rhs.host() &&
         lhs.is_ssl_enabled() == rhs.is_ssl_enabled() &&
         lhs.is_persistence_enabled() == rhs.is_persistence_enabled() &&
         lhs.cache_size_bytes() == rhs.cache_size_bytes();
}

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const Settings& lhs, const Settings& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_SETTINGS_H_
