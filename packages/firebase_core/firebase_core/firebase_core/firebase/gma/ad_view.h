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

#ifndef FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_AD_VIEW_H_
#define FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_AD_VIEW_H_

#include "firebase/future.h"
#include "firebase/gma/types.h"
#include "firebase/internal/common.h"

namespace firebase {
namespace gma {

namespace internal {
// Forward declaration for platform-specific data, implemented in each library.
class AdViewInternal;
}  // namespace internal

class AdViewBoundingBoxListener;
struct BoundingBox;

/// @brief Loads and displays Google Mobile Ads AdView ads.
///
/// Each AdView object corresponds to a single GMA ad placement of a specified
/// size. There are methods to load an ad, move it, show it and hide it, and
/// retrieve the bounds of the ad onscreen.
///
/// AdView objects provide information about their current state through
/// Futures. Methods like @ref Initialize, @ref LoadAd, and @ref Hide each have
/// a corresponding @ref Future from which the result of the last call can be
/// determined. The two variants of @ref SetPosition share a single result
/// @ref Future, since they're essentially the same action.
///
/// For example, you could initialize, load, and show an AdView while
/// checking the result of the previous action at each step as follows:
///
/// @code
/// namespace gma = ::firebase::gma;
/// gma::AdView* ad_view = new gma::AdView();
/// ad_view->Initialize(ad_parent, "YOUR_AD_UNIT_ID", desired_ad_size)
/// @endcode
///
/// Then, later:
///
/// @code
/// if (ad_view->InitializeLastResult().status() ==
///     ::firebase::kFutureStatusComplete &&
///     ad_view->InitializeLastResult().error() ==
///     firebase::gma::kAdErrorCodeNone) {
///   ad_view->LoadAd(your_ad_request);
/// }
/// @endcode
class AdView {
 public:
  /// The possible screen positions for a @ref AdView, configured via
  /// @ref SetPosition.
  enum Position {
    /// The position isn't one of the predefined screen locations.
    kPositionUndefined = -1,
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

  /// Creates an uninitialized @ref AdView object.
  /// @ref Initialize must be called before the object is used.
  AdView();

  ~AdView();

  /// Initializes the @ref AdView object.
  /// @param[in] parent The platform-specific UI element that will host the ad.
  /// @param[in] ad_unit_id The ad unit ID to use when requesting ads.
  /// @param[in] size The desired ad size for the ad.
  Future<void> Initialize(AdParent parent, const char* ad_unit_id,
                          const AdSize& size);

  /// Returns a @ref Future that has the status of the last call to
  /// @ref Initialize.
  Future<void> InitializeLastResult() const;

  /// Begins an asynchronous request for an ad. If successful, the ad will
  /// automatically be displayed in the AdView.
  /// @param[in] request An AdRequest struct with information about the request
  ///                    to be made (such as targeting info).
  Future<AdResult> LoadAd(const AdRequest& request);

  /// Returns a @ref Future containing the status of the last call to
  /// @ref LoadAd.
  Future<AdResult> LoadAdLastResult() const;

  /// Retrieves the @ref AdView's current onscreen size and location.
  ///
  /// @return The current size and location. Values are in pixels, and location
  ///         coordinates originate from the top-left corner of the screen.
  BoundingBox bounding_box() const;

  /// Sets an AdListener for this ad view.
  ///
  /// @param[in] listener An AdListener object which will be invoked
  /// when lifecycle events occur on this AdView.
  void SetAdListener(AdListener* listener);

  /// Sets a listener to be invoked when the Ad's bounding box
  /// changes size or location.
  ///
  /// @param[in] listener A AdViewBoundingBoxListener object which will be
  /// invoked when the ad changes size, shape, or position.
  void SetBoundingBoxListener(AdViewBoundingBoxListener* listener);

  /// Sets a listener to be invoked when this ad is estimated to have earned
  /// money.
  ///
  /// @param[in] listener A PaidEventListener object to be invoked when a
  /// paid event occurs on the ad.
  void SetPaidEventListener(PaidEventListener* listener);

  /// Moves the @ref AdView so that its top-left corner is located at
  /// (x, y). Coordinates are in pixels from the top-left corner of the screen.
  ///
  /// When built for Android, the library will not display an ad on top of or
  /// beneath an <code>Activity</code>'s status bar. If a call to SetPostion
  /// would result in an overlap, the @ref AdView is placed just below the
  /// status bar, so no overlap occurs.
  /// @param[in] x The desired horizontal coordinate.
  /// @param[in] y The desired vertical coordinate.
  ///
  /// @return a @ref Future which will be completed when this move operation
  /// completes.
  Future<void> SetPosition(int x, int y);

  /// Moves the @ref AdView so that it's located at the given predefined
  /// position.
  ///
  /// @param[in] position The predefined position to which to move the
  ///   @ref AdView.
  ///
  /// @return a @ref Future which will be completed when this move operation
  /// completes.
  Future<void> SetPosition(Position position);

  /// Returns a @ref Future containing the status of the last call to either
  /// version of @ref SetPosition.
  Future<void> SetPositionLastResult() const;

  /// Hides the AdView.
  Future<void> Hide();

  /// Returns a @ref Future containing the status of the last call to
  /// @ref Hide.
  Future<void> HideLastResult() const;

  /// Shows the @ref AdView.
  Future<void> Show();

  /// Returns a @ref Future containing the status of the last call to
  /// @ref Show.
  Future<void> ShowLastResult() const;

  /// Pauses the @ref AdView. Should be called whenever the C++ engine
  /// pauses or the application loses focus.
  Future<void> Pause();

  /// Returns a @ref Future containing the status of the last call to
  /// @ref Pause.
  Future<void> PauseLastResult() const;

  /// Resumes the @ref AdView after pausing.
  Future<void> Resume();

  /// Returns a @ref Future containing the status of the last call to
  /// @ref Resume.
  Future<void> ResumeLastResult() const;

  /// Cleans up and deallocates any resources used by the @ref AdView.
  /// You must call this asynchronous operation before this object's destructor
  /// is invoked or risk leaking device resources.
  Future<void> Destroy();

  /// Returns a @ref Future containing the status of the last call to
  /// @ref Destroy.
  Future<void> DestroyLastResult() const;

  /// Returns the AdSize of the AdView.
  ///
  /// @return An @ref AdSize object representing the size of the ad.  If this
  /// view has not been initialized then the AdSize will be 0,0.
  AdSize ad_size() const;

 protected:
  /// Pointer to a listener for AdListener events.
  AdListener* ad_listener_;

  /// Pointer to a listener for BoundingBox events.
  AdViewBoundingBoxListener* ad_view_bounding_box_listener_;

  /// Pointer to a listener for paid events.
  PaidEventListener* paid_event_listener_;

 private:
  // An internal, platform-specific implementation object that this class uses
  // to interact with the Google Mobile Ads SDKs for iOS and Android.
  internal::AdViewInternal* internal_;
};

/// A listener class that developers can extend and pass to an @ref AdView
/// object's @ref AdView::SetBoundingBoxListener method to be notified of
/// changes to the size of the Ad's bounding box.
class AdViewBoundingBoxListener {
 public:
  virtual ~AdViewBoundingBoxListener();

  /// This method is called when the @ref AdView object's bounding box
  /// changes.
  ///
  /// @param[in] ad_view The view whose bounding box changed.
  /// @param[in] box The new bounding box.
  virtual void OnBoundingBoxChanged(AdView* ad_view, BoundingBox box) = 0;
};

/// @brief The screen location and dimensions of an AdView once it has been
/// initialized.
struct BoundingBox {
  /// Default constructor which initializes all member variables to 0.
  BoundingBox()
      : height(0), width(0), x(0), y(0), position(AdView::kPositionUndefined) {}

  /// Height of the ad in pixels.
  int height;
  /// Width of the ad in pixels.
  int width;
  /// Horizontal position of the ad in pixels from the left.
  int x;
  /// Vertical position of the ad in pixels from the top.
  int y;

  /// The position of the AdView if one has been set as the target position, or
  /// kPositionUndefined otherwise.
  AdView::Position position;
};

}  // namespace gma
}  // namespace firebase

#endif  // FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_AD_VIEW_H_
