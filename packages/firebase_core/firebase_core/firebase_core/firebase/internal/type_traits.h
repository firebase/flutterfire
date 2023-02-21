/*
 * Copyright 2017 Google LLC
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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_TYPE_TRAITS_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_TYPE_TRAITS_H_

#include <cstdlib>
#include <type_traits>

// Doxygen breaks trying to parse this file, and since it is internal logic,
// it doesn't need to be included in the generated documentation.
#ifndef DOXYGEN

namespace firebase {

template <typename T>
struct remove_reference {
  typedef T type;
};

template <typename T>
struct remove_reference<T&> {
  typedef T type;
};

template <typename T>
struct remove_reference<T&&> {
  typedef T type;
};

template <typename T>
struct is_array {
  static constexpr bool value = false;
};

template <typename T>
struct is_array<T[]> {
  static constexpr bool value = true;
};

template <typename T, std::size_t N>
struct is_array<T[N]> {
  static constexpr bool value = true;
};

template <typename T>
struct is_lvalue_reference {
  static constexpr bool value = false;
};

template <typename T>
struct is_lvalue_reference<T&> {
  static constexpr bool value = true;
};

// STLPort does include <type_traits> header, but its contents are in `std::tr1`
// namespace. To work around this, use aliases.
// TODO(varconst): all of the reimplementations of traits above can be replaced
// with appropriate aliases.
// TODO(varconst): the traits in this file would be more conformant if they
// inherited from `std::integral_constant`.
#ifdef STLPORT
#define FIREBASE_TYPE_TRAITS_NS std::tr1
#else
#define FIREBASE_TYPE_TRAITS_NS std
#endif

template <typename T>
using decay = FIREBASE_TYPE_TRAITS_NS::decay<T>;

template <typename T>
using decay_t = typename decay<T>::type;

template <bool value, typename T = void>
using enable_if = FIREBASE_TYPE_TRAITS_NS::enable_if<value, T>;

template <typename T>
using is_floating_point = FIREBASE_TYPE_TRAITS_NS::is_floating_point<T>;

template <typename T>
using is_integral = FIREBASE_TYPE_TRAITS_NS::is_integral<T>;

template <typename T, typename U>
using is_same = FIREBASE_TYPE_TRAITS_NS::is_same<T, U>;

template <typename T, T value>
using integral_constant = FIREBASE_TYPE_TRAITS_NS::integral_constant<T, value>;

using true_type = FIREBASE_TYPE_TRAITS_NS::true_type;
using false_type = FIREBASE_TYPE_TRAITS_NS::false_type;

#undef FIREBASE_TYPE_TRAITS_NS

// `is_char<T>::value` is true iff `T` is a character type (including `wchar_t`
// and C++11 fixed-width character types).
template <typename T>
struct is_char {
  static constexpr bool value =
#if __cplusplus >= 202002L
      is_same<T, char8_t>::value ||
#endif
#if __cplusplus >= 201103L
      is_same<T, char16_t>::value || is_same<T, char32_t>::value ||
#endif
      is_same<T, char>::value || is_same<T, signed char>::value ||
      is_same<T, unsigned char>::value || is_same<T, wchar_t>::value;
};

// A subset of `std::is_integral`: excludes `bool` and character types.
template <typename T>
struct is_integer {
  static constexpr bool value =
      is_integral<T>::value && !is_same<T, bool>::value && !is_char<T>::value;
};

// NOLINTNEXTLINE - allow namespace overridden
}  // namespace firebase

#endif  // DOXYGEN

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_TYPE_TRAITS_H_
