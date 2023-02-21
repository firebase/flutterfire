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

#ifndef FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_NATIVE_EXPRESS_AD_VIEW_H_
#define FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_NATIVE_EXPRESS_AD_VIEW_H_

#include "firebase/admob/types.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

namespace firebase {
namespace admob {

namespace internal {
// Forward declaration for platform-specific data, implemented in each library.
class NativeExpressAdViewInternal;
}  // namespace internal

/// @deprecated The functionality in the <code>firebase::admob</code> namespace
/// has been replaced by the Google Mobile Ads SDK in the
/// <code>firebase::gma</code> namespace. Learn how to transition to the new
/// SDK in our <a href="/docs/admob/cpp/admob-migration">migration guide</a>.
/// Native Express Ads has been discontinued, and are no longer served.
///
/// @brief Loads and displays ads from AdMob Native Ads Express.
///
/// Each NativeExpressAdView object corresponds to a single AdMob Native Express
/// ad placement. There are methods to load an ad, move it, show it and hide it,
/// and retrieve the bounds of the ad onscreen.
///
/// NativeExpressAdView objects maintain a presentation state that indicates
/// whether or not they're currently onscreen, as well as a set of bounds
/// (stored in a @ref BoundingBox struct), but otherwise provide information
/// about their current state through Futures. Methods like @ref Initialize,
/// @ref LoadAd, and @ref Hide each have a corresponding @ref Future from which
/// the result of the last call can be determined. The two variants of
/// @ref MoveTo share a single result @ref Future, since they're essentially the
/// same action.
///
/// In addition, applications can create their own subclasses of
/// @ref NativeExpressAdView::Listener, pass an instance to the @ref SetListener
/// method, and receive callbacks whenever the presentation state or bounding
/// box of the ad changes.
///
/// For example, you could initialize, load, and show a native express ad view
/// while checking the result of the previous action at each step as follows:
///
/// @code
/// namespace admob = ::firebase::admob;
/// admob::NativeExpressAdView* ad_view = new admob::NativeExpressAdView();
/// ad_view->Initialize(ad_parent, "YOUR_AD_UNIT_ID", desired_ad_size)
/// @endcode
///
/// Then, later:
///
/// @code
/// if (ad_view->InitializeLastResult().Status() ==
///     ::firebase::kFutureStatusComplete &&
///     ad_view->InitializeLastResult().Error() ==
///     firebase::admob::kAdMobErrorNone) {
///   ad_view->LoadAd(your_ad_request);
/// }
/// @endcode
class NativeExpressAdView {
 public:
#ifdef INTERNAL_EXPERIMENTAL
// LINT.IfChange
#endif  // INTERNAL_EXPERIMENTAL
  /// @deprecated
  /// @brief The presentation state of a @ref NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a  href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  enum PresentationState {
    /// NativeExpressAdView is currently hidden.
    kPresentationStateHidden = 0,
    /// NativeExpressAdView is visible, but does not contain an ad.
    kPresentationStateVisibleWithoutAd,
    /// NativeExpressAdView is visible and contains an ad.
    kPresentationStateVisibleWithAd,
    /// NativeExpressAdView is visible and has opened a partial overlay on the
    /// screen.
    kPresentationStateOpenedPartialOverlay,
    /// NativeExpressAdView is completely covering the screen or has caused
    /// focus to leave the application (for example, when opening an external
    /// browser during a clickthrough).
    kPresentationStateCoveringUI,
  };
#ifdef INTERNAL_EXPERIMENTAL
// LINT.ThenChange(//depot_firebase_cpp/admob/client/cpp/src_java/com/google/firebase/admob/internal/cpp/ConstantsHelper.java)
#endif  // INTERNAL_EXPERIMENTAL

#ifdef INTERNAL_EXPERIMENTAL
// LINT.IfChange
#endif  // INTERNAL_EXPERIMENTAL
  /// @deprecated
  /// @brief The possible screen positions for a @ref NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  enum Position {
    /// Top of the screen, horizontally centered.
    kPositionTop = 0,
    /// Bottom of the screen, horizontally centered.
    kPositionBottom,
    /// Top-left corner of the screen.
    kPositionTopLeft,
    /// Top-right corner of the screen.
    kPositionTopRight,
    /// Bottom-left corner of the screen.
    kPositionBottomLeft,
    /// Bottom-right corner of the screen.
    kPositionBottomRight,
  };
#ifdef INTERNAL_EXPERIMENTAL
// LINT.ThenChange(//depot_firebase_cpp/admob/client/cpp/src_java/com/google/firebase/admob/internal/cpp/ConstantsHelper.java)
#endif  // INTERNAL_EXPERIMENTAL

  /// @deprecated
  /// @brief A listener class that developers can extend and pass to a
  /// @ref NativeExpressAdView object's @ref SetListener method to be notified
  /// of changes to the presentation state and bounding box.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  class Listener {
   public:
    /// @deprecated
    /// @brief This method is called when the @ref NativeExpressAdView object's
    /// presentation state changes.
    ///
    /// The functionality in the <code>firebase::admob</code> namespace has
    /// been replaced by the Google Mobile Ads SDK in the
    /// <code>firebase::gma</code> namespace. Learn how to transition to the
    /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
    /// guide</a>.
    /// @param[in] ad_view The native express ad view whose presentation state
    ///                    changed.
    /// @param[in] state The new presentation state.
    FIREBASE_DEPRECATED virtual void OnPresentationStateChanged(
        NativeExpressAdView* ad_view, PresentationState state) = 0;

    /// @deprecated
    /// @brief This method is called when the @ref NativeExpressAdView object's
    /// bounding box changes.
    ///
    /// The functionality in the <code>firebase::admob</code> namespace has
    /// been replaced by the Google Mobile Ads SDK in the
    /// <code>firebase::gma</code> namespace. Learn how to transition to the
    /// new SDK in our <a ref="/docs/admob/cpp/admob-migration>migration
    /// guide</a>.
    /// @param[in] ad_view The native express ad view whose bounding box
    ///                    changed.
    /// @param[in] box The new bounding box.
    FIREBASE_DEPRECATED virtual void OnBoundingBoxChanged(
        NativeExpressAdView* ad_view, BoundingBox box) = 0;

    virtual ~Listener();
  };

  /// @deprecated
  /// @brief Creates an uninitialized @ref NativeExpressAdView object.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  ///
  /// @ref Initialize must be called before the object is used.
  FIREBASE_DEPRECATED NativeExpressAdView();

  ~NativeExpressAdView();

  /// @deprecated
  /// @brief Initializes the @ref NativeExpressAdView object.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] parent The platform-specific UI element that will host the ad.
  /// @param[in] ad_unit_id The ad unit ID to use when requesting ads.
  /// @param[in] size The desired ad size for the native express ad.
  FIREBASE_DEPRECATED Future<void> Initialize(AdParent parent,
                                              const char* ad_unit_id,
                                              AdSize size);

  /// @deprecated
  /// @brief Returns a @ref Future that has the status of the last call to
  /// @ref Initialize.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> InitializeLastResult() const;

  /// @deprecated
  /// @brief Begins an asynchronous request for an ad. If successful, the ad
  /// will automatically be displayed in the NativeExpressAdView.
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
  /// @brief Hides the NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> Hide();

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Hide.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> HideLastResult() const;

  /// @deprecated
  /// @brief Shows the @ref NativeExpressAdView.
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
  /// @brief Pauses the @ref NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  ///
  /// Should be called whenever the C++ engine pauses or the application loses
  /// focus.
  FIREBASE_DEPRECATED Future<void> Pause();

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Pause.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> PauseLastResult() const;

  /// @deprecated
  /// @brief Resumes the @ref NativeExpressAdView after pausing.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> Resume();

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Resume.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> ResumeLastResult() const;

  /// @deprecated
  /// @brief Cleans up and deallocates any resources used by the
  /// @ref NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> Destroy();

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// @ref Destroy.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> DestroyLastResult() const;

  /// @deprecated
  /// @brief Moves the @ref NativeExpressAdView so that its top-left corner is
  /// located at (x, y). Coordinates are in pixels from the top-left corner of
  /// the screen.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  ///
  /// When built for Android, the library will not display an ad on top of or
  /// beneath an Activity's status bar. If a call to MoveTo would result in an
  /// overlap, the @ref NativeExpressAdView is placed just below the status bar,
  /// so no overlap occurs.
  /// @param[in] x The desired horizontal coordinate.
  /// @param[in] y The desired vertical coordinate.
  FIREBASE_DEPRECATED Future<void> MoveTo(int x, int y);

  /// @deprecated
  /// @brief Moves the @ref NativeExpressAdView so that it's located at the
  /// given pre-defined position.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a
  /// href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] position The pre-defined position to which to move the
  ///                     @ref NativeExpressAdView.
  FIREBASE_DEPRECATED Future<void> MoveTo(Position position);

  /// @deprecated
  /// @brief Returns a @ref Future containing the status of the last call to
  /// either version of @ref MoveTo.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  FIREBASE_DEPRECATED Future<void> MoveToLastResult() const;

  /// @deprecated
  /// @brief Returns the current presentation state of the
  /// @ref NativeExpressAdView.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @return The current presentation state.
  FIREBASE_DEPRECATED PresentationState GetPresentationState() const;

  /// @deprecated
  /// @brief Retrieves the @ref NativeExpressAdView's current onscreen size and
  /// location.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @return The current size and location. Values are in pixels, and location
  ///         coordinates originate from the top-left corner of the screen.
  FIREBASE_DEPRECATED BoundingBox GetBoundingBox() const;

  /// @deprecated
  /// @brief Sets the @ref Listener for this object.
  ///
  /// The functionality in the <code>firebase::admob</code> namespace has
  /// been replaced by the Google Mobile Ads SDK in the
  /// <code>firebase::gma</code> namespace. Learn how to transition to the
  /// new SDK in our <a href="/docs/admob/cpp/admob-migration">migration
  /// guide</a>.
  /// @param[in] listener A valid NativeExpressAdView::Listener to receive
  /// callbacks.
  FIREBASE_DEPRECATED void SetListener(Listener* listener);

 private:
  // An internal, platform-specific implementation object that this class uses
  // to interact with the Google Mobile Ads SDKs for iOS and Android.
  internal::NativeExpressAdViewInternal* internal_;
};

}  // namespace admob
}  // namespace firebase

#endif  // FIREBASE_ADMOB_SRC_INCLUDE_FIREBASE_ADMOB_NATIVE_EXPRESS_AD_VIEW_H_
