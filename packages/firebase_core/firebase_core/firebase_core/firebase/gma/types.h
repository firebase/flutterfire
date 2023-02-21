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

#ifndef FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_TYPES_H_
#define FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_TYPES_H_

#include <map>
#include <memory>
#include <string>
#include <unordered_set>
#include <vector>

#include "firebase/future.h"
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
namespace gma {

struct AdErrorInternal;
struct AdapterResponseInfoInternal;
struct BoundingBox;
struct ResponseInfoInternal;

class AdapterResponseInfo;
class AdViewBoundingBoxListener;
class GmaInternal;
class AdView;
class InterstitialAd;
class PaidEventListener;
class ResponseInfo;

namespace internal {
class AdViewInternal;
}

/// This is a platform specific datatype that is required to create
/// a Google Mobile Ads ad.
///
/// The following defines the datatype on each platform:
/// <ul>
///   <li>Android: A `jobject` which references an Android Activity.</li>
///   <li>iOS: An `id` which references an iOS UIView.</li>
/// </ul>
#if FIREBASE_PLATFORM_ANDROID
/// An Android Activity from Java.
typedef jobject AdParent;
#elif FIREBASE_PLATFORM_IOS || FIREBASE_PLATFORM_TVOS
/// A pointer to an iOS UIView.
typedef id AdParent;
#else
/// A void pointer for stub classes.
typedef void* AdParent;
#endif  // FIREBASE_PLATFORM_ANDROID, FIREBASE_PLATFORM_IOS,
        // FIREBASE_PLATFORM_TVOS

/// Error codes returned by Future::error().
enum AdErrorCode {
  /// Call completed successfully.
  kAdErrorCodeNone,
  /// The ad has not been fully initialized.
  kAdErrorCodeUninitialized,
  /// The ad is already initialized (repeat call).
  kAdErrorCodeAlreadyInitialized,
  /// A call has failed because an ad is currently loading.
  kAdErrorCodeLoadInProgress,
  /// A call to load an ad has failed due to an internal SDK error.
  kAdErrorCodeInternalError,
  /// A call to load an ad has failed due to an invalid request.
  kAdErrorCodeInvalidRequest,
  /// A call to load an ad has failed due to a network error.
  kAdErrorCodeNetworkError,
  /// A call to load an ad has failed because no ad was available to serve.
  kAdErrorCodeNoFill,
  /// An attempt has been made to show an ad on an Android Activity that has
  /// no window token (such as one that's not done initializing).
  kAdErrorCodeNoWindowToken,
  /// An attempt to load an Ad Network extras class for an ad request has
  /// failed.
  kAdErrorCodeAdNetworkClassLoadError,
  /// The ad server experienced a failure processing the request.
  kAdErrorCodeServerError,
  /// The current device’s OS is below the minimum required version.
  kAdErrorCodeOSVersionTooLow,
  /// The request was unable to be loaded before being timed out.
  kAdErrorCodeTimeout,
  /// Will not send request because the interstitial object has already been
  /// used.
  kAdErrorCodeInterstitialAlreadyUsed,
  /// The mediation response was invalid.
  kAdErrorCodeMediationDataError,
  /// Error finding or creating a mediation ad network adapter.
  kAdErrorCodeMediationAdapterError,
  /// Attempting to pass an invalid ad size to an adapter.
  kAdErrorCodeMediationInvalidAdSize,
  /// Invalid argument error.
  kAdErrorCodeInvalidArgument,
  /// Received invalid response.
  kAdErrorCodeReceivedInvalidResponse,
  /// Will not send a request because the rewarded ad object has already been
  /// used.
  kAdErrorCodeRewardedAdAlreadyUsed,
  /// A mediation ad network adapter received an ad request, but did not fill.
  /// The adapter’s error is included as an underlyingError.
  kAdErrorCodeMediationNoFill,
  /// Will not send request because the ad object has already been used.
  kAdErrorCodeAdAlreadyUsed,
  /// Will not send request because the application identifier is missing.
  kAdErrorCodeApplicationIdentifierMissing,
  /// Android Ad String is invalid.
  kAdErrorCodeInvalidAdString,
  /// The ad can not be shown when app is not in the foreground.
  kAdErrorCodeAppNotInForeground,
  /// A mediation adapter failed to show the ad.
  kAdErrorCodeMediationShowError,
  /// The ad is not ready to be shown.
  kAdErrorCodeAdNotReady,
  /// Ad is too large for the scene.
  kAdErrorCodeAdTooLarge,
  /// Attempted to present ad from a non-main thread. This is an internal
  /// error which should be reported to support if encountered.
  kAdErrorCodeNotMainThread,
  /// A debug operation failed because the device is not in test mode.
  kAdErrorCodeNotInTestMode,
  /// An attempt to load the Ad Inspector failed.
  kAdErrorCodeInspectorFailedToLoad,
  /// The request to show the Ad Inspector failed because it's already open.
  kAdErrorCodeInsepctorAlreadyOpen,
  /// Fallback error for any unidentified cases.
  kAdErrorCodeUnknown,
};

/// A listener for receiving notifications during the lifecycle of a BannerAd.
class AdListener {
 public:
  virtual ~AdListener();

  /// Called when a click is recorded for an ad.
  virtual void OnAdClicked() {}

  /// Called when the user is about to return to the application after clicking
  /// on an ad.
  virtual void OnAdClosed() {}

  /// Called when an impression is recorded for an ad.
  virtual void OnAdImpression() {}

  /// Called when an ad opens an overlay that covers the screen.
  virtual void OnAdOpened() {}
};

/// Information about why an ad operation failed.
class AdError {
 public:
  /// Default Constructor.
  AdError();

  /// Copy Constructor.
  AdError(const AdError& ad_error);

  /// Destructor.
  virtual ~AdError();

  /// Assignment operator.
  AdError& operator=(const AdError& obj);

  /// Retrieves an AdError which represents the cause of this error.
  ///
  /// @return a pointer to an adError which represents the cause of this
  /// AdError.  If there was no cause then nullptr is returned.
  std::unique_ptr<AdError> GetCause() const;

  /// Gets the error's code.
  AdErrorCode code() const;

  /// Gets the domain of the error.
  const std::string& domain() const;

  /// Gets the message describing the error.
  const std::string& message() const;

  /// Gets the ResponseInfo if an error occurred during a loadAd operation.
  /// The ResponseInfo will have empty fields if this AdError does not
  /// represent an error stemming from a load ad operation.
  const ResponseInfo& response_info() const;

  /// Returns a log friendly string version of this object.
  virtual const std::string& ToString() const;

  /// A domain string which represents an undefined error domain.
  ///
  /// The GMA SDK returns this domain for domain() method invocations when
  /// converting error information from legacy mediation adapter callbacks.
  static const char* const kUndefinedDomain;

 private:
  friend class AdapterResponseInfo;
  friend class GmaInternal;
  friend class AdView;
  friend class InterstitialAd;

  /// Constructor used when building results in Ad event callbacks.
  explicit AdError(const AdErrorInternal& ad_error_internal);

  // Collection of response from adapters if this Result is due to a loadAd
  // operation.
  ResponseInfo* response_info_;

  // An internal, platform-specific implementation object that this class uses
  // to interact with the Google Mobile Ads SDKs for iOS and Android.
  AdErrorInternal* internal_;
};

/// Information about an ad response.
class ResponseInfo {
 public:
  /// Constructor creates an uninitialized ResponseInfo.
  ResponseInfo();

  /// Gets the AdapterResponseInfo objects for the ad response.
  ///
  /// @return a vector of AdapterResponseInfo objects containing metadata for
  ///   each adapter included in the ad response.
  const std::vector<AdapterResponseInfo>& adapter_responses() const {
    return adapter_responses_;
  }

  /// A class name that identifies the ad network that returned the ad.
  /// Returns an empty string if the ad failed to load.
  const std::string& mediation_adapter_class_name() const {
    return mediation_adapter_class_name_;
  }

  /// Gets the response ID string for the loaded ad.  Returns an empty
  /// string if the ad fails to load.
  const std::string& response_id() const { return response_id_; }

  /// Gets a log friendly string version of this object.
  const std::string& ToString() const { return to_string_; }

 private:
  friend class AdError;
  friend class GmaInternal;

  explicit ResponseInfo(const ResponseInfoInternal& internal);

  std::vector<AdapterResponseInfo> adapter_responses_;
  std::string mediation_adapter_class_name_;
  std::string response_id_;
  std::string to_string_;
};

/// Information about the result of an ad operation.
class AdResult {
 public:
  /// Default Constructor.
  AdResult();

  /// Constructor.
  explicit AdResult(const AdError& ad_error);

  /// Destructor.
  virtual ~AdResult();

  /// Returns true if the operation was successful.
  bool is_successful() const;

  /// An object representing an error which occurred during an ad operation.
  /// If the @ref AdResult::is_successful() returned true, then the
  /// @ref AdError object returned via this method will contain no contextual
  /// information.
  const AdError& ad_error() const;

  /// For debugging and logging purposes, successfully loaded ads provide a
  /// ResponseInfo object which contains information about the adapter which
  /// loaded the ad. If the ad failed to load then the object returned from
  /// this method will have default values. Information about the error
  /// should be retrieved via @ref AdResult::ad_error() instead.
  const ResponseInfo& response_info() const;

 private:
  friend class GmaInternal;

  /// Constructor invoked upon successful ad load. This contains response
  /// information from the adapter which loaded the ad.
  explicit AdResult(const ResponseInfo& response_info);

  /// Denotes if the @ref AdResult represents a success or an error.
  bool is_successful_;

  /// Information about the error.  Will be a default-constructed @ref AdError
  /// if this result represents a success.
  AdError ad_error_;

  /// Information from the adapter which loaded the ad.
  ResponseInfo response_info_;
};

/// A snapshot of a mediation adapter's initialization status.
class AdapterStatus {
 public:
  AdapterStatus() : is_initialized_(false), latency_(0) {}

  /// Detailed description of the status.
  ///
  /// This method should only be used for informational purposes, such as
  /// logging. Use @ref is_initialized to make logical decisions regarding an
  /// adapter's status.
  const std::string& description() const { return description_; }

  /// Returns the adapter's initialization state.
  bool is_initialized() const { return is_initialized_; }

  /// The adapter's initialization latency in milliseconds.
  /// 0 if initialization has not yet ended.
  int latency() const { return latency_; }

#if !defined(DOXYGEN)
  // Equality operator for testing.
  bool operator==(const AdapterStatus& rhs) const {
    return (description() == rhs.description() &&
            is_initialized() == rhs.is_initialized() &&
            latency() == rhs.latency());
  }
#endif  // !defined(DOXYGEN)

 private:
  friend class GmaInternal;
  std::string description_;
  bool is_initialized_;
  int latency_;
};

/// An immutable snapshot of the GMA SDK’s initialization status, categorized
/// by mediation adapter.
class AdapterInitializationStatus {
 public:
  /// Initialization status of each known ad network, keyed by its adapter's
  /// class name.
  std::map<std::string, AdapterStatus> GetAdapterStatusMap() const {
    return adapter_status_map_;
  }
#if !defined(DOXYGEN)
  // Equality operator for testing.
  bool operator==(const AdapterInitializationStatus& rhs) const {
    return (GetAdapterStatusMap() == rhs.GetAdapterStatusMap());
  }
#endif  // !defined(DOXYGEN)

 private:
  friend class GmaInternal;
  std::map<std::string, AdapterStatus> adapter_status_map_;
};

/// Listener to be invoked when the Ad Inspector has been closed.
class AdInspectorClosedListener {
 public:
  virtual ~AdInspectorClosedListener();

  /// Called when the user clicked the ad.  The AdResult contains the status of
  /// the operation, including details of the error if one occurred.
  virtual void OnAdInspectorClosed(const AdResult& ad_result) = 0;
};

/// @brief Response information for an individual ad network contained within
/// a @ref ResponseInfo object.
class AdapterResponseInfo {
 public:
  /// Destructor
  ~AdapterResponseInfo();

  /// @brief Information about the result including whether an error
  /// occurred, and any contextual information about that error.
  ///
  /// @return the error that occurred while rendering the ad.  If no error
  /// occurred then the AdResult's successful method will return true.
  AdResult ad_result() const { return ad_result_; }

  /// Returns a string representation of a class name that identifies the ad
  /// network adapter.
  const std::string& adapter_class_name() const { return adapter_class_name_; }

  /// Amount of time the ad network spent loading an ad.
  ///
  /// @return number of milliseconds the network spent loading an ad. This value
  /// is 0 if the network did not make a load attempt.
  int64_t latency_in_millis() const { return latency_; }

  /// A log friendly string version of this object.
  const std::string& ToString() const { return to_string_; }

 private:
  friend class ResponseInfo;

  /// Constructs an Adapter Response Info Object.
  explicit AdapterResponseInfo(const AdapterResponseInfoInternal& internal);

  AdResult ad_result_;
  std::string adapter_class_name_;
  int64_t latency_;
  std::string to_string_;
};

/// The size of a banner ad.
class AdSize {
 public:
  ///  Denotes the orientation of the AdSize.
  enum Orientation {
    /// AdSize should reflect the current orientation of the device.
    kOrientationCurrent = 0,

    /// AdSize will be adaptively formatted in Landscape mode.
    kOrientationLandscape,

    /// AdSize will be adaptively formatted in Portrait mode.
    kOrientationPortrait
  };

  /// Denotes the type size object that the @ref AdSize represents.
  enum Type {
    /// The standard AdSize type of a set height and width.
    kTypeStandard = 0,

    /// An adaptive size anchored to a portion of the screen.
    kTypeAnchoredAdaptive,

    /// An adaptive size intended to be embedded in scrollable content.
    kTypeInlineAdaptive,
  };

  /// Mobile Marketing Association (MMA) banner ad size (320x50
  /// density-independent pixels).
  static const AdSize kBanner;

  /// Interactive Advertising Bureau (IAB) full banner ad size
  /// (468x60 density-independent pixels).
  static const AdSize kFullBanner;

  /// Taller version of kBanner. Typically 320x100.
  static const AdSize kLargeBanner;

  /// Interactive Advertising Bureau (IAB) leaderboard ad size
  /// (728x90 density-independent pixels).
  static const AdSize kLeaderboard;

  /// Interactive Advertising Bureau (IAB) medium rectangle ad size
  /// (300x250 density-independent pixels).
  static const AdSize kMediumRectangle;

  /// Creates a new AdSize.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  /// @param[in] height The height of the ad in density-independent pixels.
  AdSize(uint32_t width, uint32_t height);

  /// @brief Creates an AdSize with the given width and a Google-optimized
  /// height to create a banner ad in landscape mode.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a Google-optimized height
  /// to create a banner ad. The size returned will have an aspect ratio
  /// similar to BANNER, suitable for anchoring near the top or bottom of
  /// your app. The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetLandscapeAnchoredAdaptiveBannerAdSize(uint32_t width);

  /// @brief Creates an AdSize with the given width and a Google-optimized
  /// height to create a banner ad in portrait mode.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a Google-optimized height
  /// to create a banner ad. The size returned will have an aspect ratio
  /// similar to BANNER, suitable for anchoring near the top or bottom
  /// of your app. The exact size of the ad returned can be retrieved by
  /// calling @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetPortraitAnchoredAdaptiveBannerAdSize(uint32_t width);

  /// @brief Creates an AdSize with the given width and a Google-optimized
  /// height to create a banner ad given the current orientation.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a Google-optimized height
  /// to create a banner ad. The size returned will have an aspect ratio
  /// similar to AdSize, suitable for anchoring near the top or bottom of
  /// your app. The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetCurrentOrientationAnchoredAdaptiveBannerAdSize(
      uint32_t width);

  /// @brief This ad size is most suitable for banner ads given a maximum
  /// height.
  ///
  /// This AdSize allows Google servers to choose an optimal ad size with
  /// a height less than or equal to the max height given in
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  /// @param[in] max_height The maximum height that a loaded ad will have. Must
  /// be
  ///  at least 32 dp, but a maxHeight of 50 dp or higher is recommended.
  ///
  /// @return an AdSize with the given width and a height that is always 0.
  /// The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetInlineAdaptiveBannerAdSize(int width, int max_height);

  /// @brief Creates an AdSize with the given width and the device’s
  /// landscape height.
  ///
  /// This ad size allows Google servers to choose an optimal ad size with
  /// a height less than or equal to the height of the screen in landscape
  /// orientation.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a height that is always 0.
  /// The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetLandscapeInlineAdaptiveBannerAdSize(int width);

  /// @brief Creates an AdSize with the given width and the device’s
  /// portrait height.
  ///
  /// This ad size allows Google servers to choose an optimal ad size with
  /// a height less than or equal to the height of the screen in portrait
  /// orientation.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a height that is always 0.
  /// The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetPortraitInlineAdaptiveBannerAdSize(int width);

  /// @brief A convenience method to return an inline adaptive banner ad size
  /// given the current interface orientation.
  ///
  /// This AdSize allows Google servers to choose an optimal ad size with a
  /// height less than or equal to the height of the screen in the requested
  /// orientation.
  ///
  /// @param[in] width The width of the ad in density-independent pixels.
  ///
  /// @return an AdSize with the given width and a height that is always 0.
  /// The exact size of the ad returned can be retrieved by calling
  /// @ref AdView::ad_size once the ad has been loaded.
  static AdSize GetCurrentOrientationInlineAdaptiveBannerAdSize(int width);

  /// Comparison operator.
  ///
  /// @return true if `rhs` refers to the same AdSize as `this`.
  bool operator==(const AdSize& rhs) const;

  /// Comparison operator.
  ///
  /// @returns true if `rhs` refers to a different AdSize as `this`.
  bool operator!=(const AdSize& rhs) const;

  /// The width of the region represented by this AdSize.  Value is in
  /// density-independent pixels.
  uint32_t width() const { return width_; }

  /// The height of the region represented by this AdSize. Value is in
  /// density-independent pixels.
  uint32_t height() const { return height_; }

  /// The AdSize orientation.
  Orientation orientation() const { return orientation_; }

  /// The AdSize type, either standard size or adaptive.
  Type type() const { return type_; }

 private:
  friend class firebase::gma::internal::AdViewInternal;

  /// Returns an Anchor Adpative AdSize Object given a width and orientation.
  static AdSize GetAnchoredAdaptiveBannerAdSize(uint32_t width,
                                                Orientation orientation);

  /// Returns true if the AdSize parameter is equivalient to this AdSize object.
  bool is_equal(const AdSize& ad_size) const;

  /// Denotes the orientation for anchored adaptive AdSize objects.
  Orientation orientation_;

  /// Advertisement width in platform-indepenent pixels.
  uint32_t width_;

  /// Advertisement width in platform-indepenent pixels.
  uint32_t height_;

  /// The type of AdSize (standard or adaptive)
  Type type_;
};

/// Contains targeting information used to fetch an ad.
class AdRequest {
 public:
  /// Creates an @ref AdRequest with no custom configuration.
  AdRequest();

  /// Creates an @ref AdRequest with the optional content URL.
  ///
  /// When requesting an ad, apps may pass the URL of the content they are
  /// serving. This enables keyword targeting to match the ad with the content.
  ///
  /// The URL is ignored if null or the number of characters exceeds 512.
  ///
  /// @param[in] content_url the url of the content being viewed.
  explicit AdRequest(const char* content_url);

  ~AdRequest();

  /// The content URL targeting information.
  ///
  /// @return the content URL for the @ref AdRequest. The string will be empty
  /// if no content URL has been configured.
  const std::string& content_url() const { return content_url_; }

  /// A Map of adapter class names to their collection of extra parameters, as
  /// configured via @ref add_extra.
  const std::map<std::string, std::map<std::string, std::string> >& extras()
      const {
    return extras_;
  }

  /// Keywords which will help GMA to provide targeted ads, as added by
  /// @ref add_keyword.
  const std::unordered_set<std::string>& keywords() const { return keywords_; }

  /// Returns the set of neighboring content URLs or an empty set if no URLs
  /// were set via @ref add_neighboring_content_urls().
  const std::unordered_set<std::string>& neighboring_content_urls() const {
    return neighboring_content_urls_;
  }

  /// Add a network extra for the associated ad mediation adapter.
  ///
  /// Appends an extra to the corresponding list of extras for the ad mediation
  /// adapter. Each ad mediation adapter can have multiple extra strings.
  ///
  /// @param[in] adapter_class_name the class name of the ad mediation adapter
  /// for which to add the extra.
  /// @param[in] extra_key a key which will be passed to the corresponding ad
  /// mediation adapter.
  /// @param[in] extra_value the value associated with extra_key.
  void add_extra(const char* adapter_class_name, const char* extra_key,
                 const char* extra_value);

  /// Adds a keyword for targeting purposes.
  ///
  /// Multiple keywords may be added via repeated invocations of this method.
  ///
  /// @param[in] keyword a string that GMA will use to aid in targeting ads.
  void add_keyword(const char* keyword);

  /// When requesting an ad, apps may pass the URL of the content they are
  /// serving. This enables keyword targeting to match the ad with the content.
  ///
  /// The URL is ignored if null or the number of characters exceeds 512.
  ///
  /// @param[in] content_url the url of the content being viewed.
  void set_content_url(const char* content_url);

  /// Adds to the list of URLs which represent web content near an ad.
  ///
  /// Promotes brand safety and allows displayed ads to have an app level
  /// rating (MA, T, PG, etc) that is more appropriate to neighboring content.
  ///
  /// Subsequent invocations append to the existing list.
  ///
  /// @param[in] neighboring_content_urls neighboring content URLs to be
  /// attached to the existing neighboring content URLs.
  void add_neighboring_content_urls(
      const std::vector<std::string>& neighboring_content_urls);

 private:
  std::string content_url_;
  std::map<std::string, std::map<std::string, std::string> > extras_;
  std::unordered_set<std::string> keywords_;
  std::unordered_set<std::string> neighboring_content_urls_;
};

/// Describes a reward credited to a user for interacting with a RewardedAd.
class AdReward {
 public:
  /// Creates an @ref AdReward.
  AdReward(const std::string& type, int64_t amount)
      : type_(type), amount_(amount) {}

  /// Returns the reward amount.
  int64_t amount() const { return amount_; }

  /// Returns the type of the reward.
  const std::string& type() const { return type_; }

 private:
  const int64_t amount_;
  const std::string type_;
};

/// The monetary value earned from an ad.
class AdValue {
 public:
  /// Allowed constants for @ref precision_type().
  enum PrecisionType {
    /// An ad value with unknown precision.
    kdValuePrecisionUnknown = 0,
    /// An ad value estimated from aggregated data.
    kAdValuePrecisionEstimated,
    /// A publisher-provided ad value, such as manual CPMs in a mediation group.
    kAdValuePrecisionPublisherProvided = 2,
    /// The precise value paid for this ad.
    kAdValuePrecisionPrecise = 3
  };

  /// Constructor
  AdValue(const char* currency_code, PrecisionType precision_type,
          int64_t value_micros)
      : currency_code_(currency_code),
        precision_type_(precision_type),
        value_micros_(value_micros) {}

  /// The value's ISO 4217 currency code.
  const std::string& currency_code() const { return currency_code_; }

  /// The precision of the reported ad value.
  PrecisionType precision_type() const { return precision_type_; }

  /// The ad's value in micro-units, where 1,000,000 micro-units equal one
  /// unit of the currency.
  int64_t value_micros() const { return value_micros_; }

 private:
  const std::string currency_code_;
  const PrecisionType precision_type_;
  const int64_t value_micros_;
};

/// @brief Listener to be invoked when ads show and dismiss full screen content,
/// such as a fullscreen ad experience or an in-app browser.
class FullScreenContentListener {
 public:
  virtual ~FullScreenContentListener();

  /// Called when the user clicked the ad.
  virtual void OnAdClicked() {}

  /// Called when the ad dismissed full screen content.
  virtual void OnAdDismissedFullScreenContent() {}

  /// Called when the ad failed to show full screen content.
  ///
  /// @param[in] ad_error An object containing detailed information
  /// about the error.
  virtual void OnAdFailedToShowFullScreenContent(const AdError& ad_error) {}

  /// Called when an impression is recorded for an ad.
  virtual void OnAdImpression() {}

  /// Called when the ad showed the full screen content.
  virtual void OnAdShowedFullScreenContent() {}
};

/// Listener to be invoked when ads have been estimated to earn money.
class PaidEventListener {
 public:
  virtual ~PaidEventListener();

  /// Called when an ad is estimated to have earned money.
  virtual void OnPaidEvent(const AdValue& value) {}
};

/// @brief Global configuration that will be used for every @ref AdRequest.
/// Set the configuration via @ref SetRequestConfiguration.
struct RequestConfiguration {
  /// A maximum ad content rating, which may be configured via
  /// @ref max_ad_content_rating.
  enum MaxAdContentRating {
    /// No content rating has been specified.
    kMaxAdContentRatingUnspecified = -1,

    /// Content suitable for general audiences, including families.
    kMaxAdContentRatingG,

    /// Content suitable only for mature audiences.
    kMaxAdContentRatingMA,

    /// Content suitable for most audiences with parental guidance.
    kMaxAdContentRatingPG,

    /// Content suitable for teen and older audiences.
    kMaxAdContentRatingT
  };

  /// Specify whether you would like your app to be treated as child-directed
  /// for purposes of the Children’s Online Privacy Protection Act (COPPA).
  /// Values defined here may be configured via
  /// @ref tag_for_child_directed_treatment.
  enum TagForChildDirectedTreatment {
    /// Indicates that ad requests will include no indication of how you would
    /// like your app treated with respect to COPPA.
    kChildDirectedTreatmentUnspecified = -1,

    /// Indicates that your app should not be treated as child-directed for
    /// purposes of the Children’s Online Privacy Protection Act (COPPA).
    kChildDirectedTreatmentFalse,

    /// Indicates that your app should be treated as child-directed for purposes
    /// of the Children’s Online Privacy Protection Act (COPPA).
    kChildDirectedTreatmentTrue
  };

  /// Configuration values to mark your app to receive treatment for users in
  /// the European Economic Area (EEA) under the age of consent. Values defined
  /// here should be configured via @ref tag_for_under_age_of_consent.
  enum TagForUnderAgeOfConsent {
    /// Indicates that the publisher has not specified whether the ad request
    /// should receive treatment for users in the European Economic Area (EEA)
    /// under the age of consent.
    kUnderAgeOfConsentUnspecified = -1,

    /// Indicates the publisher specified that the ad request should not receive
    /// treatment for users in the European Economic Area (EEA) under the age of
    /// consent.
    kUnderAgeOfConsentFalse,

    /// Indicates the publisher specified that the ad request should receive
    /// treatment for users in the European Economic Area (EEA) under the age of
    /// consent.
    kUnderAgeOfConsentTrue
  };

  /// Sets a maximum ad content rating. GMA ads returned for your app will
  /// have a content rating at or below that level.
  MaxAdContentRating max_ad_content_rating;

  /// @brief Allows you to specify whether you would like your app
  /// to be treated as child-directed for purposes of the Children’s Online
  /// Privacy Protection Act (COPPA) -
  /// http://business.ftc.gov/privacy-and-security/childrens-privacy.
  ///
  /// If you set this value to
  /// RequestConfiguration.kChildDirectedTreatmentTrue, you will indicate
  /// that your app should be treated as child-directed for purposes of the
  /// Children’s Online Privacy Protection Act (COPPA).
  ///
  /// If you set this value to
  /// RequestConfiguration.kChildDirectedTreatmentFalse, you will indicate
  /// that your app should not be treated as child-directed for purposes of the
  /// Children’s Online Privacy Protection Act (COPPA).
  ///
  /// If you do not set this value, or set this value to
  /// RequestConfiguration.kChildDirectedTreatmentUnspecified, ad requests will
  /// include no indication of how you would like your app treated with respect
  /// to COPPA.
  ///
  /// By setting this value, you certify that this notification is accurate and
  /// you are authorized to act on behalf of the owner of the app. You
  /// understand that abuse of this setting may result in termination of your
  /// Google account.
  ///
  /// @note: it may take some time for this designation to be fully implemented
  /// in applicable Google services.
  ///
  TagForChildDirectedTreatment tag_for_child_directed_treatment;

  /// This value allows you to mark your app to receive treatment for users in
  /// the European Economic Area (EEA) under the age of consent. This feature is
  /// designed to help facilitate compliance with the General Data Protection
  /// Regulation (GDPR). Note that you may have other legal obligations under
  /// GDPR. Please review the European Union's guidance and consult with your
  /// own legal counsel. Please remember that Google's tools are designed to
  /// facilitate compliance and do not relieve any particular publisher of its
  /// obligations under the law.
  ///
  /// When using this feature, a Tag For Users under the Age of Consent in
  /// Europe (TFUA) parameter will be included in all ad requests. This
  /// parameter disables personalized advertising, including remarketing, for
  /// that specific ad request. It also disables requests to third-party ad
  /// vendors, such as ad measurement pixels and third-party ad servers.
  ///
  /// If you set this value to RequestConfiguration.kUnderAgeOfConsentTrue, you
  /// will indicate that you want your app to be handled in a manner suitable
  /// for users under the age of consent.
  ///
  /// If you set this value to RequestConfiguration.kUnderAgeOfConsentFalse,
  /// you will indicate that you don't want your app to be handled in a manner
  /// suitable for users under the age of consent.
  ///
  /// If you do not set this value, or set this value to
  /// kUnderAgeOfConsentUnspecified, your app will include no indication of how
  /// you would like your app to be handled in a manner suitable for users under
  /// the age of consent.
  TagForUnderAgeOfConsent tag_for_under_age_of_consent;

  /// Sets a list of test device IDs corresponding to test devices which will
  /// always request test ads.
  std::vector<std::string> test_device_ids;
};

/// Listener to be invoked when the user earned a reward.
class UserEarnedRewardListener {
 public:
  virtual ~UserEarnedRewardListener();
  /// Called when the user earned a reward. The app is responsible for
  /// crediting the user with the reward.
  ///
  /// @param[in] reward the @ref AdReward that should be granted to the user.
  virtual void OnUserEarnedReward(const AdReward& reward) {}
};

}  // namespace gma
}  // namespace firebase

#endif  // FIREBASE_GMA_SRC_INCLUDE_FIREBASE_GMA_TYPES_H_
