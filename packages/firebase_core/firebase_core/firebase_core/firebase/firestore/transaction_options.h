/*
 * Copyright 2022 Google LLC
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

#ifndef FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_OPTIONS_H_
#define FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_OPTIONS_H_

#include <cstdint>
#include <iosfwd>
#include <string>

namespace firebase {
namespace firestore {

/**
 * Options to customize transaction behavior for `Firestore.runTransaction()`.
 */
class TransactionOptions final {
 public:
  /**
   * @brief Creates the default `TransactionOptions`.
   */
  TransactionOptions() = default;

  /**
   * @brief Copy constructor.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `TransactionOptions` to copy from.
   */
  TransactionOptions(const TransactionOptions& other) = default;

  /**
   * @brief Move constructor.
   *
   * Moving is not any more efficient than copying for `TransactionOptions`
   * because this class is trivially copyable; however, future additions to this
   * class may make it not trivially copyable, at which point moving would be
   * more efficient than copying. After being moved from, `TransactionOptions`
   * is in a valid but unspecified state.
   *
   * @param[in] other `TransactionOptions` to move data from.
   */
  TransactionOptions(TransactionOptions&& other) = default;

  /**
   * @brief Copy assignment operator.
   *
   * This performs a deep copy, creating an independent instance.
   *
   * @param[in] other `TransactionOptions` to copy from.
   *
   * @return Reference to the destination `TransactionOptions`.
   */
  TransactionOptions& operator=(const TransactionOptions& other) = default;

  /**
   * @brief Move assignment operator.
   *
   * Moving is not any more efficient than copying for `TransactionOptions`
   * because this class is trivially copyable; however, future additions to this
   * class may make it not trivially copyable, at which point moving would be
   * more efficient than copying. After being moved from, `TransactionOptions`
   * is in a valid but unspecified state.
   *
   * @param[in] other `TransactionOptions` to move data from.
   *
   * @return Reference to the destination `TransactionOptions`.
   */
  TransactionOptions& operator=(TransactionOptions&& other) = default;

  /**
   * @brief Gets the maximum number of attempts to commit, after which the
   * transaction fails.
   *
   * The default value is 5.
   */
  int32_t max_attempts() const { return max_attempts_; }

  /**
   * @brief Sets the maximum number of attempts to commit, after which the
   * transaction fails.
   *
   * The default value is 5.
   *
   * @param[in] max_attempts The maximum number of attempts; must be greater
   * than zero.
   */
  void set_max_attempts(int32_t max_attempts);

  /**
   * Returns a string representation of this `TransactionOptions` object for
   * logging/debugging purposes.
   *
   * @note the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `TransactionOptions` object to
   * the given stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream&, const TransactionOptions&);

 private:
  int32_t max_attempts_ = 5;
};

/** Compares two `TransactionOptions` objects for equality. */
bool operator==(const TransactionOptions&, const TransactionOptions&);

/** Compares two `TransactionOptions` objects for inequality. */
inline bool operator!=(const TransactionOptions& lhs,
                       const TransactionOptions& rhs) {
  return !(lhs == rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_FIRESTORE_SRC_INCLUDE_FIREBASE_FIRESTORE_TRANSACTION_OPTIONS_H_
