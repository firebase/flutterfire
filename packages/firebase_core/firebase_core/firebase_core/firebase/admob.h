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

#ifndef FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_H_
#define FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_H_

#include "firebase/internal/platform.h"

#if FIREBASE_PLATFORM_ANDROID
#include <jni.h>
#endif  // FIREBASE_PLATFORM_ANDROID

#include "firebase/admob/banner_view.h"
#include "firebase/admob/interstitial_ad.h"
#include "firebase/admob/rewarded_video.h"
#include "firebase/admob/types.h"
#include "firebase/app.h"
#include "firebase/internal/common.h"

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(admob)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

namespace firebase {

/// @deprecated The functionality in the <code>firebase::admob</code> namespace
/// has been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the new
/// SDK in our <a href="/docs/admob/cpp/admob-migration">migration guide</a>.
///
/// @brief API for AdMob with Firebase.
///
/// The AdMob API allows you to load and display mobile ads using the Google
/// Mobile Ads SDK. Each ad format has its own header file.
namespace admob {

/// @deprecated
/// @brief Initializes AdMob via Firebase.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// @param app The Firebase app for which to initialize mobile ads.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the Google Mobile Ads SDK requires
/// Google Play services (for example, when using 'play-services-ads-lite').
FIREBASE_DEPRECATED InitResult Initialize(const ::firebase::App& app);

/// @deprecated
/// @brief Initializes AdMob via Firebase with the publisher's AdMob app ID.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// Initializing the Google Mobile Ads SDK with the AdMob app ID at app launch
/// allows the SDK to fetch app-level settings and perform configuration tasks
/// as early as possible. This can help reduce latency for the initial ad
/// request. AdMob app IDs are unique identifiers given to mobile apps when
/// they're registered in the AdMob console. To find your app ID in the AdMob
/// console, click the App management (https://apps.admob.com/#account/appmgmt:)
/// option under the settings dropdown (located in the upper right-hand corner).
/// App IDs have the form ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN.
///
/// @param[in] app The Firebase app for which to initialize mobile ads.
/// @param[in] admob_app_id The publisher's AdMob app ID.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the Google Mobile Ads SDK requires
/// Google Play services (for example, when using 'play-services-ads-lite').
FIREBASE_DEPRECATED InitResult Initialize(const ::firebase::App& app,
                                          const char* admob_app_id);

#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
/// @deprecated
/// @brief Initializes AdMob without Firebase for Android.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// The arguments to @ref Initialize are platform-specific so the caller must do
/// something like this:
/// @code
/// #if defined(__ANDROID__)
/// firebase::admob::Initialize(jni_env, activity);
/// #else
/// firebase::admob::Initialize();
/// #endif
/// @endcode
///
/// @param[in] jni_env JNIEnv pointer.
/// @param[in] activity Activity used to start the application.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the AdMob SDK requires
/// Google Play services (for example when using 'play-services-ads-lite').
FIREBASE_DEPRECATED InitResult Initialize(JNIEnv* jni_env, jobject activity);

/// @deprecated
/// @brief Initializes AdMob via Firebase with the publisher's AdMob app ID.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// Initializing the Google Mobile Ads SDK with the AdMob app ID at app launch
/// allows the SDK to fetch app-level settings and perform configuration tasks
/// as early as possible. This can help reduce latency for the initial ad
/// request. AdMob app IDs are unique identifiers given to mobile apps when
/// they're registered in the AdMob console. To find your app ID in the AdMob
/// console, click the App management (https://apps.admob.com/#account/appmgmt:)
/// option under the settings dropdown (located in the upper right-hand corner).
/// App IDs have the form ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN.
///
/// The arguments to @ref Initialize are platform-specific so the caller must do
/// something like this:
/// @code
/// #if defined(__ANDROID__)
/// firebase::admob::Initialize(jni_env, activity, admob_app_id);
/// #else
/// firebase::admob::Initialize(admob_app_id);
/// #endif
/// @endcode
///
/// @param[in] jni_env JNIEnv pointer.
/// @param[in] activity Activity used to start the application.
/// @param[in] admob_app_id The publisher's AdMob app ID.
///
/// @return kInitResultSuccess if initialization succeeded, or
/// kInitResultFailedMissingDependency on Android if Google Play services is not
/// available on the current device and the AdMob SDK requires
/// Google Play services (for example when using 'play-services-ads-lite').
FIREBASE_DEPRECATED InitResult Initialize(JNIEnv* jni_env, jobject activity,
                                          const char* admob_app_id);
#endif  // defined(__ANDROID__) || defined(DOXYGEN)
#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
/// @deprecated
/// @brief Initializes AdMob without Firebase for iOS.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
FIREBASE_DEPRECATED InitResult Initialize();

/// @deprecated
/// @brief Initializes AdMob with the publisher's AdMob app ID and without
/// Firebase for iOS.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// Initializing the Google Mobile Ads SDK with the AdMob app ID at app launch
/// allows the SDK to fetch app-level settings and perform configuration tasks
/// as early as possible. This can help reduce latency for the initial ad
/// request. AdMob app IDs are unique identifiers given to mobile apps when
/// they're registered in the AdMob console. To find your app ID in the AdMob
/// console, click the App management (https://apps.admob.com/#account/appmgmt:)
/// option under the settings dropdown (located in the upper right-hand corner).
/// App IDs have the form ca-app-pub-XXXXXXXXXXXXXXXX~NNNNNNNNNN.
///
/// @param[in] admob_app_id The publisher's AdMob app ID.
///
/// @return kInitResultSuccess if initialization succeeded
FIREBASE_DEPRECATED InitResult Initialize(const char* admob_app_id);
#endif  // !defined(__ANDROID__) || defined(DOXYGEN)

/// @deprecated
/// @brief Terminate AdMob.
///
/// The functionality in the <code>firebase::admob</code> namespace has
/// been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the
/// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
/// guide</a>.
///
/// Frees resources associated with AdMob that were allocated during
/// @ref firebase::admob::Initialize().
FIREBASE_DEPRECATED void Terminate();

}  // namespace admob
}  // namespace firebase

#endif  // FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_H_
