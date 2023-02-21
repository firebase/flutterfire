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

#ifndef FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_COMPONENTS_H_
#define FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_COMPONENTS_H_

#include <cstring>
#include <string>
#include <vector>

#include "firebase/future.h"

namespace firebase {

namespace dynamic_links {

/// @brief Google Analytics Parameters.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until the
/// DynamicLinkComponents that uses them goes out of scope.
struct GoogleAnalyticsParameters {
  /// Constructs an empty set of Google Analytics parameters.
  GoogleAnalyticsParameters()
      : source(nullptr),
        medium(nullptr),
        campaign(nullptr),
        term(nullptr),
        content(nullptr) {}

  /// The campaign source; used to identify a search engine, newsletter,
  /// or other source.
  const char* source;
  /// The campaign medium; used to identify a medium such as email or
  /// cost-per-click (cpc).
  const char* medium;
  /// The campaign name; The individual campaign name, slogan, promo code, etc.
  /// for a product.
  const char* campaign;
  /// The campaign term; used with paid search to supply the keywords for ads.
  const char* term;
  /// The campaign content; used for A/B testing and content-targeted ads to
  /// differentiate ads or links that point to the same URL.
  const char* content;
};

/// @brief iOS Parameters.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until the
/// DynamicLinkComponents that uses them goes out of scope.
struct IOSParameters {
  /// Constructs a set of IOS parameters with the given bundle id.
  ///
  /// @param bundle_id_ The parameters ID of the iOS app to use to open the
  /// link.
  IOSParameters(const char* bundle_id_)
      : bundle_id(bundle_id_),
        fallback_url(nullptr),
        custom_scheme(nullptr),
        ipad_fallback_url(nullptr),
        ipad_bundle_id(nullptr),
        app_store_id(nullptr),
        minimum_version(nullptr) {}

  /// Constructs an empty set of IOS parameters.
  IOSParameters()
      : bundle_id(nullptr),
        fallback_url(nullptr),
        custom_scheme(nullptr),
        ipad_fallback_url(nullptr),
        ipad_bundle_id(nullptr),
        app_store_id(nullptr),
        minimum_version(nullptr) {}

  /// The parameters ID of the iOS app to use to open the link. The app must be
  /// connected to your project from the Overview page of the Firebase console.
  /// Note this field is required.
  const char* bundle_id;
  /// The link to open on iOS if the app is not installed.
  ///
  /// Specify this to do something other than install your app from the
  /// App Store when the app isn't installed, such as open the mobile
  /// web version of the content, or display a promotional page for your app.
  const char* fallback_url;
  /// The app's custom URL scheme, if defined to be something other than your
  /// app's parameters ID.
  const char* custom_scheme;
  /// The link to open on iPad if the app is not installed.
  ///
  /// Overrides fallback_url when on iPad.
  const char* ipad_fallback_url;
  /// The iPad parameters ID of the app.
  const char* ipad_bundle_id;
  /// The App Store ID, used to send users to the App Store when the app isn't
  /// installed.
  const char* app_store_id;
  /// The minimum version of your app that can open the link.
  const char* minimum_version;
};

/// @brief iTunes Connect App Analytics Parameters.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until the
/// DynamicLinkComponents that uses them goes out of scope.
struct ITunesConnectAnalyticsParameters {
  /// Constructs an empty set of ITunes Connect Analytics parameters.
  ITunesConnectAnalyticsParameters()
      : provider_token(nullptr),
        affiliate_token(nullptr),
        campaign_token(nullptr) {}

  /// The provider token that enables analytics for Dynamic Links from
  /// within iTunes Connect.
  const char* provider_token;
  /// The affiliate token used to create affiliate-coded links.
  const char* affiliate_token;
  /// The campaign token that developers can add to any link in order to
  /// track sales from a specific marketing campaign.
  const char* campaign_token;
};

/// @brief Android Parameters.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until the
/// DynamicLinkComponents that uses them goes out of scope.
struct AndroidParameters {
  /// Constructs a set of Android parameters with the given package name.
  ///
  /// The package name of the Android app to use to open the link.
  AndroidParameters(const char* package_name_)
      : package_name(package_name_),
        fallback_url(nullptr),
        minimum_version(0) {}

  /// Constructs an empty set of Android parameters.
  AndroidParameters()
      : package_name(nullptr), fallback_url(nullptr), minimum_version(0) {}

  /// The package name of the Android app to use to open the link. The app
  /// must be connected to your project from the Overview page of the Firebase
  /// console.
  /// Note this field is required.
  const char* package_name;
  /// The link to open when the app isn't installed.
  ///
  /// Specify this to do something other than install your app from the
  /// Play Store when the app isn't installed, such as open the mobile web
  /// version of the content, or display a promotional page for your app.
  const char* fallback_url;
  /// The versionCode of the minimum version of your app that can open the link.
  int minimum_version;
};

/// @brief Social meta-tag Parameters.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until the
/// DynamicLinkComponents that uses them goes out of scope.
struct SocialMetaTagParameters {
  /// Constructs an empty set of Social meta-tag parameters.
  SocialMetaTagParameters()
      : title(nullptr), description(nullptr), image_url(nullptr) {}

  /// The title to use when the Dynamic Link is shared in a social post.
  const char* title;
  /// The description to use when the Dynamic Link is shared in a social post.
  const char* description;
  /// The URL to an image related to this link.
  const char* image_url;
};

/// @brief The desired path length for shortened Dynamic Link URLs.
enum PathLength {
  /// Uses the server-default for the path length.
  /// See https://goo.gl/8yDAqC for more information.
  kPathLengthDefault = 0,
  /// Typical short link for non-sensitive links.
  kPathLengthShort,
  /// Short link that uses a very long path to make it more difficult to
  /// guess. Useful for sensitive links.
  kPathLengthUnguessable,
};

/// @brief Additional options for Dynamic Link creation.
struct DynamicLinkOptions {
  /// Constructs an empty set of Dynamic Link options.
  DynamicLinkOptions() : path_length(kPathLengthDefault) {}

  /// The desired path length for shortened Dynamic Link URLs.
  PathLength path_length;
};

/// @brief The returned value from creating a Dynamic Link.
struct GeneratedDynamicLink {
  /// The Dynamic Link value.
  std::string url;
  /// Information about potential warnings on link creation.
  ///
  /// Usually presence of warnings means parameter format errors, parameter
  /// value errors, or missing parameters.
  std::vector<std::string> warnings;
  /// If non-empty, the cause of the Dynamic Link generation failure.
  std::string error;
};

/// @brief The information needed to generate a Dynamic Link.
///
/// Note that the strings used by the struct are not copied, as so must
/// either be statically allocated, or must persist in memory until this
/// struct goes out of scope.
struct DynamicLinkComponents {
  /// The link your app will open.
  /// You can specify any URL your app can handle, such as a link to your
  /// app's content, or a URL that initiates some
  /// app-specific logic such as crediting the user with a coupon, or
  /// displaying a specific welcome screen. This link must be a well-formatted
  /// URL, be properly URL-encoded, and use the HTTP or HTTPS scheme.
  /// Note, this field is required.
  const char* link;
  /// The domain (of the form "https://xyz.app.goo.gl") to use for this Dynamic
  /// Link. You can find this value in the Dynamic Links section of the Firebase
  /// console.
  ///
  /// If you have set up custom domains on your project, set this to your
  /// project's custom domain as listed in the Firebase console.
  ///
  /// Only https:// links are supported.
  ///
  /// Note, this field is required.
  const char* domain_uri_prefix;
  /// The Google Analytics parameters.
  GoogleAnalyticsParameters* google_analytics_parameters;
  /// The iOS parameters.
  IOSParameters* ios_parameters;
  /// The iTunes Connect App Analytics parameters.
  ITunesConnectAnalyticsParameters* itunes_connect_analytics_parameters;
  /// The Android parameters.
  AndroidParameters* android_parameters;
  /// The social meta-tag parameters.
  SocialMetaTagParameters* social_meta_tag_parameters;

  /// Default constructor, initializes all fields to null.
  DynamicLinkComponents()
      : link(nullptr),
        domain_uri_prefix(nullptr),
        google_analytics_parameters(nullptr),
        ios_parameters(nullptr),
        itunes_connect_analytics_parameters(nullptr),
        android_parameters(nullptr),
        social_meta_tag_parameters(nullptr) {}

  /// Constructor that initializes with the given link and domain.
  ///
  /// @param link_ The link your app will open.
  /// @param domain_uri_prefix_ The domain (of the form
  /// "https://xyz.app.goo.gl") to use for this Dynamic Link. You can find this
  /// value in the Dynamic Links section of the Firebase console. If you have
  /// set up custom domains on your project, set this to your project's custom
  /// domain as listed in the Firebase console. Note: If you do not specify
  /// "https://" as the URI scheme, it will be added.
  DynamicLinkComponents(const char* link_, const char* domain_uri_prefix_)
      : link(link_),
        domain_uri_prefix(domain_uri_prefix_),
        google_analytics_parameters(nullptr),
        ios_parameters(nullptr),
        itunes_connect_analytics_parameters(nullptr),
        android_parameters(nullptr),
        social_meta_tag_parameters(nullptr) {
    // For backwards compatibility with dynamic_link_domain, if
    // domain_uri_prefix doesn't start with "https://", add it.
    static const char kHttpsPrefix[] = "https://";
    static const size_t kHttpsPrefixLength = sizeof(kHttpsPrefix) - 1;
    if (strncmp(domain_uri_prefix, kHttpsPrefix, kHttpsPrefixLength) != 0) {
      domain_uri_prefix_with_scheme =
          std::string(kHttpsPrefix) + domain_uri_prefix;
      domain_uri_prefix = domain_uri_prefix_with_scheme.c_str();
    }
  }

#ifndef INTERNAL_EXPERIMENTAL

 private:
#endif  // INTERNAL_EXPERIMENTAL
  std::string domain_uri_prefix_with_scheme;
};

/// Creates a long Dynamic Link from the given parameters.
GeneratedDynamicLink GetLongLink(const DynamicLinkComponents& components);

/// Creates a shortened Dynamic Link from the given parameters.
/// @param components: Settings used to configure the behavior for the link.
Future<GeneratedDynamicLink> GetShortLink(
    const DynamicLinkComponents& components);

/// Creates a shortened Dynamic Link from the given parameters.
/// @param components: Settings used to configure the behavior for the link.
/// @param options: Additional options for Dynamic Link shortening, indicating
/// whether or not to produce an unguessable or shortest possible link.
/// No references to the options object will be retained after the call.
Future<GeneratedDynamicLink> GetShortLink(
    const DynamicLinkComponents& components, const DynamicLinkOptions& options);

/// Creates a shortened Dynamic Link from a given long Dynamic Link.
/// @param long_dynamic_link A link previously generated from GetLongLink.
Future<GeneratedDynamicLink> GetShortLink(const char* long_dynamic_link);

/// Creates a shortened Dynamic Link from a given long Dynamic Link.
/// @param long_dynamic_link: A link previously generated from GetLongLink.
/// @param options: Additional options for Dynamic Link shortening, indicating
/// whether or not to produce an unguessable or shortest possible link.
/// No references to the options object will be retained after the call.
Future<GeneratedDynamicLink> GetShortLink(const char* long_dynamic_link,
                                          const DynamicLinkOptions& options);

/// Get the (possibly still pending) results of the most recent GetShortUrl
/// call.
Future<GeneratedDynamicLink> GetShortLinkLastResult();

}  // namespace dynamic_links
}  // namespace firebase

#endif  // FIREBASE_DYNAMIC_LINKS_SRC_INCLUDE_FIREBASE_DYNAMIC_LINKS_COMPONENTS_H_
