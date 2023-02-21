// Copyright 2016 Google Inc. All Rights Reserved.

#ifndef FIREBASE_APP_CLIENT_CPP_SRC_VERSION_H_
#define FIREBASE_APP_CLIENT_CPP_SRC_VERSION_H_

/// @def FIREBASE_VERSION_MAJOR
/// @brief Major version number of the Firebase C++ SDK.
/// @see kFirebaseVersionString
#define FIREBASE_VERSION_MAJOR 10
/// @def FIREBASE_VERSION_MINOR
/// @brief Minor version number of the Firebase C++ SDK.
/// @see kFirebaseVersionString
#define FIREBASE_VERSION_MINOR 5
/// @def FIREBASE_VERSION_REVISION
/// @brief Revision number of the Firebase C++ SDK.
/// @see kFirebaseVersionString
#define FIREBASE_VERSION_REVISION 0

/// @cond FIREBASE_APP_INTERNAL
#define FIREBASE_STRING_EXPAND(X) #X
#define FIREBASE_STRING(X) FIREBASE_STRING_EXPAND(X)
/// @endcond

// Version number.
// clang-format off
#define FIREBASE_VERSION_NUMBER_STRING        \
  FIREBASE_STRING(FIREBASE_VERSION_MAJOR) "." \
  FIREBASE_STRING(FIREBASE_VERSION_MINOR) "." \
  FIREBASE_STRING(FIREBASE_VERSION_REVISION)
// clang-format on

// Identifier for version string, e.g. kFirebaseVersionString.
#define FIREBASE_VERSION_IDENTIFIER(library) k##library##VersionString

// Concatenated version string, e.g. "Firebase C++ x.y.z".
#define FIREBASE_VERSION_STRING(library) \
  #library " C++ " FIREBASE_VERSION_NUMBER_STRING

#if !defined(DOXYGEN)
#if !defined(_WIN32) && !defined(__CYGWIN__)
#define DEFINE_FIREBASE_VERSION_STRING(library)          \
  extern volatile __attribute__((weak))                  \
      const char* FIREBASE_VERSION_IDENTIFIER(library);  \
  volatile __attribute__((weak))                         \
      const char* FIREBASE_VERSION_IDENTIFIER(library) = \
          FIREBASE_VERSION_STRING(library)
#else
#define DEFINE_FIREBASE_VERSION_STRING(library)             \
  static const char* FIREBASE_VERSION_IDENTIFIER(library) = \
      FIREBASE_VERSION_STRING(library)
#endif  // !defined(_WIN32) && !defined(__CYGWIN__)
#else   // if defined(DOXYGEN)

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {

/// @brief String which identifies the current version of the Firebase C++
/// SDK.
///
/// @see FIREBASE_VERSION_MAJOR
/// @see FIREBASE_VERSION_MINOR
/// @see FIREBASE_VERSION_REVISION
static const char* kFirebaseVersionString = FIREBASE_VERSION_STRING;

}  // namespace firebase
#endif  // !defined(DOXYGEN)

#endif  // FIREBASE_APP_CLIENT_CPP_SRC_VERSION_H_
