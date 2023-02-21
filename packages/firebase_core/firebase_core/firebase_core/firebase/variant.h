/*
 * Copyright 2016 Google LLC
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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_VARIANT_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_VARIANT_H_

#include <stdint.h>

#include <cstring>
#include <map>
#include <string>
#include <utility>
#include <vector>

#include "firebase/internal/common.h"

/// @brief Namespace that encompasses all Firebase APIs.

namespace firebase {
namespace internal {
class VariantInternal;
}
}  // namespace firebase

namespace firebase {

// <SWIG>
// SWIG uses the Variant class as a readonly object, and so ignores most of the
// functions. In order to keep things clean, functions that should be exposed
// are explicitly listed in app.SWIG, and everything else is ignored.
// </SWIG>

/// Variant data type used by Firebase libraries.
class Variant {
 public:
  /// Type of data that this variant object contains.
  enum Type {
    /// Null, or no data.
    kTypeNull,
    /// A 64-bit integer.
    kTypeInt64,
    /// A double-precision floating point number.
    kTypeDouble,
    /// A boolean value.
    kTypeBool,
    /// A statically-allocated string we point to.
    kTypeStaticString,
    /// A std::string.
    kTypeMutableString,
    /// A std::vector of Variant.
    kTypeVector,
    /// A std::map, mapping Variant to Variant.
    kTypeMap,
    /// An statically-allocated blob of data that we point to. Never constructed
    /// by default. Use Variant::FromStaticBlob() to create a Variant of this
    /// type.
    kTypeStaticBlob,
    /// A blob of data that the Variant holds. Never constructed by default. Use
    /// Variant::FromMutableBlob() to create a Variant of this type, and copy
    /// binary data from an existing source.
    kTypeMutableBlob,

    // Note: If you add new types update enum InternalType;
  };

// <SWIG>
// Because of the VariantVariantMap C# class, we need to hide the constructors
// explicitly, as the SWIG ignore does not seem to work with that macro.
// </SWIG>
#ifndef SWIG
  /// @brief Construct a null Variant.
  ///
  /// The Variant constructed will be of type Null.
  Variant() : type_(kInternalTypeNull), value_({}) {}

  /// @brief Construct a Variant with the given templated type.
  ///
  /// @param[in] value The value to construct the variant.
  ///
  /// Valid types for this constructor are `int`, `int64_t`, `float`, `double`,
  /// `bool`, `const char*`, and `char*` (but see below for additional Variant
  /// types).
  ///
  ///
  /// Type `int` or `int64_t`:
  ///   * The Variant constructed will be of type Int64.
  ///
  /// Type `double` or `float`:
  ///   * The Variant constructed will be of type Double.
  ///
  /// Type `bool`:
  ///   * The Variant constructed will be of type Bool.
  ///
  /// Type `const char*`:
  ///   * The Variant constructed will be of type StaticString, and is_string()
  ///     will return true. **Note:** If you use this constructor, you must
  ///     ensure that the memory pointed to stays valid for the life of the
  ///     Variant, otherwise call mutable_string() or set_mutable_string(),
  ///     which will copy the string to an internal buffer.
  ///
  /// Type `char*`:
  ///   * The Variant constructed will be of type MutableString, and is_string()
  ///     will return true.
  ///
  /// Other types will result in compiler error unless using the following
  /// constructor overloads:
  ///   * `std::string`
  ///   * `std::vector<Variant>`
  ///   * `std::vector<T>` where T is convertible to variant type
  ///   * `T*`, `size_t` where T is convertible to variant type
  ///   * `std::map<Variant, Variant>`
  ///   * `std::map<K, V>` where K and V is convertible to variant type
  template <typename T>
  Variant(T value)  // NOLINT
      : type_(kInternalTypeNull) {
    set_value_t(value);
  }

  /// @brief Construct a Variant containing the given string value (makes a
  /// copy).
  ///
  /// The Variant constructed will be of type MutableString, and is_string()
  /// will return true.
  ///
  /// @param[in] value The string to use for the Variant.
  Variant(const std::string& value)  // NOLINT
      : type_(kInternalTypeNull) {
    set_mutable_string(value);
  }

  /// @brief Construct a Variant containing the given std::vector of Variant.
  ///
  /// The Variant constructed will be of type Vector.
  ///
  /// @param[in] value The STL vector to copy into the Variant.
  Variant(const std::vector<Variant>& value)  // NOLINT
      : type_(kInternalTypeNull) {
    set_vector(value);
  }

  /// @brief Construct a Variant containing the given std::vector of something
  /// that can be constructed into a Variant.
  ///
  /// The Variant constructed will be of type Vector.
  ///
  /// @param[in] value An STL vector containing elements that can be converted
  /// to Variant (such as ints, strings, vectors). A Variant will be created for
  /// each element, and copied into the Vector Variant constructed here.
  template <typename T>
  Variant(const std::vector<T>& value)  // NOLINT
      : type_(kInternalTypeNull) {
    Clear(kTypeVector);
    vector().reserve(value.size());
    for (size_t i = 0; i < value.size(); i++) {
      vector().push_back(Variant(static_cast<T>(value[i])));
    }
  }

  /// @brief Construct a Variant from an array of supported types into a Vector.
  ///
  /// The Variant constructed will be of type Vector.
  ///
  /// @param[in] array_of_values A C array containing elements that can be
  /// converted to Variant (such as ints, strings, vectors). A Variant will be
  /// created for each element, and copied into the Vector Variant constructed
  /// here.
  /// @param[in] array_size Number of elements of the array.
  template <typename T>
  Variant(const T array_of_values[], size_t array_size)
      : type_(kInternalTypeNull) {
    Clear(kTypeVector);
    vector().reserve(array_size);
    for (size_t i = 0; i < array_size; i++) {
      vector()[i] = Variant(array_of_values[i]);
    }
  }

  /// @brief Construct a Variatn containing the given std::map of Variant to
  /// Variant.
  ///
  /// The Variant constructed will be of type Map.
  ///
  /// @param[in] value The STL map to copy into the Variant.
  Variant(const std::map<Variant, Variant>& value)  // NOLINT
      : type_(kInternalTypeNull) {
    set_map(value);
  }

  /// @brief Construct a Variant containing the given std::map of something that
  /// can be constructed into a Variant, to something that can be constructed
  /// into a Variant.
  ///
  /// The Variant constructed will be of type Map.
  ///
  /// @param[in] value An STL map containing keys and values that can be
  /// converted to Variant (such as ints, strings, vectors). A Variant will be
  /// created for each key and for each value, and copied by pairs into the Map
  /// Variant constructed here.
  template <typename K, typename V>
  Variant(const std::map<K, V>& value)  // NOLINT
      : type_(kInternalTypeNull) {
    Clear(kTypeMap);
    for (typename std::map<K, V>::const_iterator i = value.begin();
         i != value.end(); ++i) {
      map().insert(std::make_pair(Variant(i->first), Variant(i->second)));
    }
  }

  /// @brief Copy constructor. Performs a deep copy.
  ///
  /// @param[in] other Source Variant to copy from.
  Variant(const Variant& other) : type_(kInternalTypeNull) { *this = other; }

  /// @brief Copy assignment operator. Performs a deep copy.
  ///
  /// @param[in] other Source Variant to copy from.
  Variant& operator=(const Variant& other);

#if defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)

  /// @brief Move constructor. Efficiently moves  the more complex data types by
  /// simply reassigning pointer ownership.
  ///
  /// @param[in] other Source Variant to move from.
  Variant(Variant&& other) noexcept : type_(kInternalTypeNull) {
    *this = std::move(other);
  }

  /// @brief Move assignment operator. Efficiently moves the more complex data
  /// types by simply reassigning pointer ownership.
  ///
  /// @param[in] other Source Variant to move from.
  Variant& operator=(Variant&& other) noexcept;

#endif  // defined(FIREBASE_USE_MOVE_OPERATORS) || defined(DOXYGEN)
#endif  // SWIG

  /// Destructor. Frees the memory that this Variant owns.
  ~Variant() { Clear(); }

  /// @brief Equality operator. Both the type and the value must be equal
  /// (except that static strings CAN be == to mutable strings). For container
  /// types, element-by-element comparison is performed. For strings, string
  /// comparison is performed.
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return True if the Variants are of identical types and values, false
  /// otherwise.
  bool operator==(const Variant& other) const;

  /// @brief Inequality operator, only meant for internal use.
  ///
  /// Explanation: In order to use Variant as a key for std::map, we must
  /// provide a comparison function. This comparison function is ONLY for
  /// std::map to be able to use a Variant as a map key.
  ///
  /// We define v1 < v2 IFF:
  /// * If different types, compare type as int: v1.type() < v2.type()
  ///   (note: this means that Variant(1) < Variant(0.0) - be careful!)
  /// * If both are int64: v1.int64_value() < v2.int64_value();
  /// * If both are double: v1.double_value() < v2.double_value()
  /// * If both are bool: v1.bool_value() < v2.bool_value();
  /// * If both are either static or mutable strings: strcmp(v1, v2) < 0
  /// * If both are vectors:
  ///   * If v1[0] < v2[0], that means v1 < v2 == true. Otherwise:
  ///   * If v1[0] > v2[0], that means v1 < v2 == false. Otherwise:
  ///   * Continue to the next element of both vectors and compare again.
  ///   * If you reach the end of one vector first, that vector is considered
  ///     to be lesser.
  /// * If both are maps, iterate similar to vectors (since maps are ordered),
  ///   but for each element, first compare the key, then the value.
  /// * If both are blobs, the smaller-sized blob is considered lesser. If both
  ///   blobs are the same size, use memcmp to compare the bytes.
  ///
  /// We have defined this operation such that if !(v1 < v2) && !(v2 < v1), it
  /// must follow that v1 == v2.
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return Results of the comparison, as described in this documentation.
  ///
  /// @note This will not give you the results you expect if you compare
  /// Variants of different types! For example, Variant(0.0) < Variant(1).
  bool operator<(const Variant& other) const;

  /// @brief Inequality operator: x != y is evaluated as !(x == y).
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return Results of the comparison.
  bool operator!=(const Variant& other) const { return !(*this == other); }

  /// @brief Inequality operator: x > y is evaluated as y < x
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return Results of the comparison.
  bool operator>(const Variant& other) const { return other < *this; }

  /// @brief Inequality operator: x >= y is evaluated as !(x < y)
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return Results of the comparison.
  bool operator>=(const Variant& other) const { return !(*this < other); }

  /// @brief Inequality operator: x <= y is evaluated as !(x > y)
  ///
  /// @param[in] other Variant to compare to.
  ///
  /// @return Results of the comparison.
  bool operator<=(const Variant& other) const { return !(*this > other); }

  /// @brief Clear the given Variant data, optionally into a new type. Frees up
  /// any memory that might have been allocated. After calling this, you can
  /// access the Variant as the new type.
  ///
  /// @param[in] new_type Optional new type to clear the Variant to. You may
  /// immediately begin using the Variant as that new type.
  void Clear(Type new_type = kTypeNull);

  // Convenience functions (used similarly to constants).

  /// @brief Get a Variant of type Null.
  ///
  /// @return A Variant of type Null.
  static Variant Null() { return Variant(); }

  /// @brief Get a Variant of integer value 0.
  ///
  /// @return A Variant of type Int64, with value 0.
  static Variant Zero() { return Variant::FromInt64(0L); }

  /// @brief Get a Variant of integer value 1.
  ///
  /// @return A Variant of type Int64, with value 1.
  static Variant One() { return Variant::FromInt64(1L); }

  /// @brief Get a Variant of double value 0.0.
  ///
  /// @return A Variant of type Double, with value 0.0.
  static Variant ZeroPointZero() { return Variant::FromDouble(0.0); }

  /// @brief Get a Variant of double value 1.0.
  ///
  /// @return A Variant of type Double, with value 1.0.
  static Variant OnePointZero() { return Variant::FromDouble(1.0); }

  /// @brief Get a Variant of bool value false.
  ///
  /// @return A Variant of type Bool, with value false.
  static Variant False() { return Variant::FromBool(false); }

  /// @brief Get a Variant of bool value true.
  ///
  /// @return A Variant of type Bool, with value true.
  static Variant True() { return Variant::FromBool(true); }

  /// @brief Get an empty string variant.
  ///
  /// @return A Variant of type StaticString, referring to an empty string.
  static Variant EmptyString() { return Variant::FromStaticString(""); }

  /// @brief Get a Variant containing an empty mutable string.
  ///
  /// @return A Variant of type MutableString, containing an empty string.
  static Variant EmptyMutableString() {
    Variant v;
    v.Clear(kTypeMutableString);
    return v;
  }

  /// @brief Get a Variant containing an empty vector. You can immediately call
  /// vector() on it to work with the vector it contains.
  ///
  /// @return A Variant of type Vector, containing no elements.
  static Variant EmptyVector() {
    Variant v;
    v.Clear(kTypeVector);
    return v;
  }

  /// @brief Get a Variant containing an empty map. You can immediately call
  /// map() on
  /// it to work with the map it contains.
  ///
  /// @return A Variant of type Map, containing no elements.
  static Variant EmptyMap() {
    Variant v;
    v.Clear(kTypeMap);
    return v;
  }

  /// @brief Return a Variant containing an empty mutable blob of the requested
  /// size, filled with 0-bytes.
  ///
  /// @param[in] size_bytes Size of the buffer you want, in bytes.
  ///
  /// @returns A Variant containing a mutable blob of the requested size, filled
  /// with 0-bytes.
  static Variant EmptyMutableBlob(size_t size_bytes) {
    Variant v;
    uint8_t* blank_data = new uint8_t[size_bytes];
    memset(blank_data, 0, size_bytes);
    v.Clear(kTypeMutableBlob);
    v.set_blob_pointer(blank_data, size_bytes);
    return v;
  }

  /// @brief Get the current type contained in this Variant.
  ///
  /// @return The Variant's type.
  Type type() const {
    // To avoid breaking user code, alias the small string type to mutable
    // string.
    if (type_ == kInternalTypeSmallString) {
      return kTypeMutableString;
    }

    return static_cast<Type>(type_);
  }

  /// @brief Get whether this Variant is currently null.
  ///
  /// @return True if the Variant is Null, false otherwise.
  bool is_null() const { return type() == kTypeNull; }

  /// @brief Get whether this Variant contains an integer.
  ///
  /// @return True if the Variant's type is Int64, false otherwise.
  bool is_int64() const { return type() == kTypeInt64; }

  /// @brief Get whether this Variant contains a double.
  ///
  /// @return True if the Variant's type is Double, false otherwise.
  bool is_double() const { return type() == kTypeDouble; }

  /// @brief Get whether this Variant contains a bool.
  ///
  /// @return True if the Variant's type is Bool, false otherwise.
  bool is_bool() const { return type() == kTypeBool; }

  /// @brief Get whether this Variant contains a vector.
  ///
  /// @return True if the Variant's type is Vector, false otherwise.
  bool is_vector() const { return type() == kTypeVector; }

  /// @brief Get whether this Variant contains a map.
  ///
  /// @return True if the Variant's type is Map, false otherwise.
  bool is_map() const { return type() == kTypeMap; }

  /// @brief Get whether this Variant contains a static string.
  ///
  /// @return True if the Variant's type is StaticString, false otherwise.
  bool is_static_string() const { return type() == kTypeStaticString; }

  /// @brief Get whether this Variant contains a mutable string.
  ///
  /// @return True if the Variant's type is MutableString, false otherwise.
  bool is_mutable_string() const { return type() == kTypeMutableString; }

  /// @brief Get whether this Variant contains a string.
  ///
  /// @return True if the Variant's type is either StaticString or
  /// MutableString or SmallString; false otherwise.
  ///
  /// @note No matter which type of string the Variant contains, you can read
  /// its value via string_value().
  bool is_string() const {
    return is_static_string() || is_mutable_string() || is_small_string();
  }

  /// @brief Get whether this Variant contains a static blob.
  ///
  /// @return True if the Variant's type is StaticBlob, false otherwise.
  bool is_static_blob() const { return type() == kTypeStaticBlob; }

  /// @brief Get whether this Variant contains a mutable blob.
  ///
  /// @return True if the Variant's type is MutableBlob, false otherwise.
  bool is_mutable_blob() const { return type() == kTypeMutableBlob; }

  /// @brief Get whether this Variant contains a blob.
  ///
  /// @return True if the Variant's type is either StaticBlob or
  /// MutableBlob; false otherwise.
  ///
  /// @note No matter which type of blob the Variant contains, you can read
  /// its data via blob_data() and get its size via blob_size().
  bool is_blob() const { return is_static_blob() || is_mutable_blob(); }

  /// @brief Get whether this Variant contains a numeric type, Int64 or Double.
  ///
  /// @return True if the Variant's type is either Int64 or Double; false
  /// otherwise.
  bool is_numeric() const { return is_int64() || is_double(); }

  /// @brief Get whether this Variant contains a fundamental type: Null, Int64,
  /// Double, Bool, or one of the two String types. Essentially
  /// !is_containerType().
  ///
  /// @return True if the Variant's type is Int64, Double, Bool, or Null; false
  /// otherwise.
  bool is_fundamental_type() const {
    return is_int64() || is_double() || is_string() || is_bool() || is_null();
  }

  /// @brief Get whether this Variant contains a container type: Vector or Map.
  ///
  /// @return True if the Variant's type is Vector or Map; false otherwise.
  bool is_container_type() const { return is_vector() || is_map(); }

  /// @brief Get the current Variant converted into a string. Only valid for
  /// fundamental types.
  ///
  /// Special cases: Booleans will be returned as "true" or "false".  Null will
  /// be returned as an empty string. The returned string may be either mutable
  /// or static, depending on the source type. All other cases will return an
  /// empty string.
  ///
  /// @return A Variant containing a String that represents the value of this
  /// original Variant.
  Variant AsString() const;

  /// @brief Get the current Variant converted into an integer. Only valid for
  /// fundamental types.
  ///
  /// Special cases: If a String can be parsed as a number
  /// via strtol(), it will be. If a Bool is true, this will return 1. All other
  /// cases (including non-fundamental types) will return 0.
  ///
  /// @return A Variant containing an Int64 that represents the value of this
  /// original Variant.
  Variant AsInt64() const;

  /// @brief Get the current Variant converted into a floating-point
  /// number. Only valid for fundamental types.
  ///
  /// Special cases: If a Bool is true, this will return 1. All other cases will
  /// return 0.
  ///
  /// @return A Variant containing a Double that represents the value of this
  /// original Variant.
  Variant AsDouble() const;

  /// @brief Get the current Variant converted into a boolean. Null, 0, 0.0,
  /// empty strings, empty vectors, empty maps, blobs of size 0, and "false"
  /// (case-sensitive) are all considered false. All other values are true.
  ///
  /// @return A Variant of type Bool containing the original Variant interpreted
  /// as a Bool.
  Variant AsBool() const;

  /// @brief Mutable accessor for a Variant containing a string.
  ///
  /// If the Variant contains a static string, it will be converted into a
  /// mutable string, which copies the const char*'s data into a std::string.
  ///
  /// @return Reference to the string contained in this Variant.
  ///
  /// @note If the Variant is not one of the two String types, this will assert.
  std::string& mutable_string() {
    if (type_ == kInternalTypeStaticString ||
        type_ == kInternalTypeSmallString) {
      // Automatically promote a static or small string to a mutable string.
      set_mutable_string(string_value(), false);
    }
    assert_is_type(kTypeMutableString);
    return *value_.mutable_string_value;
  }

  /// @brief Get the size of a blob. This method works with both static
  /// and mutable blobs.
  ///
  /// @return Number of bytes of binary data contained in the blob.
  size_t blob_size() const {
    assert_is_blob();
    return value_.blob_value.size;
  }

  /// @brief Get the pointer to the binary data contained in a blob.
  /// This method works with both static and mutable blob.
  ///
  /// @return Pointer to the binary data. Use blob_size() to get the
  /// number of bytes.
  const uint8_t* blob_data() const {
    assert_is_blob();
    return value_.blob_value.ptr;
  }

  /// @brief Get a mutable pointer to the binary data contained in
  /// a blob.
  ///
  /// If the Variant contains a static blob, it will be converted into a mutable
  /// blob, which copies the binary data into the Variant's buffer.
  ///
  /// @returns Pointer to a mutable buffer of binary data. The size of the
  /// buffer cannot be changed, but the contents are mutable.
  uint8_t* mutable_blob_data() {
    if (type_ == kInternalTypeStaticBlob) {
      // Automatically promote a static blob to a mutable blob.
      set_mutable_blob(blob_data(), blob_size());
    }
    assert_is_type(kTypeMutableBlob);
    return const_cast<uint8_t*>(value_.blob_value.ptr);
  }

  /// @brief Const accessor for a Variant contianing mutable blob data.
  ///
  /// @note Unlike the non-const accessor, this accessor cannot "promote" a
  /// static blob to mutable, and thus will assert if the Variant you pass in
  /// is not of MutableBlob type.
  ///
  /// @returns Pointer to a mutable buffer of binary data. The size of the
  /// buffer cannot be changed, but the contents are mutable.
  uint8_t* mutable_blob_data() const {
    assert_is_type(kTypeMutableBlob);
    return const_cast<uint8_t*>(value_.blob_value.ptr);
  }

  /// @brief Mutable accessor for a Variant containing a vector of Variant
  /// data.
  ///
  /// @return Reference to the vector contained in this Variant.
  ///
  /// @note If the Variant is not of Vector type, this will assert.
  std::vector<Variant>& vector() {
    assert_is_type(kTypeVector);
    return *value_.vector_value;
  }
  /// @brief Mutable accessor for a Variant containing a map of Variant data.
  ///
  /// @return Reference to the map contained in this Variant.
  ///
  /// @note If the Variant is not of Map type, this will assert.
  std::map<Variant, Variant>& map() {
    assert_is_type(kTypeMap);
    return *value_.map_value;
  }

  /// @brief Const accessor for a Variant containing an integer.
  ///
  /// @return The integer contained in this Variant.
  ///
  /// @note If the Variant is not of Int64 type, this will assert.
  int64_t int64_value() const {
    assert_is_type(kTypeInt64);
    return value_.int64_value;
  }

  /// @brief Const accessor for a Variant containing a double.
  ///
  /// @return The double contained in this Variant.
  ///
  /// @note If the Variant is not of Double type, this will assert.
  double double_value() const {
    assert_is_type(kTypeDouble);
    return value_.double_value;
  }

  /// @brief Const accessor for a Variant containing a bool.
  ///
  /// @return The bool contained in this Variant.
  ///
  /// @note If the Variant is not of Bool type, this will assert.
  const bool& bool_value() const {
    assert_is_type(kTypeBool);
    return value_.bool_value;
  }

  /// @brief Const accessor for a Variant containing a string.
  ///
  /// This can return both static and mutable strings. The pointer is only
  /// guaranteed to persist if this Variant's type is StaticString.
  ///
  /// @return The string contained in this Variant.
  ///
  /// @note If the Variant is not of StaticString or MutableString type, this
  /// will assert.
  const char* string_value() const {
    assert_is_string();
    if (type_ == kInternalTypeMutableString)
      return value_.mutable_string_value->c_str();
    else if (type_ == kInternalTypeStaticString)
      return value_.static_string_value;
    else  // if (type_ == kInternalTypeSmallString)
      return value_.small_string;
  }

  /// @brief Const accessor for a Variant containing a string.
  ///
  /// @note Unlike the non-const accessor, this accessor cannot "promote" a
  /// static string to mutable, and thus returns a std::string copy instead of a
  /// const reference to a std::string
  ///
  /// @return std::string with the string contents contained in this Variant.
  std::string mutable_string() const {
    assert_is_string();
    return string_value();
  }

  /// @brief Const accessor for a Variant containing a vector of Variant data.
  ///
  /// @return Reference to the vector contained in this Variant.
  ///
  /// @note If the Variant is not of Vector type, this will assert.
  const std::vector<Variant>& vector() const {
    assert_is_type(kTypeVector);
    return *value_.vector_value;
  }

  /// @brief Const accessor for a Variant containing a map of strings to
  /// Variant
  /// data.
  ///
  /// @return Reference to the map contained in this Variant.
  ///
  /// @note If the Variant is not of Map type, this will assert.
  const std::map<Variant, Variant>& map() const {
    assert_is_type(kTypeMap);
    return *value_.map_value;
  }

  /// @brief Sets the Variant value to null.
  ///
  /// The Variant's type will be Null.
  void set_null() { Clear(kTypeNull); }

  /// @brief Sets the Variant to an 64-bit integer value.
  ///
  /// The Variant's type will be set to Int64.
  ///
  /// @param[in] value The 64-bit integer value for the Variant.
  void set_int64_value(int64_t value) {
    Clear(kTypeInt64);
    value_.int64_value = value;
  }

  /// @brief Sets the Variant to an double-precision floating point value.
  ///
  /// The Variant's type will be set to Double.
  ///
  /// @param[in] value The double-precision floating point value for the
  /// Variant.
  void set_double_value(double value) {
    Clear(kTypeDouble);
    value_.double_value = value;
  }

  /// @brief Sets the Variant to the given boolean value.
  ///
  /// The Variant's type will be set to Bool.
  ///
  /// @param[in] value The boolean value for the Variant.
  void set_bool_value(bool value) {
    Clear(kTypeBool);
    value_.bool_value = value;
  }

  /// @brief Sets the Variant to point to a static string buffer.
  ///
  /// The Variant's type will be set to StaticString.
  ///
  /// @note If you use this method, you must ensure that the memory pointed to
  /// stays valid for the life of the Variant, or otherwise call
  /// mutable_string() or set_mutable_string(), which will copy the string to an
  /// internal buffer.
  ///
  /// @param[in] value A pointer to the static null-terminated string for the
  /// Variant.
  void set_string_value(const char* value) {
    Clear(kTypeStaticString);
    value_.static_string_value = value;
  }

  /// @brief Sets the Variant to a mutable string.
  ///
  /// The Variant's type will be set to MutableString.
  ///
  /// @param[in] value A pointer to a null-terminated string, which will be
  /// copied into to the Variant.
  void set_string_value(char* value) {
    size_t len = strlen(value);
    if (len < kMaxSmallStringSize) {
      Clear(static_cast<Type>(kInternalTypeSmallString));
      strncpy(value_.small_string, value, len + 1);
    } else {
      set_mutable_string(std::string(value, len));
    }
  }

  /// @brief Sets the Variant to a mutable string.
  ///
  /// The Variant's type will be set to MutableString.
  ///
  /// @param[in] value The string to use for the Variant.
  void set_string_value(const std::string& value) { set_mutable_string(value); }

  /// @brief Sets the Variant to a copy of the given string.
  ///
  /// The Variant's type will be set to SmallString if the size of the string is
  /// less than kMaxSmallStringSize (8 bytes on x86, 16 bytes on x64) or
  /// otherwise set to MutableString.
  ///
  /// @param[in] value The string to use for the Variant.
  /// @param[in] use_small_string Check to see if the input string should be
  ///            treated as a small string or left as a mutable string
  void set_mutable_string(const std::string& value,
                          bool use_small_string = true) {
    if (value.size() < kMaxSmallStringSize && use_small_string) {
      Clear(static_cast<Type>(kInternalTypeSmallString));
      strncpy(value_.small_string, value.data(), value.size() + 1);
    } else {
      Clear(kTypeMutableString);
      *value_.mutable_string_value = value;
    }
  }

  /// @brief Sets the Variant to a copy of the given binary data.
  ///
  /// The Variant's type will be set to MutableBlob.
  ///
  /// @param[in] src_data The data to use for the Variant. If you
  /// pass in nullptr, no data will be copied, but a buffer of the
  /// requested size will be allocated.
  /// @param[in] size_bytes The size of the data, in bytes.
  void set_mutable_blob(const void* src_data, size_t size_bytes) {
    uint8_t* dest_data = new uint8_t[size_bytes];  // Will be deleted when
                                                   // `this` is deleted.
    if (src_data != nullptr) {
      memcpy(dest_data, src_data, size_bytes);
    }
    Clear(kTypeMutableBlob);
    set_blob_pointer(dest_data, size_bytes);
  }

  /// @brief Sets the Variant to point to static binary data.
  ///
  /// The Variant's type will be set to kTypeStaticBlob.
  ///
  /// @param[in] static_data Pointer to statically-allocated binary data. The
  /// Variant will point to the data, not copy it.
  /// @param[in] size_bytes Size of the data, in bytes.
  ///
  /// @note If you use this method, you must ensure that the memory pointer to
  /// stays valid for the life of the Variant, or otherwise call
  /// mutable_blob_data() or set_mutable_blob(), which will copy the data into
  /// an internal buffer.
  void set_static_blob(const void* static_data, size_t size_bytes) {
    Clear(kTypeStaticBlob);
    set_blob_pointer(static_data, size_bytes);
  }

  /// @brief Sets the Variant to a copy of the given vector.
  ///
  /// The Variant's type will be set to Vector.
  ///
  /// @param[in] value The STL vector to copy into the Variant.

  void set_vector(const std::vector<Variant>& value) {
    Clear(kTypeVector);
    *value_.vector_value = value;
  }

  /// @brief Sets the Variant to a copy of the given map.
  ///
  /// The Variant's type will be set to Map.
  ///
  /// @param[in] value The STL map to copy into the Variant.
  void set_map(const std::map<Variant, Variant>& value) {
    Clear(kTypeMap);
    *value_.map_value = value;
  }

  /// @brief Assigns an existing string which was allocated on the heap into the
  /// Variant without performing a copy. This object will take over ownership of
  /// the pointer, and will set the std::string* you pass in to NULL.
  ///
  /// The Variant's type will be set to MutableString.
  ///
  /// @param[in, out] str Pointer to a pointer to an STL string. The Variant
  /// will take over ownership of the pointer to the string, and set the
  /// pointer
  /// you passed in to NULL.
  void AssignMutableString(std::string** str) {
    Clear(kTypeNull);
    type_ = kInternalTypeMutableString;
    value_.mutable_string_value = *str;
    *str = NULL;  // NOLINT
  }

  /// @brief Assigns an existing vector which was allocated on the heap into the
  /// Variant without performing a copy. This object will take over ownership of
  /// the pointer, and will set the std::vector* you pass in to NULL.
  ///
  /// The Variant's type will be set to Vector.
  ///
  /// @param[in, out] vect Pointer to a pointer to an STL vector. The Variant
  /// will take over ownership of the pointer to the vector, and set the
  /// pointer
  /// you passed in to NULL.
  void AssignVector(std::vector<Variant>** vect) {
    Clear(kTypeNull);
    type_ = kInternalTypeVector;
    value_.vector_value = *vect;
    *vect = NULL;  // NOLINT
  }

  /// @brief Assigns an existing map which was allocated on the heap into the
  /// Variant without performing a copy. This object will take over ownership
  /// of
  /// the map, and will set the std::map** you pass in to NULL.
  ///
  /// The Variant's type will be set to Map.
  ///
  /// @param[in, out] map Pointer to a pointer to an STL map. The Variant will
  /// take over ownership of the pointer to the map, and set the pointer you
  /// passed in to NULL.
  void AssignMap(std::map<Variant, Variant>** map) {
    Clear(kTypeNull);
    type_ = kInternalTypeMap;
    value_.map_value = *map;
    *map = NULL;  // NOLINT
  }

  // Convenience methods for the times when constructors are too ambiguious.

  /// @brief Return a Variant from a 64-bit integer.
  ///
  /// @param[in] value 64-bit integer value to put into the Variant.
  ///
  /// @returns A Variant containing the 64-bit integer.
  static Variant FromInt64(int64_t value) { return Variant(value); }

  /// @brief Return a Variant from a double-precision floating point number.
  ///
  /// @param[in] value Double-precision floating point value to put into the
  /// Variant;
  ///
  /// @returns A Variant containing the double-precision floating point number.
  static Variant FromDouble(double value) { return Variant(value); }

  /// @brief Return a Variant from a boolean.
  ///
  /// @param[in] value Boolean value to put into the Variant.
  ///
  /// @returns A Variant containing the Boolean.
  static Variant FromBool(bool value) { return Variant(value); }

  /// @brief Return a Variant from a static string.
  ///
  /// @param[in] value Pointer to statically-allocated null-terminated string.
  ///
  /// @returns A Variant referring to the string pointer you passed in.
  ///
  /// @note If you use this function, you must ensure that the memory pointed
  /// to stays valid for the life of the Variant, otherwise call
  /// mutable_string() or set_mutable_string(), which will copy the string to an
  /// internal buffer.
  static Variant FromStaticString(const char* value) { return Variant(value); }

  /// @brief Return a Variant from a string.
  ///
  /// This method makes a copy of the string.
  ///
  /// @param[in] value String value to copy into the Variant.
  ///
  /// @returns A Variant containing a copy of the string.
  static Variant FromMutableString(const std::string& value) {
    return Variant(value);
  }

  /// @brief Return a Variant that points to static binary data.
  ///
  /// @param[in] static_data Pointer to statically-allocated binary data. The
  /// Variant will point to the data, not copy it.
  /// @param[in] size_bytes Size of the data, in bytes.
  ///
  /// @returns A Variant pointing to the binary data.
  ///
  /// @note If you use this function, you must ensure that the memory pointed
  /// to stays valid for the life of the Variant, otherwise call
  /// mutable_blob() or set_mutable_blob(), which will copy the data to an
  /// internal buffer.
  static Variant FromStaticBlob(const void* static_data, size_t size_bytes) {
    Variant v;
    v.set_static_blob(static_data, size_bytes);
    return v;
  }

  /// @brief Return a Variant containing a copy of binary data.
  ///
  /// @param[in] src_data Pointer to binary data to be copied into the Variant.
  /// @param[in] size_bytes Size of the data, in bytes.
  ///
  /// @returns A Variant containing a copy of the binary data.
  static Variant FromMutableBlob(const void* src_data, size_t size_bytes) {
    Variant v;
    v.set_mutable_blob(src_data, size_bytes);
    return v;
  }

  /// @brief Return a Variant from a string, but make it mutable.
  ///
  /// Only copies the string once, unlike Variant(std::string(value)), which
  /// copies the string twice.
  ///
  /// @param[in] value String value to copy into the Variant and make mutable.
  ///
  /// @returns A Variant containing a mutable copy of the string.
  static Variant MutableStringFromStaticString(const char* value) {
    std::string* str = new std::string(value);
    Variant v;
    v.AssignMutableString(&str);
    return v;
  }

  /// @brief Get the human-readable type name of a Variant type.
  ///
  /// @param[in] type Variant type to describe.
  ///
  /// @returns A string describing the type, suitable for error messages or
  /// debugging. For example "Int64" or "MutableString".
  static const char* TypeName(Type type);

 private:
  // Internal Type of data that this variant object contains to avoid breaking
  // API
  enum InternalType {
    /// Null, or no data.
    kInternalTypeNull = kTypeNull,
    /// A 64-bit integer.
    kInternalTypeInt64 = kTypeInt64,
    /// A double-precision floating point number.
    kInternalTypeDouble = kTypeDouble,
    /// A boolean value.
    kInternalTypeBool = kTypeBool,
    /// A statically-allocated string we point to.
    kInternalTypeStaticString = kTypeStaticString,
    /// A std::string.
    kInternalTypeMutableString = kTypeMutableString,
    /// A std::vector of Variant.
    kInternalTypeVector = kTypeVector,
    /// A std::map, mapping Variant to Variant.
    kInternalTypeMap = kTypeMap,
    /// An statically-allocated blob of data that we point to. Never constructed
    /// by default. Use Variant::FromStaticBlob() to create a Variant of this
    /// type.
    kInternalTypeStaticBlob = kTypeStaticBlob,
    /// A blob of data that the Variant holds. Never constructed by default. Use
    /// Variant::FromMutableBlob() to create a Variant of this type, and copy
    /// binary data from an existing source.
    kInternalTypeMutableBlob = kTypeMutableBlob,
    // A c string stored in the Variant internal data blob as opposed to be
    // newed as a std::string. Max size is 16 bytes on x64 and 8 bytes on x86.
    kInternalTypeSmallString = kTypeMutableBlob + 1,
    // Not a valid type. Used to get the total number of Variant types.
    kMaxTypeValue,
  };

  /// Human-readable type names, for error logging.
  static const char* const kTypeNames[];

  /// Assert that this Variant is of the given type, failing if it is not.
  void assert_is_type(Type type) const;

  /// Assert that this Variant is NOT of the given type, failing if it is.
  void assert_is_not_type(Type type) const;

  /// Assert that this Variant is a static string or mutable string, failing if
  /// it is not.
  void assert_is_string() const;

  /// Assert that this Variant is a static blob or mutable blob, failing if
  /// it is not.
  void assert_is_blob() const;

  /// Sets the blob's data pointer, for kTypeStaticBlob and kTypeMutableBlob.
  /// Asserts if the Variant isn't a blob. Caller is responsible for managing
  /// the pointer's memory and deleting any existing data at the location.
  void set_blob_pointer(const void* blob_ptr, size_t size) {
    assert_is_blob();
    value_.blob_value.ptr = static_cast<const uint8_t*>(blob_ptr);
    value_.blob_value.size = size;
  }

  // If you hit a compiler error here it means you are trying to construct a
  // variant with unsupported type. Ether cast to correct type or add support
  // below.
  template <typename T>
  void set_value_t(T value) = delete;

  // Get whether this Variant contains a small string.
  bool is_small_string() const { return type_ == kInternalTypeSmallString; }

  // Current type contained in this Variant.
  InternalType type_;

  // Older versions of visual studio cant have this inline in the union and do
  // sizeof for small string
  typedef struct {
    const uint8_t* ptr;
    size_t size;
  } BlobValue;

  // Union of plain old data (scalars or pointers).
  union Value {
    int64_t int64_value;
    double double_value;
    bool bool_value;
    const char* static_string_value;
    std::string* mutable_string_value;
    std::vector<Variant>* vector_value;
    std::map<Variant, Variant>* map_value;
    BlobValue blob_value;
    char small_string[sizeof(BlobValue)];
  } value_;

  static constexpr size_t kMaxSmallStringSize = sizeof(Value::small_string);

  friend class firebase::internal::VariantInternal;
};

template <>
inline void Variant::set_value_t<int64_t>(int64_t value) {
  set_int64_value(value);
}

template <>
inline void Variant::set_value_t<int>(int value) {
  set_int64_value(static_cast<int64_t>(value));
}

template <>
inline void Variant::set_value_t<int16_t>(int16_t value) {
  set_int64_value(static_cast<int64_t>(value));
}

template <>
inline void Variant::set_value_t<uint8_t>(uint8_t value) {
  set_int64_value(static_cast<int64_t>(value));
}

template <>
inline void Variant::set_value_t<int8_t>(int8_t value) {
  set_int64_value(static_cast<int64_t>(value));
}

template <>
inline void Variant::set_value_t<char>(char value) {
  set_int64_value(static_cast<int64_t>(value));
}

template <>
inline void Variant::set_value_t<double>(double value) {
  set_double_value(value);
}

template <>
inline void Variant::set_value_t<float>(float value) {
  set_double_value(static_cast<double>(value));
}

template <>
inline void Variant::set_value_t<bool>(bool value) {
  set_bool_value(value);
}

template <>
inline void Variant::set_value_t<const char*>(const char* value) {
  set_string_value(value);
}

template <>
inline void Variant::set_value_t<char*>(char* value) {
  set_mutable_string(value);
}

// NOLINTNEXTLINE - allow namespace overridden
}  // namespace firebase

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_VARIANT_H_
