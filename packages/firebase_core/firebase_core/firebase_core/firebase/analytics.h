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

#ifndef FIREBASE_ANALYTICS_SRC_INCLUDE_FIREBASE_ANALYTICS_H_
#define FIREBASE_ANALYTICS_SRC_INCLUDE_FIREBASE_ANALYTICS_H_

#include <cstddef>
#include <cstdint>
#include <map>
#include <string>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"
#include "firebase/variant.h"

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(analytics)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {

/// @brief Firebase Analytics API.
///
/// See <a href="/docs/analytics">the developer guides</a> for general
/// information on using Firebase Analytics in your apps.
namespace analytics {

/// @brief Event parameter.
///
/// Parameters supply information that contextualize events (see @ref LogEvent).
/// You can associate up to 25 unique Parameters with each event type (name).
///
/// <SWIG>
/// @if swig_examples
/// Common event types are provided as static properties of the
/// FirebaseAnalytics class (e.g FirebaseAnalytics.EventPostScore) where
/// parameters of these events are also provided in this FirebaseAnalytics
/// class (e.g FirebaseAnalytics.ParameterScore).
///
/// You are not limited to the set of event types and parameter names
/// suggested in FirebaseAnalytics class properties.  Additional Parameters can
/// be supplied for suggested event types or custom Parameters for custom event
/// types.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// Common event types (names) are suggested in @ref event_names
/// (%event_names.h) with parameters of common event types defined in
/// @ref parameter_names (%parameter_names.h).
///
/// You are not limited to the set of event types and parameter names suggested
/// in @ref event_names (%event_names.h) and  %parameter_names.h respectively.
/// Additional Parameters can be supplied for suggested event types or custom
/// Parameters for custom event types.
/// @endif
///
/// Parameter names must be a combination of letters and digits
/// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
/// long starting with a letter [a-zA-Z] character.  The "firebase_",
/// "google_" and "ga_" prefixes are reserved and should not be used.
///
/// Parameter string values can be up to 100 characters long.
///
/// <SWIG>
/// @if swig_examples
/// An array of Parameter class instances can be passed to LogEvent in order
/// to associate parameters's of an event with values where each value can be
/// a double, 64-bit integer or string.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// An array of this structure is passed to LogEvent in order to associate
/// parameter's of an event (Parameter::name) with values (Parameter::value)
/// where each value can be a double, 64-bit integer or string.
/// @endif
///
/// For example, a game may log an achievement event along with the
/// character the player is using and the level they're currently on:
///
/// <SWIG>
/// @if swig_examples
/// @code{.cs}
/// using Firebase.Analytics;
///
/// int currentLevel = GetCurrentLevel();
/// Parameter[] AchievementParameters = {
///   new Parameter(FirebaseAnalytics.ParameterAchievementID,
///                 "ultimate_wizard"),
///   new Parameter(FirebaseAnalytics.ParameterCharacter, "mysterion"),
///   new Parameter(FirebaseAnalytics.ParameterLevel, currentLevel),
/// };
/// FirebaseAnalytics.LogEvent(FirebaseAnalytics.EventLevelUp,
///                            AchievementParameters);
/// @endcode
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @code{.cpp}
/// using namespace firebase::analytics;
/// int64_t current_level = GetCurrentLevel();
/// const Parameter achievement_parameters[] = {
///   Parameter(kParameterAchievementID,  "ultimate_wizard"),
///   Parameter(kParameterCharacter, "mysterion"),
///   Parameter(kParameterLevel, current_level),
/// };
/// LogEvent(kEventUnlockAchievement, achievement_parameters,
///          sizeof(achievement_parameters) /
///          sizeof(achievement_parameters[0]));
/// @endcode
/// @endif
///
struct Parameter {
#ifndef SWIG
  /// Construct an empty parameter.
  ///
  /// This is provided to allow initialization after construction.
  Parameter() : name(nullptr) {}
#endif  // !SWIG

// <SWIG>
// We don't want to pull in Variant in the C# interface.
// </SWIG>
#ifndef SWIG
  /// Construct a parameter.
  ///
  /// @param parameter_name Name of the parameter (see Parameter::name).
  /// @param parameter_value Value for the parameter. Variants can
  /// hold numbers and strings.
  Parameter(const char* parameter_name, Variant parameter_value)
      : name(parameter_name) {
    value = parameter_value;
  }
#endif  // !SWIG

  /// Construct a 64-bit integer parameter.
  ///
  /// @param parameter_name Name of the parameter.
  /// @if cpp_examples
  /// (see Parameter::name).
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// Parameter names must be a combination of letters and digits
  /// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
  /// long starting with a letter [a-zA-Z] character.
  /// @endif
  /// </SWIG>
  /// @param parameter_value Integer value for the parameter.
  Parameter(const char* parameter_name, int parameter_value)
      : name(parameter_name) {
    value = parameter_value;
  }

  /// Construct a 64-bit integer parameter.
  ///
  /// @param parameter_name Name of the parameter.
  /// @if cpp_examples
  /// (see Parameter::name).
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// Parameter names must be a combination of letters and digits
  /// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
  /// long starting with a letter [a-zA-Z] character.
  /// @endif
  /// </SWIG>
  /// @param parameter_value Integer value for the parameter.
  Parameter(const char* parameter_name, int64_t parameter_value)
      : name(parameter_name) {
    value = parameter_value;
  }

  /// Construct a floating point parameter.
  ///
  /// @param parameter_name Name of the parameter.
  /// @if cpp_examples
  /// (see Parameter::name).
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// Parameter names must be a combination of letters and digits
  /// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
  /// long starting with a letter [a-zA-Z] character.
  /// @endif
  /// </SWIG>
  /// @param parameter_value Floating point value for the parameter.
  Parameter(const char* parameter_name, double parameter_value)
      : name(parameter_name) {
    value = parameter_value;
  }

  /// Construct a string parameter.
  ///
  /// @param parameter_name Name of the parameter.
  /// @if cpp_examples
  /// (see Parameter::name).
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// Parameter names must be a combination of letters and digits
  /// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
  /// long starting with a letter [a-zA-Z] character.
  /// @endif
  /// </SWIG>
  /// @param parameter_value String value for the parameter, can be up to 100
  /// characters long.
  Parameter(const char* parameter_name, const char* parameter_value)
      : name(parameter_name) {
    value = parameter_value;
  }

#ifndef SWIG
  // <SWIG>
  // Skipping implementation values because the C# API members are
  // immutable, and there's no other need to read these values in
  // C#. The class just needs to be passed to the C++ layers.
  // This also avoids having to solve the nested union, which is
  // unsupported in swig.
  // </SWIG>

  /// @brief Name of the parameter.
  ///
  /// Parameter names must be a combination of letters and digits
  /// (matching the regular expression [a-zA-Z0-9]) between 1 and 40 characters
  /// long starting with a letter [a-zA-Z] character.  The "firebase_",
  /// "google_" and "ga_" prefixes are reserved and should not be used.
  const char* name;
  /// @brief Value of the parameter.
  ///
  /// See firebase::Variant for usage information.
  /// @note String values can be up to 100 characters long.
  Variant value;
#endif  // SWIG
};

/// @brief Initialize the Analytics API.
///
/// This must be called prior to calling any other methods in the
/// firebase::analytics namespace.
///
/// @param[in] app Default @ref firebase::App instance.
///
/// @see firebase::App::GetInstance().
void Initialize(const App& app);

/// @brief Terminate the Analytics API.
///
/// Cleans up resources associated with the API.
void Terminate();

/// @brief Sets whether analytics collection is enabled for this app on this
/// device.
///
/// This setting is persisted across app sessions. By default it is enabled.
///
/// @param[in] enabled true to enable analytics collection, false to disable.
void SetAnalyticsCollectionEnabled(bool enabled);

/// @brief The type of consent to set.
///
/// Supported consent types are kConsentTypeAdStorage and
/// kConsentTypeAnalyticsStorage. Omitting a type retains its previous status.
enum ConsentType { kConsentTypeAdStorage = 0, kConsentTypeAnalyticsStorage };

/// @brief The status value of the consent type.
///
/// Supported statuses are kConsentStatusGranted and kConsentStatusDenied.
enum ConsentStatus { kConsentStatusGranted = 0, kConsentStatusDenied };

/// @brief Sets the applicable end user consent state (e.g., for device
/// identifiers) for this app on this device.
///
/// Use the consent map to specify individual consent type values. Settings are
/// persisted across app sessions. By default consent types are set to
/// "granted".
void SetConsent(const std::map<ConsentType, ConsentStatus>& consent_settings);

/// @brief Log an event with one string parameter.
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved.
/// <SWIG>
/// @if swig_examples
/// See the FirebaseAnalytics.Event properties for the list of reserved event
/// names.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// See @ref event_names (%event_names.h) for the list of reserved event names.
/// @endif
/// The "firebase_" prefix is reserved and should not be used. Note that event
/// names are case-sensitive and that logging two events whose names differ
/// only in case will result in two distinct events.
/// @param[in] parameter_name Name of the parameter to log.
/// For more information, see @ref Parameter.
/// @param[in] parameter_value Value of the parameter to log.
///
/// <SWIG>
/// @if swig_examples
/// @see LogEvent(string, Parameter[])
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @see LogEvent(const char*, const Parameter*, size_t)
/// @endif
void LogEvent(const char* name, const char* parameter_name,
              const char* parameter_value);

/// @brief Log an event with one float parameter.
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved.
/// <SWIG>
/// @if swig_examples
/// See the FirebaseAnalytics.Event properties for the list of reserved event
/// names.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// See @ref event_names (%event_names.h) for the list of reserved event names.
/// @endif
/// The "firebase_" prefix is reserved and should not be used. Note that event
/// names are case-sensitive and that logging two events whose names differ
/// only in case will result in two distinct events.
/// @param[in] parameter_name Name of the parameter to log.
/// For more information, see @ref Parameter.
/// @param[in] parameter_value Value of the parameter to log.
///
/// <SWIG>
/// @if swig_examples
/// @see LogEvent(string, Parameter[])
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @see LogEvent(const char*, const Parameter*, size_t)
/// @endif
void LogEvent(const char* name, const char* parameter_name,
              const double parameter_value);

/// @brief Log an event with one 64-bit integer parameter.
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved.
/// <SWIG>
/// @if swig_examples
/// See the FirebaseAnalytics.Event properties for the list of reserved event
/// names.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// See @ref event_names (%event_names.h) for the list of reserved event names.
/// @endif
/// The "firebase_" prefix is reserved and should not be used. Note that event
/// names are case-sensitive and that logging two events whose names differ
/// only in case will result in two distinct events.
/// @param[in] parameter_name Name of the parameter to log.
/// For more information, see @ref Parameter.
/// @param[in] parameter_value Value of the parameter to log.
///
/// <SWIG>
/// @if swig_examples
/// @see LogEvent(string, Parameter[])
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @see LogEvent(const char*, const Parameter*, size_t)
/// @endif
void LogEvent(const char* name, const char* parameter_name,
              const int64_t parameter_value);

/// @brief Log an event with one integer parameter
/// (stored as a 64-bit integer).
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved.
/// <SWIG>
/// @if swig_examples
/// See the FirebaseAnalytics.Event properties for the list of reserved event
/// names.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// See @ref event_names (%event_names.h) for the list of reserved event names.
/// @endif
/// The "firebase_" prefix is reserved and should not be used. Note that event
/// names are case-sensitive and that logging two events whose names differ
/// only in case will result in two distinct events.
/// @param[in] parameter_name Name of the parameter to log.
/// For more information, see @ref Parameter.
/// @param[in] parameter_value Value of the parameter to log.
///
/// <SWIG>
/// @if swig_examples
/// @see LogEvent(string, Parameter[])
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @see LogEvent(const char*, const Parameter*, size_t)
/// @endif
void LogEvent(const char* name, const char* parameter_name,
              const int parameter_value);

/// @brief Log an event with no parameters.
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved.
/// <SWIG>
/// @if swig_examples
/// See the FirebaseAnalytics.Event properties for the list of reserved event
/// names.
/// @endif
/// </SWIG>
/// @if cpp_examples
/// See @ref event_names (%event_names.h) for the list of reserved event names.
/// @endif
/// The "firebase_" prefix is reserved and should not be used. Note that event
/// names are case-sensitive and that logging two events whose names differ
/// only in case will result in two distinct events.
///
/// <SWIG>
/// @if swig_examples
/// @see LogEvent(string, Parameter[])
/// @endif
/// </SWIG>
/// @if cpp_examples
/// @see LogEvent(const char*, const Parameter*, size_t)
/// @endif
void LogEvent(const char* name);

// clang-format off
#ifdef SWIG
// Modify the following overload with unsafe, so that we can do some pinning
// in the C# code.
%csmethodmodifiers LogEvent "public unsafe"
#endif  // SWIG
// clang-format on

/// @brief Log an event with associated parameters.
///
/// An Event is an important occurrence in your app that you want to
/// measure.  You can report up to 500 different types of events per app and
/// you can associate up to 25 unique parameters with each Event type.
///
/// Some common events are documented in @ref event_names (%event_names.h),
/// but you may also choose to specify custom event types that are associated
/// with your specific app.
///
/// @param[in] name Name of the event to log. Should contain 1 to 40
/// alphanumeric characters or underscores. The name must start with an
/// alphabetic character. Some event names are reserved. See @ref event_names
/// (%event_names.h) for the list of reserved event names. The "firebase_"
/// prefix is reserved and should not be used. Note that event names are
/// case-sensitive and that logging two events whose names differ only in
/// case will result in two distinct events.
/// @param[in] parameters Array of Parameter structures.
/// @param[in] number_of_parameters Number of elements in the parameters
/// array.
void LogEvent(const char* name, const Parameter* parameters,
              size_t number_of_parameters);

/// Initiates on-device conversion measurement given a user email address on iOS
/// and tvOS (no-op on Android). On iOS and tvOS, this method requires the
/// dependency GoogleAppMeasurementOnDeviceConversion to be linked in,
/// otherwise the invocation results in a no-op.
/// @param[in] email_address User email address. Include a domain name for all
/// email addresses (e.g. gmail.com or hotmail.co.jp).
void InitiateOnDeviceConversionMeasurementWithEmailAddress(
    const char* email_address);

/// @brief Set a user property to the given value.
///
/// Properties associated with a user allow a developer to segment users
/// into groups that are useful to their application.  Up to 25 properties
/// can be associated with a user.
///
/// Suggested property names are listed @ref user_property_names
/// (%user_property_names.h) but you're not limited to this set. For example,
/// the "gamertype" property could be used to store the type of player where
/// a range of values could be "casual", "mid_core", or "core".
///
/// @param[in] name Name of the user property to set.  This must be a
/// combination of letters and digits (matching the regular expression
/// [a-zA-Z0-9] between 1 and 40 characters long starting with a letter
/// [a-zA-Z] character.
/// @param[in] property Value to set the user property to.  Set this
/// argument to NULL or nullptr to remove the user property.  The value can be
/// between 1 to 100 characters long.
void SetUserProperty(const char* name, const char* property);

/// @brief Sets the user ID property.
///
/// This feature must be used in accordance with
/// <a href="https://www.google.com/policies/privacy">Google's Privacy
/// Policy</a>
///
/// @param[in] user_id The user ID associated with the user of this app on this
/// device.  The user ID must be non-empty and no more than 256 characters long.
/// Setting user_id to NULL or nullptr removes the user ID.
void SetUserId(const char* user_id);

/// @brief Sets the duration of inactivity that terminates the current session.
///
/// @note The default value is 1800000 (30 minutes).
///
/// @param milliseconds The duration of inactivity that terminates the current
/// session.
void SetSessionTimeoutDuration(int64_t milliseconds);

/// Clears all analytics data for this app from the device and resets the app
/// instance id.
void ResetAnalyticsData();

/// Get the instance ID from the analytics service.
///
/// @note This is *not* the same ID as the ID returned by
/// @if cpp_examples
/// firebase::instance_id::InstanceId.
/// @else
/// Firebase.InstanceId.FirebaseInstanceId.
/// @endif
///
/// @returns Object which can be used to retrieve the analytics instance ID.
Future<std::string> GetAnalyticsInstanceId();

/// Get the result of the most recent GetAnalyticsInstanceId() call.
///
/// @returns Object which can be used to retrieve the analytics instance ID.
Future<std::string> GetAnalyticsInstanceIdLastResult();

/// Asynchronously retrieves the identifier of the current app
/// session.
///
/// The session ID retrieval could fail due to Analytics collection
/// disabled, or if the app session was expired.
///
/// @returns Object which can be used to retrieve the identifier of the current
/// app session.
Future<int64_t> GetSessionId();

/// Get the result of the most recent GetSessionId() call.
///
/// @returns Object which can be used to retrieve the identifier of the current
/// app session.
Future<int64_t> GetSessionIdLastResult();

}  // namespace analytics
}  // namespace firebase

#endif  // FIREBASE_ANALYTICS_SRC_INCLUDE_FIREBASE_ANALYTICS_H_
