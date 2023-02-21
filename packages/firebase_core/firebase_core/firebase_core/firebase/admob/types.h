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

#ifndef FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_TYPES_H_
#define FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_TYPES_H_

#include "firebase/internal/platform.h"

#if FIREBASE_PLATFORM_ANDROID
#include <jni.h>
#elif FIREBASE_PLATFORM_IOS || FIREBASE_PLATFORM_TVOS
extern "C" {
#include <objc/objc.h>
}  // extern "C"
#endif  // FIREBASE_PLATFORM_ANDROID, FIREBASE_PLATFORM_IOS,
        // FIREBASE_PLATFORM_TVOS

namespace firebase {
namespace admob {

/// @deprecated The functionality in the <code>firebase::admob</code> namespace
/// has been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the new
/// SDK in our <a href="/docs/admob/cpp/admob-migration">migration guide</a>.
///
/// @brief This is a platform specific datatype that is required to create an
/// AdMob ad.
///
/// The following defines the datatype on each platform:
/// <ul>
///   <li>Android: A `jobject` which references an Android Activity.</li>
///   <li>iOS: An `id` which references an iOS UIView.</li>
/// </ul>
///
#if FIREBASE_PLATFORM_ANDROID
/// An Android Activity from Java.
typedef jobject AdParent;
#elif FIREBASE_PLATFORM_IOS || FIREBASE_PLATFORM_TVOS
/// A pointer to an iOS UIView.
typedef id AdParent;
#else
/// A void pointer for stub classes.
typedef void *AdParent;
#endif  // FIREBASE_PLATFORM_ANDROID, FIREBASE_PLATFORM_IOS,
        // FIREBASE_PLATFORM_TVOS

#ifdef INTERNAL_EXPERIMENTAL
// LINT.IfChange
#endif  // INTERNAL_EXPERIMENTAL
/// @deprecated
/// @brief Error codes returned by Future::error().
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
enum AdMobError {
  /// Call completed successfully.
  kAdMobErrorNone,
  /// The ad has not been fully initialized.
  kAdMobErrorUninitialized,
  /// The ad is already initialized (repeat call).
  kAdMobErrorAlreadyInitialized,
  /// A call has failed because an ad is currently loading.
  kAdMobErrorLoadInProgress,
  /// A call to load an ad has failed due to an internal SDK error.
  kAdMobErrorInternalError,
  /// A call to load an ad has failed due to an invalid request.
  kAdMobErrorInvalidRequest,
  /// A call to load an ad has failed due to a network error.
  kAdMobErrorNetworkError,
  /// A call to load an ad has failed because no ad was available to serve.
  kAdMobErrorNoFill,
  /// An attempt has been made to show an ad on an Android Activity that has
  /// no window token (such as one that's not done initializing).
  kAdMobErrorNoWindowToken,
  /// Fallback error for any unidentified cases.
  kAdMobErrorUnknown,
};
#ifdef INTERNAL_EXPERIMENTAL
// LINT.ThenChange(//depot_firebase_cpp/admob/client/cpp/src_java/com/google/firebase/admob/internal/cpp/ConstantsHelper.java)
#endif  // INTERNAL_EXPERIMENTAL

/// @deprecated
/// @brief Types of ad sizes.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
enum AdSizeType { kAdSizeStandard = 0 };

/// @deprecated
/// @brief An ad size value to be used in requesting ads.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
struct AdSize {
  /// The type of ad size.
  AdSizeType ad_size_type;
  /// Height of the ad (in points or dp).
  int height;
  /// Width of the ad (in points or dp).
  int width;
};

/// @deprecated
/// @brief Gender information used as part of the
/// @ref firebase::admob::AdRequest struct.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
enum Gender {
  /// The gender of the current user is unknown or unspecified by the
  /// publisher.
  kGenderUnknown = 0,
  /// The current user is known to be male.
  kGenderMale,
  /// The current user is known to be female.
  kGenderFemale
};

/// @deprecated
/// @brief Indicates whether an ad request is considered tagged for
/// child-directed treatment.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
enum ChildDirectedTreatmentState {
  /// The child-directed status for the request is not indicated.
  kChildDirectedTreatmentStateUnknown = 0,
  /// The request is tagged for child-directed treatment.
  kChildDirectedTreatmentStateTagged,
  /// The request is not tagged for child-directed treatment.
  kChildDirectedTreatmentStateNotTagged
};

/// @deprecated
/// @brief Generic Key-Value container used for the "extras" values in an
/// @ref firebase::admob::AdRequest.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
struct KeyValuePair {
  /// The name for an "extra."
  const char *key;
  /// The value for an "extra."
  const char *value;
};

/// @deprecated
/// @brief The information needed to request an ad.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
struct AdRequest {
  /// An array of test device IDs specifying devices that test ads will be
  /// returned for.
  const char **test_device_ids;
  /// The number of entries in the array referenced by test_device_ids.
  unsigned int test_device_id_count;
  /// An array of keywords or phrases describing the current user activity, such
  /// as "Sports Scores" or "Football."
  const char **keywords;
  /// The number of entries in the array referenced by keywords.
  unsigned int keyword_count;
  /// A @ref KeyValuePair specifying additional parameters accepted by an ad
  /// network.
  const KeyValuePair *extras;
  /// The number of entries in the array referenced by extras.
  unsigned int extras_count;
  /// The day the user was born. Specify the user's birthday to increase ad
  /// relevancy.
  int birthday_day;
  /// The month the user was born. Specify the user's birthday to increase ad
  /// relevancy.
  int birthday_month;
  /// The year the user was born. Specify the user's birthday to increase ad
  /// relevancy.
  int birthday_year;
  /// The user's @ref Gender. Specify the user's gender to increase ad
  /// relevancy.
  Gender gender;
  /// Specifies whether the request should be considered as child-directed for
  /// purposes of the Children’s Online Privacy Protection Act (COPPA).
  ChildDirectedTreatmentState tagged_for_child_directed_treatment;
};

/// @deprecated
/// @brief The screen location and dimensions of an ad view once it has been
/// initialized.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
struct BoundingBox {
  /// Default constructor which initializes all member variables to 0.
  BoundingBox() : height(0), width(0), x(0), y(0) {}
  /// Height of the ad in pixels.
  int height;
  /// Width of the ad in pixels.
  int width;
  /// Horizontal position of the ad in pixels from the left.
  int x;
  /// Vertical position of the ad in pixels from the top.
  int y;
};

}  // namespace admob
}  // namespace firebase

#endif  // FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_TYPES_H_
