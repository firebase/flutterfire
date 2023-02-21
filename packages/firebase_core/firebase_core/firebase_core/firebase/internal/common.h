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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_COMMON_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_COMMON_H_

// This file contains definitions that configure the SDK.

// Include a STL header file, othewise _STLPORT_VERSION won't be set.
#include <utility>

// Move operators use rvalue references, which are a C++11 extension.
// Also, Visual Studio 2010 and later actually support move operators despite
// reporting __cplusplus to be 199711L, so explicitly check for that.
// Also, stlport doesn't implement std::move().
#if (__cplusplus >= 201103L || _MSC_VER >= 1600) && !defined(_STLPORT_VERSION)
#define FIREBASE_USE_MOVE_OPERATORS
#endif

// stlport doesn't implement std::function.
#if !defined(_STLPORT_VERSION)
#define FIREBASE_USE_STD_FUNCTION
#endif  // !defined(_STLPORT_VERSION)

// stlport doesn't implement std::aligned_storage.
#if defined(_STLPORT_VERSION)
#include <cstddef>

namespace firebase {
template <std::size_t Length, std::size_t Alignment>
struct AlignedStorage {
  struct type {
    alignas(Alignment) unsigned char data[Length];
  };
};
}  // namespace firebase
#define FIREBASE_ALIGNED_STORAGE ::firebase::AlignedStorage
#else
#include <type_traits>
#define FIREBASE_ALIGNED_STORAGE std::aligned_storage
#endif  // defined(_STLPORT_VERSION)

// Visual Studio 2013 does not support snprintf, so use streams instead.
#if !(defined(_MSC_VER) && _MSC_VER <= 1800)
#define FIREBASE_USE_SNPRINTF
#endif  // !(defined(_MSC_VER) && _MSC_VER <= 1800)

#if !(defined(_MSC_VER) && _MSC_VER <= 1800)
#define FIREBASE_USE_EXPLICIT_DEFAULT_METHODS
#endif  // !(defined(_MSC_VER) && _MSC_VER <= 1800)

#if !defined(DOXYGEN) && !defined(SWIG)
#if !defined(_WIN32) && !defined(__CYGWIN__)
// Prevent GCC & Clang from stripping a symbol.
#define FIREBASE_APP_KEEP_SYMBOL __attribute__((used))
#else
// MSVC needs to reference a symbol directly in the application for it to be
// kept in the final executable.  In this case, the end user's application
// must include the appropriate Firebase header (e.g firebase/analytics.h) to
// initialize the module.
#define FIREBASE_APP_KEEP_SYMBOL
#endif  // !defined(_WIN32) && !defined(__CYGWIN__)

// Module initializer's name.
//
// This can be used to explicitly include a module initializer in an application
// to prevent the object from being stripped by the linker.  The symbol is
// located in the "firebase" namespace so can be referenced using:
//
// ::firebase::FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE_NAME(name)
//
// Where "name" is the module name, for example "analytics".
#define FIREBASE_APP_REGISTER_CALLBACKS_INITIALIZER_NAME(module_name) \
  g_##module_name##_initializer

// Declare a module initializer variable as a global.
#define FIREBASE_APP_REGISTER_CALLBACKS_INITIALIZER_VARIABLE(module_name)     \
  namespace firebase {                                                        \
  extern void* FIREBASE_APP_REGISTER_CALLBACKS_INITIALIZER_NAME(module_name); \
  } /* namespace firebase */

// Generates code which references a module initializer.
// For example, FIREBASE_APP_REGISTER_REFERENCE(analytics) will register the
// module initializer for the analytics module.
#define FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(module_name)        \
  FIREBASE_APP_REGISTER_CALLBACKS_INITIALIZER_VARIABLE(module_name)   \
  namespace firebase {                                                \
  static void* module_name##_ref FIREBASE_APP_KEEP_SYMBOL =           \
      &FIREBASE_APP_REGISTER_CALLBACKS_INITIALIZER_NAME(module_name); \
  }     /* namespace firebase */
#endif  //  !defined(DOXYGEN) && !defined(SWIG)

#if defined(SWIG) || defined(DOXYGEN)
// SWIG needs to ignore the FIREBASE_DEPRECATED tag.
#define FIREBASE_DEPRECATED
#endif  // defined(SWIG) || defined(DOXYGEN)

#ifndef FIREBASE_DEPRECATED
#ifdef __GNUC__
#define FIREBASE_DEPRECATED __attribute__((deprecated))
#elif defined(_MSC_VER)
#define FIREBASE_DEPRECATED __declspec(deprecated)
#else
// We don't know how to mark functions as "deprecated" with this compiler.
#define FIREBASE_DEPRECATED
#endif
#endif  // FIREBASE_DEPRECATED

// Calculates the number of elements in an array.
#define FIREBASE_ARRAYSIZE(x) (sizeof(x) / sizeof((x)[0]))

// Guaranteed compile time strlen.
#define FIREBASE_STRLEN(s) (FIREBASE_ARRAYSIZE(s) - sizeof((s)[0]))

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_INTERNAL_COMMON_H_
