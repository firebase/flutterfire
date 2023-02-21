/*
 * Copyright 2021 Google LLC
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

#ifndef FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_H_
#define FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_H_

#include "firebase/internal/platform.h"

#if FIREBASE_PLATFORM_ANDROID
#include <jni.h>
#endif  // FIREBASE_PLATFORM_ANDROID

#include <vector>

#include "firebase/app.h"
#include "firebase/gma/ad_view.h"
#include "firebase/gma/interstitial_ad.h"
#include "firebase/gma/rewarded_ad.h"
#include "firebase/gma/types.h"
#include "firebase/internal/common.h"

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(gma)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

namespace firebase {
// In the GMA docs, link to firebase::Future in the Firebase C++ docs.
#if defined(DOXYGEN_ADMOB)
/// @brief The Google Mobile Ads C++ SDK uses this class to return results from
/// asynchronous operations. All  C++ functions and method calls that operate
/// asynchronously return a <code>%Future</code>, and provide a "LastResult"
/// function to retrieve the most recent <code>%Future</code> result.
///
/// The Google Mobile Ads C++ SDK uses this class from the Firebase C++ SDK to
/// return results from asynchronous operations. For more information, see the
/// <a
/// href="https://firebase.google.com/docs/reference/cpp/class/firebase/future">Firebase
/// C++ SDK documentation</a>.
template <typename ResultType>
class Future {
  // Empty class (used for documentation only).
};
#endif  // defined(DOXYGEN_ADMOB)

/// @brief API for Google Mobile Ads with Firebase.
///
/// The GMA API allows you to load and display mobile ads using the Google
/// Mobile Ads SDK. Each ad format has its own header file.
namespace gma {

/// Initializes Google Mobile Ads (GMA) via Firebase.
///
/// @param[in] app The Firebase app for which to initialize mobile ads.
///
/// @param[out] init_result_out Optional: If provided, write the basic init
/// result here. kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the Google Mobile Ads SDK requires
/// Google Play services (for example, when using 'play-services-ads-lite').
/// Note that this does not include the adapter initialization status, which is
/// returned in the Future.
///
/// @return If init_result_out is kInitResultSuccess, this Future will contain
/// the initialization status of each adapter once initialization is complete.
/// Otherwise, the returned Future will have kFutureStatusInvalid.
Future<AdapterInitializationStatus> Initialize(
    const ::firebase::App& app, InitResult* init_result_out = nullptr);

#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
/// Initializes Google Mobile Ads (GMA) without Firebase for Android.
///
/// The arguments to @ref Initialize are platform-specific so the caller must do
/// something like this:
/// @code
/// #if defined(__ANDROID__)
/// firebase::gma::Initialize(jni_env, activity);
/// #else
/// firebase::gma::Initialize();
/// #endif
/// @endcode
///
/// @param[in] jni_env JNIEnv pointer.
/// @param[in] activity Activity used to start the application.
/// @param[out] init_result_out Optional: If provided, write the basic init
/// result here. kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the Google Mobile Ads SDK requires
/// Google Play services (for example, when using 'play-services-ads-lite').
/// Note that this does not include the adapter initialization status, which is
/// returned in the Future.
///
/// @return If init_result_out is kInitResultSuccess, this Future will contain
/// the initialization status of each adapter once initialization is complete.
/// Otherwise, the returned Future will have kFutureStatusInvalid.
Future<AdapterInitializationStatus> Initialize(
    JNIEnv* jni_env, jobject activity, InitResult* init_result_out = nullptr);

#endif  // defined(__ANDROID__) || defined(DOXYGEN)
#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
/// Initializes Google Mobile Ads (GMA) without Firebase for iOS.
///
/// @param[out] init_result_out Optional: If provided, write the basic init
/// result here. kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the Google Mobile Ads SDK requires
/// Google Play services (for example, when using 'play-services-ads-lite').
/// Note that this does not include the adapter initialization status, which is
/// returned in the Future.
///
/// @return If init_result_out is <code>kInitResultSuccess</code>, this Future
/// will contain the initialization status of each adapter once initialization
/// is complete. Otherwise, the returned Future will have
/// <code>kFutureStatusInvalid</code>.
Future<AdapterInitializationStatus> Initialize(
    InitResult* init_result_out = nullptr);
#endif  // !defined(__ANDROID__) || defined(DOXYGEN)

/// Get the Future returned by a previous call to
/// @ref firebase::gma::Initialize().
Future<AdapterInitializationStatus> InitializeLastResult();

/// Get the current adapter initialization status. You can poll this method to
/// check which adapters have been initialized.
AdapterInitializationStatus GetInitializationStatus();

/// Disables automated SDK crash reporting on iOS. If not called, the SDK
/// records the original exception handler if available and registers a new
/// exception handler. The new exception handler only reports SDK related
/// exceptions and calls the recorded original exception handler.
///
/// This method has no effect on Android.
void DisableSDKCrashReporting();

/// Disables mediation adapter initialization on iOS during initialization of
/// the GMA SDK. Calling this method may negatively impact your ad
/// performance and should only be called if you will not use GMA SDK
/// controlled mediation during this app session. This method must be called
/// before initializing the GMA SDK or loading ads and has no effect once the
/// SDK has been initialized.
///
/// This method has no effect on Android.
void DisableMediationInitialization();

/// Sets the global @ref RequestConfiguration that will be used for
/// every @ref AdRequest during the app's session.
///
/// @param[in] request_configuration The request configuration that should be
/// applied to all ad requests.
void SetRequestConfiguration(const RequestConfiguration& request_configuration);

/// Gets the global RequestConfiguration.
///
/// @return the currently active @ref RequestConfiguration that's being
/// used for every ad request.
/// @note: on iOS, the
/// @ref RequestConfiguration::tag_for_child_directed_treatment and
/// @ref RequestConfiguration::tag_for_under_age_of_consent fields will be set
/// to RequestConfiguration.kChildDirectedTreatmentUnspecified, and
/// RequestConfiguration.kUnderAgeOfConsentUnspecified, respectfully.
RequestConfiguration GetRequestConfiguration();

/// Opens the ad inspector UI.
///
/// @param[in] parent The platform-specific UI element that will host the
/// ad inspector.  For iOS this should be the window's
/// <code>UIViewController</code>. For Android this is the
/// <code>Activity</code> Context which the GMA SDK is running in.
/// @param[in] listener The listener will be invoked when the user closes
/// the ad inspector UI. @ref firebase::gma::Initialize(). must be called
/// prior to this function.
void OpenAdInspector(AdParent parent, AdInspectorClosedListener* listener);

/// Controls whether the Google Mobile Ads SDK Same App Key is enabled.
///
/// This function must be invoked after GMA has been initialized. The value set
/// persists across app sessions. The key is enabled by default.
///
/// This operation is supported on iOS only.  This is a no-op on Android
/// systems.
///
/// @param[in] is_enabled whether the Google Mobile Ads SDK Same App Key is
/// enabled.
void SetIsSameAppKeyEnabled(bool is_enabled);

/// @brief Terminate GMA.
///
/// Frees resources associated with GMA that were allocated during
/// @ref firebase::gma::Initialize().
void Terminate();

}  // namespace gma
}  // namespace firebase

#endif  // FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_H_
