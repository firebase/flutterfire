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

#ifndef FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_INTERSTITIAL_AD_H_
#define FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_INTERSTITIAL_AD_H_

#include "firebase/admob/types.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

namespace firebase {
namespace admob {

namespace internal {
// Forward declaration for platform-specific data, implemented in each library.
class InterstitialAdInternal;
}  // namespace internal

/// @deprecated The functionality in the <code>firebase::admob</code> namespace
/// has been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the new
/// SDK in our <a href="/docs/admob/cpp/admob-migration">migration guide</a>.
///
/// @brief Loads and displays AdMob interstitial ads.
///
/// @ref InterstitialAd is a single-use object that can load and show a
/// single AdMob interstitial ad.
///
/// InterstitialAd objects maintain a presentation state that indicates whether
/// or not they're currently onscreen, but otherwise provide information about
/// their current state through Futures. @ref Initialize, @ref LoadAd, and
/// @ref Show each have a corresponding @ref Future from which you can determine
/// result of the previous call.
///
/// In addition, applications can create their own subclasses of
/// @ref InterstitialAd::Listener, pass an instance to the @ref SetListener
/// method, and receive callbacks whenever the presentation state changes.
///
/// Here's how one might initialize, load, and show an interstitial ad while
/// checking against the result of the previous action at each step:
///
/// @code
/// namespace admob = ::firebase::admob;
/// admob::InterstitialAd* interstitial = new admob::InterstitialAd();
/// interstitial->Initialize(ad_parent, "YOUR_AD_UNIT_ID")
/// @endcode
///
/// Then, later:
///
/// @code
/// if (interstitial->InitializeLastResult().status() ==
///     ::firebase::kFutureStatusComplete &&
///     interstitial->InitializeLastResult().error() ==
///     firebase::admob::kAdMobErrorNone) {
///   interstitial->LoadAd(my_ad_request);
/// }
/// @endcode
///
/// And after that:
///
/// @code
/// if (interstitial->LoadAdLastResult().status() ==
///     ::firebase::kFutureStatusComplete &&
///     interstitial->LoadAdLastResult().error() ==
///     firebase::admob::kAdMobErrorNone)) {
///   interstitial->Show();
/// }
/// @endcode
///
class InterstitialAd {
 public:
#ifdef INTERNAL_EXPERIMENTAL
// LINT.IfChange
#endif  // INTERNAL_EXPERIMENTAL
  /// @deprecated
  /// @brief The presentation states of an @ref InterstitialAd.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  enum PresentationState {
    /// InterstitialAd is not currently being shown.
    kPresentationStateHidden = 0,
    /// InterstitialAd is being shown or has caused focus to leave the
    /// application (for example, when opening an external browser during a
    /// clickthrough).
    kPresentationStateCoveringUI,
  };
#ifdef INTERNAL_EXPERIMENTAL
// LINT.ThenChange(//depot_firebase_cpp/admob/client/cpp/src_java/com/google/firebase/admob/internal/cpp/InterstitialAdHelper.java)
#endif  // INTERNAL_EXPERIMENTAL

  /// @deprecated
  /// @brief A listener class that developers can extend and pass to an
  /// @ref InterstitialAd object's @ref SetListener method to be notified of
  /// presentation state changes.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a ref="/docs/admob/cpp/admob-migration>migration
  /// guide</a>.
  ///
  /// This is useful for changes caused by user interaction, such as when the
  /// user closes an interstitial.
  ///
  class Listener {
   public:
    /// @deprecated
    /// @brief This method is called when the @ref InterstitialAd object's
    /// presentation state changes.
    ///
    /// The functionality in the <code>firebase::admob</code> namespace has
    /// been replaced by the Google Mobile Ads SDK in the
    /// <code>firebase::gma</code> namespace. Learn how to transition to the
    /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
    /// guide</a>.
    /// @param[in] interstitial_ad The interstitial ad whose presentation state
    ///                            changed.
    /// @param[in] state The new presentation state.
    virtual void OnPresentationStateChanged(InterstitialAd* interstitial_ad,
                                            PresentationState state) = 0;
    virtual ~Listener();
  };

  /// @deprecated
  /// @brief Creates an uninitialized @ref InterstitialAd object.
  /// @ref Initialize must be called before the object is used.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED InterstitialAd();

  ~InterstitialAd();

  /// @deprecated
  /// @brief Initialize the @ref InterstitialAd object.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] parent The platform-specific UI element that will host the ad.
  /// @param[in] ad_unit_id The ad unit ID to use in loading the ad.
  FIREBASE_DEPRECATED Future<void> Initialize(AdParent parent,
                                              const char* ad_unit_id);

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Initialize.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a
  /// href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> InitializeLastResult() const;

  /// @deprecated
  /// @brief Begins an asynchronous request for an ad.
  ///
  /// The @ref InterstitialAd::presentation_state method can be used to track
  /// the progress of the request.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] request An AdRequest struct with information about the request
  ///                    to be made (such as targeting info).
  FIREBASE_DEPRECATED Future<void> LoadAd(const AdRequest& request);

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref LoadAd.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> LoadAdLastResult() const;

  /// @deprecated
  /// @brief Shows the @ref InterstitialAd. This should not be called unless an
  /// ad has already been loaded.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> Show();

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Show.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> ShowLastResult() const;

  /// @deprecated
  /// @brief Returns the current presentation state of the @ref InterstitialAd.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @return The current presentation state.
  FIREBASE_DEPRECATED PresentationState presentation_state() const;

  /// @deprecated
  /// @brief Sets the @ref Listener for this @ref InterstitialAd.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] listener A valid InterstititalAd::Listener to receive
  ///                     callbacks.
  FIREBASE_DEPRECATED void SetListener(Listener* listener);

 private:
  // An internal, platform-specific implementation object that this class uses
  // to interact with the Google Mobile Ads SDKs for iOS and Android.
  internal::InterstitialAdInternal* internal_;
};

}  // namespace admob
}  // namespace firebase

#endif  // FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_INTERSTITIAL_AD_H_
