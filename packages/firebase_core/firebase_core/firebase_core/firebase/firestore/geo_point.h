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

#ifndef FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_GEO_POINT_H_
#define FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_GEO_POINT_H_

#include <iosfwd>
#include <string>

namespace firebase {
namespace firestore {

/**
 * An immutable object representing a geographical point in Firestore. The point
 * is represented as a latitude/longitude pair.
 *
 * Latitude values are in the range of [-90, 90].
 * Longitude values are in the range of [-180, 180].
 */
class GeoPoint {
 public:
  /** Creates a `GeoPoint` with both latitude and longitude set to 0. */
  GeoPoint() = default;

  /**
   * Creates a `GeoPoint` from the provided latitude and longitude values.
   *
   * @param latitude The latitude as number of degrees between -90 and 90.
   * @param longitude The longitude as number of degrees between -180 and 180.
   */
  GeoPoint(double latitude, double longitude);

  /** Copy constructor, `GeoPoint` is trivially copyable. */
  GeoPoint(const GeoPoint& other) = default;

  /** Move constructor, equivalent to copying. */
  GeoPoint(GeoPoint&& other) = default;

  /** Copy assignment operator, `GeoPoint` is trivially copyable. */
  GeoPoint& operator=(const GeoPoint& other) = default;

  /** Move assignment operator, equivalent to copying. */
  GeoPoint& operator=(GeoPoint&& other) = default;

  /** Returns the latitude value of this `GeoPoint`. */
  double latitude() const {
    return latitude_;
  }

  /** Returns the latitude value of this `GeoPoint`. */
  double longitude() const {
    return longitude_;
  }

  /**
   * Returns a string representation of this `GeoPoint` for logging/debugging
   * purposes.
   *
   * @note: the exact string representation is unspecified and subject to
   * change; don't rely on the format of the string.
   */
  std::string ToString() const;

  /**
   * Outputs the string representation of this `GeoPoint` to the given stream.
   *
   * @see `ToString()` for comments on the representation format.
   */
  friend std::ostream& operator<<(std::ostream& out, const GeoPoint& geo_point);

 private:
  double latitude_ = 0.0;
  double longitude_ = 0.0;
};

/** Checks whether `lhs` and `rhs` are in ascending order. */
bool operator<(const GeoPoint& lhs, const GeoPoint& rhs);

/** Checks whether `lhs` and `rhs` are in descending order. */
inline bool operator>(const GeoPoint& lhs, const GeoPoint& rhs) {
  return rhs < lhs;
}

/** Checks whether `lhs` and `rhs` are in non-ascending order. */
inline bool operator>=(const GeoPoint& lhs, const GeoPoint& rhs) {
  return !(lhs < rhs);
}

/** Checks whether `lhs` and `rhs` are in non-descending order. */
inline bool operator<=(const GeoPoint& lhs, const GeoPoint& rhs) {
  return !(lhs > rhs);
}

/** Checks `lhs` and `rhs` for inequality. */
inline bool operator!=(const GeoPoint& lhs, const GeoPoint& rhs) {
  return lhs < rhs || lhs > rhs;
}

/** Checks `lhs` and `rhs` for equality. */
inline bool operator==(const GeoPoint& lhs, const GeoPoint& rhs) {
  return !(lhs != rhs);
}

}  // namespace firestore
}  // namespace firebase

#endif  // FIRESTORE_CORE_INCLUDE_FIREBASE_FIRESTORE_GEO_POINT_H_
