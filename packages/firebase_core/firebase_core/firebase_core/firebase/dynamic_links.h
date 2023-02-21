// Copyright 2017 Google LLC
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

#ifndef FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_H_
#define FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_H_

#include <string>

#include "firebase/app.h"
#include "firebase/internal/common.h"

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(dynamic_links)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

namespace firebase {

/// @brief Firebase Dynamic Links API.
///
/// Firebase Dynamic Links is a cross-platform solution for generating and
/// receiving links, whether or not the app is already installed.
namespace dynamic_links {

#ifndef SWIG
/// @brief Error code used by Futures returned by this API.
enum ErrorCode {
  kErrorCodeSuccess = 0,
  kErrorCodeFailed,
};
#endif  // SWIG

/// @brief Enum describing the strength of a dynamic links match.
///
/// This version is local to dynamic links; there is a similar enum in invites
/// and another internal version in app.
enum LinkMatchStrength {
  /// No match has been achieved
  kLinkMatchStrengthNoMatch = 0,

  /// The match between the Dynamic Link and device is not perfect.  You should
  /// not reveal any personal information related to the Dynamic Link.
  kLinkMatchStrengthWeakMatch,

  /// The match between the Dynamic Link and this device has a high confidence,
  /// but there is a small possibility of error.
  kLinkMatchStrengthStrongMatch,

  /// The match between the Dynamic Link and the device is exact.  You may
  /// safely reveal any personal information related to this Dynamic Link.
  kLinkMatchStrengthPerfectMatch
};

/// @brief The received Dynamic Link.
struct DynamicLink {
  /// The URL that was passed to the app.
  std::string url;
  /// The match strength of the dynamic link.
  LinkMatchStrength match_strength;
};

/// @brief Base class used to receive Dynamic Links.
class Listener {
 public:
  virtual ~Listener();

  /// Called on the client when a dynamic link arrives.
  ///
  /// @param[in] dynamic_link The data describing the Dynamic Link.
  virtual void OnDynamicLinkReceived(const DynamicLink* dynamic_link) = 0;
};

/// @brief Initialize Firebase Dynamic Links.
///
/// After Initialize is called, the implementation may call functions on the
/// Listener provided at any time.
///
/// @param[in] app The Firebase App object for this application.
/// @param[in] listener A Listener object that receives Dynamic Links.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is
/// not available on the current device.
InitResult Initialize(const App& app, Listener* listener);

/// @brief Terminate Firebase Dynamic Links.
void Terminate();

/// @brief Set the listener for receiving Dynamic Links.
///
/// @param[in] listener A Listener object that receives Dynamic Links.
///
/// @return Pointer to the previously set listener.
Listener* SetListener(Listener* listener);

/// Fetch any pending dynamic links. Each pending link will trigger a call to
/// the registered Listener class.
///
/// This function is implicitly called on initialization. On iOS this is called
/// automatically when the app gains focus, but on Android this needs to be
/// called manually.
void Fetch();

}  // namespace dynamic_links
}  // namespace firebase

#endif  // FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_H_
