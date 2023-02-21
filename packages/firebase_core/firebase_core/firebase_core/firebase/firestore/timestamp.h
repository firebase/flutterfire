/*
 * Copyright 2018 Google
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

#ifndef FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_TIMESTAMP_H_
#define FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_TIMESTAMP_H_

#include <cstdint>
#include <ctime>
#include <iosfwd>
#include <string>

#if !defined(_STLPORT_VERSION)
#include <chrono>  // NOLINT(build/c++11)
#endif             // !defined(_STLPORT_VERSION)

namespace firebase {

/**
 * A Timestamp represents a point in time independent of any time zone or
 * calendar, represented as seconds and fractions of seconds at nanosecond
 * resolution in UTC Epoch time. It is encoded using the Proleptic Gregorian
 * Calendar which extends the Gregorian calendar backwards to year one. It is
 * encoded assuming all minutes are 60 seconds long, i.e. leap seconds are
 * "smeared" so that no leap second table is needed for interpretation. Range is
 * from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59.999999999Z.
 *
 * @see
 * https://github.com/google/protobuf/blob/master/src/google/protobuf/timestamp.proto
 */
class Timestamp {
 public:
  /**
   * Creates a new timestamp representing the epoch (with seconds and
   * nanoseconds set to 0).
   */
  Timestamp() = default;

  /**
   * Creates a new timestamp.
   *
   * @param seconds The number of seconds of UTC time since Unix epoch
   *     1970-01-01T00:00:00Z. Must be from 0001-01-01T00:00:00Z to
   *     9999-12-31T23:59:59Z inclusive; otherwise, assertion failure will be
   *     triggered.
   * @param nanoseconds The non-negative fractions of a second at nanosecond
   *     resolution. Negative second values with fractions must still have
   *     non-negative nanoseconds values that count forward in time. Must be
   *     from 0 to 999,999,999 inclusive; otherwise, assertion failure will be
   *     triggered.
   */
  Timestamp(int64_t seconds, int32_t nanoseconds);

  /** Copy constructor, `Timestamp` is trivially copyable. */
  Timestamp(const Timestamp& other) = default;

  /** Move constructor, equivalent to copying. */
  Timestamp(Timestamp&& other) = default;

  /** Copy assignment operator, `Timestamp` is trivially copyable. */
  Timestamp& operator=(const Timestamp& other) = default;

  /** Move assignment operator, equivalent to copying. */
  Timestamp& operator=(Timestamp&& other) = default;

  /**
   * Creates a new timestamp with the current date.
   *
   * The precision is up to nanoseconds, depending on the system clock.
   *
   * @return a new timestamp representing the current date.
   */
  static Timestamp Now();

  /**
   * The number of seconds of UTC time since Unix epoch 1970-01-01T00:00:00Z.
   */
  int64_t seconds() const {
    return seconds_;
  }

  /**
   * The non-negative fractions of a second at nanosecond resolution. Negative
   * second values with fractions still have non-negative nanoseconds values
   * that count forward in time.
   */
  int32_t nanoseconds() const {
    return nanoseconds_;
  }

  /**
   * Converts `time_t` to a `Timestamp`.
   *
   * @param seconds_since_unix_epoch
   *     @parblock
   *     The number of seconds of UTC time since Unix epoch
   *     1970-01-01T00:00:00Z. Can be negative to represent dates before the
   *     epoch. Must be from 0001-01-01T00:00:00Z to 9999-12-31T23:59:59Z
   *     inclusive; otherwise, assertion failure will be triggered.
   *
   *     Note that while the epoch of `time_t` is unspecified, it's usually Unix
   *     epoch. If this assumption is broken, this function will produce
   *     incorrect results.
   *     @endparblock
   *
   * @return a new timestamp with the given number of seconds and zero
   *     nanoseconds.
   */
  static Timestamp FromTimeT(time_t seconds_since_unix_epoch);

#if !defined(_STLPORT_VERSION)
  /**
   * Converts `std::chrono::time_point` to a `Timestamp`.
   *
   * @param time_point
   *     @parblock
   *     The time point with system clock's epoch, which is
   *     presumed to be Unix epoch 1970-01-01T00:00:00Z. Can be negative to
   *     represent dates before the epoch. Must be from 0001-01-01T00:00:00Z to
   *     9999-12-31T23:59:59Z inclusive; otherwise, assertion failure will be
   *     triggered.
   *
   *     Note that while the epoch of `std::chrono::system_clock` is
   *     unspecified, it's usually Unix epoch. If this assumption is broken,
   *     this constructor will produce incorrect results.
   *     @endparblock
   */
  static Timestamp FromTimePoint(
      std::chrono::time_point<std::chrono::system_clock> time_point);

  /**
   * Converts this `Timestamp` to a `time_point`.
   *
   * Important: if overflow would occur, the returned value will be the maximum
   * or minimum value that `Duration` can hold. Note in particular that `long
   * long` is insufficient to hold the full range of `Timestamp` values with
   * nanosecond precision (which is why `Duration` defaults to `microseconds`).
   */
  template <typename Clock = std::chrono::system_clock,
            typename Duration = std::chrono::microseconds>
  std::chrono::time_point<Clock, Duration> ToTimePoint() const;
#endif  // !defined(_STLPORT_VERSION)

  /**
   * Returns a string representation of this `Timestamp` for logging/debugging
   * purposes.
   *
   * @note: the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `Timestamp` to the given stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out,
                                  const Timestamp& timestamp);

 private:
  // Checks that the number of seconds is within the supported date range, and
  // that nanoseconds satisfy 0 <= ns <= 1second.
  void ValidateBounds() const;

  int64_t seconds_ = 0;
  int32_t nanoseconds_ = 0;
};

/** Checks whether `lhs` and `rhs` are in ascending order. */
inline bool operator<(const Timestamp& lhs, const Timestamp& rhs) {
  return lhs.seconds() < rhs.seconds() ||
         (lhs.seconds() == rhs.seconds() &&
          lhs.nanoseconds() < rhs.nanoseconds());
}

/** Checks whether `lhs` and `rhs` are in descending order. */
inline bool operator>(const Timestamp& lhs, const Timestamp& rhs) {
  return rhs < lhs;
}

/** Checks whether `lhs` and `rhs` are in non-ascending order. */
inline bool operator>=(const Timestamp& lhs, const Timestamp& rhs) {
  return !(lhs < rhs);
}

/** Checks whether `lhs` and `rhs` are in non-descending order. */
inline bool operator<=(const Timestamp& lhs, const Timestamp& rhs) {
  return !(lhs > rhs);
}

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const Timestamp& lhs, const Timestamp& rhs) {
  return lhs < rhs || lhs > rhs;
}

/** Checks `lhs` and `rhs` for equality. */
inline bool operator==(const Timestamp& lhs, const Timestamp& rhs) {
  return !(lhs != rhs);
}

#if !defined(_STLPORT_VERSION)

// Make sure the header compiles even when included after `<windows.h>` without
// `NOMINMAX` defined. `push/pop_macro` pragmas are supported by Visual Studio
// as well as Clang and GCC.
#pragma push_macro("min")
#pragma push_macro("max")
#undef min
#undef max

template <typename Clock, typename Duration>
std::chrono::time_point<Clock, Duration> Timestamp::ToTimePoint() const {
  namespace chr = std::chrono;
  using TimePoint = chr::time_point<Clock, Duration>;

  // Saturate on overflow
  const auto max_seconds = chr::duration_cast<chr::seconds>(Duration::max());
  if (seconds_ > 0 && max_seconds.count() <= seconds_) {
    return TimePoint{Duration::max()};
  }
  const auto min_seconds = chr::duration_cast<chr::seconds>(Duration::min());
  if (seconds_ < 0 && min_seconds.count() >= seconds_) {
    return TimePoint{Duration::min()};
  }

  const auto seconds = chr::duration_cast<Duration>(chr::seconds(seconds_));
  const auto nanoseconds =
      chr::duration_cast<Duration>(chr::nanoseconds(nanoseconds_));
  return TimePoint{seconds + nanoseconds};
}

#pragma pop_macro("max")
#pragma pop_macro("min")

#endif  // !defined(_STLPORT_VERSION)

}  // namespace firebase

#endif  // FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_TIMESTAMP_H_
