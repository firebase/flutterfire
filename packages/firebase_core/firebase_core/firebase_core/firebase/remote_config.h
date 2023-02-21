// Copyright 2016 Google LLC
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

#ifndef FIREBASE_REMOTE_CONFIG_SRC_INCLUDE_FIREBASE_REMOTE_CONFIG_H_
#define FIREBASE_REMOTE_CONFIG_SRC_INCLUDE_FIREBASE_REMOTE_CONFIG_H_

#include <cstdint>
#include <string>
#include <vector>

#include "firebase/app.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"
#include "firebase/internal/platform.h"
#ifndef SWIG
#include "firebase/variant.h"
#endif  // SWIG

#if !defined(DOXYGEN) && !defined(SWIG)
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(remote_config)
#endif  // !defined(DOXYGEN) && !defined(SWIG)

/// @brief Namespace that encompasses all Firebase APIs.
namespace firebase {

#ifndef SWIG
/// @brief Firebase Remote Config API.
///
/// Firebase Remote Config is a cloud service that lets you change the
/// appearance and behavior of your app without requiring users to download an
/// app update.
#endif  // SWIG
namespace remote_config {

/// @brief Describes the most recent fetch request status.
enum LastFetchStatus {
  /// The most recent fetch was a success, and its data is ready to be
  /// applied, if you have not already done so.
  kLastFetchStatusSuccess,
  /// The most recent fetch request failed.
  kLastFetchStatusFailure,
  /// The most recent fetch is still in progress.
  kLastFetchStatusPending,
};

/// @brief Describes the most recent fetch failure.
enum FetchFailureReason {
  /// The fetch has not yet failed.
  kFetchFailureReasonInvalid,
  /// The most recent fetch failed because it was throttled by the server.
  /// (You are sending too many fetch requests in too short a time.)
  kFetchFailureReasonThrottled,
  /// The most recent fetch failed for an unknown reason.
  kFetchFailureReasonError,
};

/// @brief Describes the state of the most recent Fetch() call.
/// Normally returned as a result of the GetInfo() function.
struct ConfigInfo {
  /// @brief The time (in milliseconds since the epoch) that the last fetch
  /// operation completed.
  uint64_t fetch_time;

  /// @brief The status of the last fetch request.
  LastFetchStatus last_fetch_status;

  /// @brief The reason the most recent fetch failed.
  FetchFailureReason last_fetch_failure_reason;

  /// @brief The time (in milliseconds since the epoch) when the refreshing of
  /// Remote Config data is throttled.
  uint64_t throttled_end_time;
};

/// @brief Describes the source a config value was retrieved from.
enum ValueSource {
  /// The value was not specified and no default was specified, so a static
  /// value (0 for numeric values, an empty string for strings) was returned.
  kValueSourceStaticValue,
  /// The value was found in the remote data store, and returned.
  kValueSourceRemoteValue,
  /// The value was not specified, so the specified default value was
  /// returned instead.
  kValueSourceDefaultValue,
};

/// @brief Describes a retrieved value.
struct ValueInfo {
  /// Where the config value was retrieved from (Default Config or Active
  /// Config).
  ValueSource source;
  /// If <code>true</code> this indicates conversion to the requested type
  /// succeeded, otherwise conversion failed so the static value for the
  /// requested type was retrieved instead.
  bool conversion_successful;
};

/// @brief Keys of API settings.
///
/// @see SetConfigSetting
/// @see GetConfigSetting
enum ConfigSetting {
  /// Set the value associated with this key to "1" to enable developer mode
  /// (i.e disable throttling) and "0" to disable.
  kConfigSettingDeveloperMode,
};

/// @brief The default cache expiration used by Fetch(), equal to 12 hours,
/// in milliseconds.
static const uint64_t kDefaultCacheExpiration = 60 * 60 * 12 * 1000;

/// @brief The default timeout used by Fetch(), equal to 30 seconds,
/// in milliseconds.
static const uint64_t kDefaultTimeoutInMilliseconds = 30 * 1000;

/// @brief Describes a mapping of a key to a string value. Used to set default
/// values.
struct ConfigKeyValue {
  /// The lookup key string.
#ifndef SWIG
  ///
  /// @note Ensure this string stays valid for the duration of the
  /// call to SetDefaults.
#endif  // SWIG
  const char* key;
  /// The value string to be stored.
#ifndef SWIG
  ///
  /// @note Ensure this string stays valid for the duration of the
  /// call to SetDefaults.
#endif  // SWIG
  const char* value;
};

#ifndef SWIG
/// @brief Describes a mapping of a key to a value of any type. Used to set
/// default values.
struct ConfigKeyValueVariant {
  /// The lookup key string.
  ///
  /// @note Ensure this string stays valid for the duration of the
  /// call to SetDefaults.
  const char* key;
  /// The value to be stored. The type of the Variant determines the type of
  /// default data for the given key.
  ///
  /// @note If you use a Variant of type StaticString, ensure it stays
  /// valid for the duration of the call to SetDefaults.
  Variant value;
};
#endif  // SWIG

/// @brief Configurations for Remote Config behavior.
struct ConfigSettings {
  /// The timeout specifies how long the client should wait for a connection to
  /// the Firebase Remote Config servers.
  ///
  /// @note A fetch call will fail if it takes longer than the specified timeout
  /// to connect to the Remote Config servers. Default is 60 seconds.
  uint64_t fetch_timeout_in_milliseconds = kDefaultTimeoutInMilliseconds;

  /// The minimum interval between successive fetch calls.
  ///
  /// @note Fetches less than duration seconds after the last fetch from the
  /// Firebase Remote Config server would use values returned during the last
  /// fetch. Default is 12 hours.
  uint64_t minimum_fetch_interval_in_milliseconds = kDefaultCacheExpiration;
};

namespace internal {
class RemoteConfigInternal;
}  // namespace internal

#ifndef SWIG
/// @brief Entry point for the Firebase C++ SDK for Remote Config.
///
/// To use the SDK, call firebase::remote_config::RemoteConfig::GetInstance() to
/// obtain an instance of RemoteConfig, then call operations on that instance.
/// The instance contains the complete set of FRC parameter values available to
/// your app. The instance also stores values fetched from the FRC Server until
/// they are made available for use with a call to @ref Activate().
#endif  // SWIG
class RemoteConfig {
 public:
  ~RemoteConfig();

  /// @brief Returns a Future that contains ConfigInfo representing the
  /// initialization status of this Firebase Remote Config instance.
  /// Use this method to ensure Set/Get call not being blocked.
  Future<ConfigInfo> EnsureInitialized();

  /// @brief Get the (possibly still pending) results of the most recent
  /// EnsureInitialized() call.
  ///
  /// @return The future result from the last call to EnsureInitialized().
  Future<ConfigInfo> EnsureInitializedLastResult();

  /// Asynchronously activates the most recently fetched configs, so that the
  /// fetched key value pairs take effect.
  ///
  /// @return A Future that contains true if fetched configs were
  /// activated. The future will contain false if the configs were already
  /// activated.
  Future<bool> Activate();

  /// @brief Get the (possibly still pending) results of the most recent
  /// Activate() call.
  ///
  /// @return The future result from the last call to Activate().
  Future<bool> ActivateLastResult();

  /// Asynchronously fetches and then activates the fetched configs.
  ///
  /// If the time elapsed since the last fetch from the Firebase Remote Config
  /// backend is more than the default minimum fetch interval, configs are
  /// fetched from the backend.
  ///
  /// After the fetch is complete, the configs are activated so that the fetched
  /// key value pairs take effect.
  ///
  /// @return A Future that contains true if the current call
  /// activated the fetched configs; if no configs were fetched from the backend
  /// and the local fetched configs have already been activated, the future will
  /// contain false.
  Future<bool> FetchAndActivate();

  /// @brief Get the (possibly still pending) results of the most recent
  /// FetchAndActivate() call.
  ///
  /// @return The future result from the last call to FetchAndActivate().
  Future<bool> FetchAndActivateLastResult();

  /// @brief Fetches config data from the server.
  ///
  /// @note This does not actually apply the data or make it accessible,
  /// it merely retrieves it and caches it.  To accept and access the newly
  /// retrieved values, you must call @ref Activate().
  ///
  /// Note that this function is asynchronous, and will normally take an
  /// unspecified amount of time before completion.
  ///
  /// @return A Future which can be used to determine when the fetch is
  /// complete.
  Future<void> Fetch();

  /// @brief Fetches config data from the server.
  ///
  /// @note This does not actually apply the data or make it accessible,
  /// it merely retrieves it and caches it.  To accept and access the newly
  /// retrieved values, you must call @ref Activate().
  /// Note that this function is asynchronous, and will normally take an
  /// unspecified amount of time before completion.
  ///
  /// @param[in] cache_expiration_in_seconds The number of seconds to keep
  /// previously fetch data available.  If cached data is available that is
  /// newer than cache_expiration_in_seconds, then the function returns
  /// immediately and does not fetch any data. A cache_expiration_in_seconds of
  /// zero will always cause a fetch.
  ///
  /// @return A Future which can be used to determine when the fetch is
  /// complete.
  Future<void> Fetch(uint64_t cache_expiration_in_seconds);

  /// @brief Get the (possibly still pending) results of the most recent Fetch()
  /// call.
  ///
  /// @return The future result from the last call to Fetch().
  Future<void> FetchLastResult();

#if defined(__ANDROID__)
  /// @brief Sets the default values, using an XML resource.
  ///
  /// @note This method is specific to the Android implementation.
  ///
  /// This completely overwrites all previous default values.
  ///
  /// @param[in] defaults_resource_id Id for the XML resource, which should be
  /// in your applications res/xml folder.
  ///
  /// @return a Future which can be used to determine when the operation is
  /// complete.
  Future<void> SetDefaults(int defaults_resource_id);
#endif  // __ANDROID__

#ifndef SWIG
  /// @brief Sets the default values based on a mapping of string to Variant.
  /// This allows you to specify defaults of type other than string.
  ///
  /// The type of each Variant in the map determines the type of data for which
  /// you are providing a default. For example, boolean values can be retrieved
  /// with GetBool(), integer values can be retrieved with GetLong(), double
  /// values can be retrieved with GetDouble(), string values can be retrieved
  /// with GetString(), and binary data can be retrieved with GetData().
  /// Aggregate Variant types are not allowed.
  ///
  /// @see firebase::Variant for more information on how to create a Variant of
  /// each type.
  ///
  /// @note This completely overrides all previous values.
  ///
  /// @param defaults Array of ConfigKeyValueVariant, representing the new set
  /// of defaults to apply. If the same key is specified multiple times, the
  /// value associated with the last duplicate key is applied.
  /// @param number_of_defaults Number of elements in the defaults array.
  ///
  /// @return a Future which can be used to determine when the operation is
  /// complete.
  Future<void> SetDefaults(const ConfigKeyValueVariant* defaults,
                           size_t number_of_defaults);
#endif  // SWIG

  /// @brief Sets the default values based on a string map.
  ///
  /// @note This completely overrides all previous values.
  ///
  /// @param defaults Array of ConfigKeyValue, representing the new set of
  /// defaults to apply. If the same key is specified multiple times, the
  /// value associated with the last duplicate key is applied.
  /// @param number_of_defaults Number of elements in the defaults array.
  ///
  /// @return a Future which can be used to determine when the operation is
  /// complete.
  Future<void> SetDefaults(const ConfigKeyValue* defaults,
                           size_t number_of_defaults);

  /// @brief Get the (possibly still pending) results of the most recent
  /// SetDefaults() call.
  ///
  /// @return The future result from the last call to SetDefaults().
  Future<void> SetDefaultsLastResult();

  /// @brief Asynchronously changes the settings for this Remote Config
  /// instance.
  ///
  /// @param settings The new settings to be applied.
  ///
  /// @return a Future which can be used to determine when the operation is
  /// complete.
  Future<void> SetConfigSettings(ConfigSettings settings);

  /// @brief Gets the current settings of the RemoteConfig object.
  ///
  /// @return A ConfigSettings struct.
  ConfigSettings GetConfigSettings();

  /// @brief Get the (possibly still pending) results of the most recent
  /// SetConfigSettings() call.
  ///
  /// @return The future result from the last call to SetConfigSettings().
  Future<void> SetConfigSettingsLastResult();

  /// @brief Returns the value associated with a key, converted to a bool.
  ///
  /// Values of "1", "true", "t", "yes", "y" and "on" are interpreted (case
  /// insensitive) as <code>true</code> and "0", "false", "f", "no", "n", "off",
  /// and empty strings are interpreted (case insensitive) as
  /// <code>false</code>.
  ///
  /// @param[in] key Key of the value to be retrieved.
  ///
  /// @return Value associated with the specified key converted to a boolean
  /// value.
  bool GetBoolean(const char* key);

  /// @brief Returns the value associated with a key, converted to a bool.
  ///
  /// Values of "1", "true", "t", "yes", "y" and "on" are interpreted (case
  /// insensitive) as <code>true</code> and "0", "false", "f", "no", "n", "off",
  /// and empty strings are interpreted (case insensitive) as
  /// <code>false</code>.
  ///
  /// @param[in] key Key of the value to be retrieved.
  /// @param[out] info A return value, specifying the source of the returned
  /// value.
  ///
  /// @return Value associated with the specified key converted to a boolean
  /// value.
  bool GetBoolean(const char* key, ValueInfo* info);

  /// @brief Returns the value associated with a key, converted to a 64-bit
  /// integer.
  ///
  /// @param[in] key Key of the value to be retrieved.
  ///
  /// @return Value associated with the specified key converted to a 64-bit
  /// integer.
  int64_t GetLong(const char* key);

  /// @brief Returns the value associated with a key, converted to a 64-bit
  /// integer.
  ///
  /// @param[in] key Key of the value to be retrieved.
  /// @param[out] info A return value, specifying the source of the returned
  /// value.
  ///
  /// @return Value associated with the specified key converted to a 64-bit
  /// integer.
  int64_t GetLong(const char* key, ValueInfo* info);

  /// @brief Returns the value associated with a key, converted to a double.
  ///
  /// @param[in] key Key of the value to be retrieved.
  ///
  /// @return Value associated with the specified key converted to a double.
  double GetDouble(const char* key);

  /// @brief Returns the value associated with a key, converted to a double.
  ///
  /// @param[in] key Key of the value to be retrieved.
  /// @param[out] info A return value, specifying the source of the returned
  /// value.
  ///
  /// @return Value associated with the specified key converted to a double.
  double GetDouble(const char* key, ValueInfo* info);

  /// @brief Returns the value associated with a key, converted to a string.
  ///
  /// @param[in] key Key of the value to be retrieved.
  ///
  /// @return Value as a string associated with the specified key.
  std::string GetString(const char* key);

  /// @brief Returns the value associated with a key, converted to a string.
  ///
  /// @param[in] key Key of the value to be retrieved.
  /// @param[out] info A return value, specifying the source of the returned
  /// value.
  ///
  /// @return Value as a string associated with the specified key.
  std::string GetString(const char* key, ValueInfo* info);

  /// @brief Returns the value associated with a key, as a vector of raw
  /// byte-data.
  ///
  /// @param[in] key Key of the value to be retrieved.
  ///
  /// @return Vector of bytes.
  std::vector<unsigned char> GetData(const char* key);

  /// @brief Returns the value associated with a key, as a vector of raw
  /// byte-data.
  ///
  /// @param[in] key Key of the value to be retrieved.
  /// @param[out] info A return value, specifying the source of the returned
  /// value.
  ///
  /// @return Vector of bytes.
  std::vector<unsigned char> GetData(const char* key, ValueInfo* info);

  /// @brief Gets the set of keys that start with the given prefix.
  ///
  /// @param[in] prefix The key prefix to look for. If empty or null, this
  /// method will return all keys.
  ///
  /// @return Set of Remote Config parameter keys that start with the specified
  /// prefix. Will return an empty set if there are no keys with the given
  /// prefix.
  std::vector<std::string> GetKeysByPrefix(const char* prefix);

  /// @brief Gets the set of all keys.
  ///
  /// @return Set of all Remote Config parameter keys.
  std::vector<std::string> GetKeys();

  /// @brief Returns a Map of Firebase Remote Config key value pairs.
  ///
  /// Evaluates the values of the parameters in the following order:
  /// The activated value, if the last successful @ref Activate() contained the
  /// key. The default value, if the key was set with @ref SetDefaults().
  std::map<std::string, Variant> GetAll();

  /// @brief Returns information about the last fetch request, in the form
  /// of a ConfigInfo struct.
  ///
  /// @return A ConfigInfo struct, containing fields reflecting the state
  /// of the most recent fetch request.
  const ConfigInfo GetInfo();

  /// Gets the App this remote config object is connected to.
  App* app() { return app_; }

  /// Returns the RemoteConfig object for an App. Creates the RemoteConfig if
  /// required.
  ///
  /// To get the RemoteConfig object for the default app, use,
  /// GetInstance(GetDefaultFirebaseApp());
  ///
  /// If the library RemoteConfig fails to initialize, init_result_out will be
  /// written with the result status (if a pointer is given).
  ///
  /// @param[in] app The App to use for the RemoteConfig object.
  static RemoteConfig* GetInstance(App* app);

 private:
  explicit RemoteConfig(App* app);

  // Find RemoteConfig instance using App.  Return null if the instance does not
  // exist.
  static RemoteConfig* FindRemoteConfig(App* app);

  // Clean up RemoteConfig instance.
  void DeleteInternal();

  /// The Firebase App this remote config is connected to.
  App* app_;

  bool InitInternal();

  internal::RemoteConfigInternal* internal_;
};

}  // namespace remote_config
}  // namespace firebase

#endif  // FIREBASE_REMOTE_CONFIG_SRC_INCLUDE_FIREBASE_REMOTE_CONFIG_H_
