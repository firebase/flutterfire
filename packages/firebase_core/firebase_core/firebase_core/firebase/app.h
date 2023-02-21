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

#ifndef FIREBASE_APP_SRC_INCLUDE_FIREBASE_APP_H_
#define FIREBASE_APP_SRC_INCLUDE_FIREBASE_APP_H_

#include "firebase/internal/platform.h"

#if FIREBASE_PLATFORM_ANDROID
#include <jni.h>
#endif  // FIREBASE_PLATFORM_ANDROID

#include <map>
#include <memory>
#include <string>

#if FIREBASE_PLATFORM_IOS || FIREBASE_PLATFORM_TVOS
#ifdef __OBJC__
@class FIRApp;
#endif  // __OBJC__
#endif  // FIREBASE_PLATFORM_IOS

namespace firebase {

#ifdef FIREBASE_LINUX_BUILD_CONFIG_STRING
// Check to see if the shared object compiler string matches the input
void CheckCompilerString(const char* input);
#endif  // FIREBASE_LINUX_BUILD_CONFIG_STRING

// Predeclarations.
#ifdef INTERNAL_EXPERIMENTAL
namespace internal {
class FunctionRegistry;
}  // namespace internal
#endif  // INTERNAL_EXPERIMENTAL

#ifdef INTERNAL_EXPERIMENTAL
#if FIREBASE_PLATFORM_DESKTOP
namespace heartbeat {
class HeartbeatController;  // forward declaration
}  // namespace heartbeat
#endif  // FIREBASE_PLATFORM_DESKTOP
#endif  // INTERNAL_EXPERIMENTAL

namespace internal {
class AppInternal;
}  // namespace internal

/// @brief Reports whether a Firebase module initialized successfully.
enum InitResult {
  /// The given library was successfully initialized.
  kInitResultSuccess = 0,

  /// The given library failed to initialize due to a missing dependency.
  ///
  /// On Android, this typically means that Google Play services is not
  /// available and the library requires it.
  /// @if cpp_examples
  /// Use google_play_services::CheckAvailability() and
  /// google_play_services::MakeAvailable() to resolve this issue.
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// Use FirebaseApp.CheckDependencies() and
  /// FirebaseApp.FixDependenciesAsync() to resolve this issue.
  /// @endif
  /// </SWIG>
  ///
  /// Also, on Android, this value can be returned if the Java dependencies of a
  /// Firebase component are not included in the application, causing
  /// initialization to fail.  This means that the application's build
  /// environment is not configured correctly.  To resolve the problem,
  /// see the SDK setup documentation for the set of Java dependencies (AARs)
  /// required for the component that failed to initialize.
  kInitResultFailedMissingDependency
};

/// @brief Default name for firebase::App() objects.
extern const char* const kDefaultAppName;

/// @brief Options that control the creation of a Firebase App.
/// @if cpp_examples
/// @see firebase::App
/// @endif
/// <SWIG>
/// @if swig_examples
/// @see FirebaseApp
/// @endif
/// </SWIG>
class AppOptions {
  friend class App;

 public:
  /// @brief Create AppOptions.
  ///
  /// @if cpp_examples
  /// To create a firebase::App object, the Firebase application identifier
  /// and API key should be set using set_app_id() and set_api_key()
  /// respectively.
  ///
  /// @see firebase::App::Create().
  /// @endif
  /// <SWIG>
  /// @if swig_examples
  /// To create a FirebaseApp object, the Firebase application identifier
  /// and API key should be set using AppId and ApiKey respectively.
  ///
  /// @see FirebaseApp.Create().
  /// @endif
  /// </SWIG>
  AppOptions() {}

  /// Set the Firebase app ID used to uniquely identify an instance of an app.
  ///
  /// This is the mobilesdk_app_id in the Android google-services.json config
  /// file or GOOGLE_APP_ID in the GoogleService-Info.plist.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  void set_app_id(const char* id) { app_id_ = id; }

  /// Retrieves the app ID.
  ///
  /// @if cpp_examples
  /// @see set_app_id().
  /// @endif
  ///
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="AppId">
  /// Gets or sets the App Id.
  ///
  /// This is the mobilesdk_app_id in the Android google-services.json config
  /// file or GOOGLE_APP_ID in the GoogleService-Info.plist.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* app_id() const { return app_id_.c_str(); }

  /// API key used to authenticate requests from your app.
  ///
  /// For example, "AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk" used to identify
  /// your app to Google servers.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  void set_api_key(const char* key) { api_key_ = key; }

  /// Get the API key.
  ///
  /// @if cpp_examples
  /// @see set_api_key().
  /// @endif
  ///
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="ApiKey">
  /// Gets or sets the API key used to authenticate requests from your app.
  ///
  /// For example, \"AIzaSyDdVgKwhZl0sTTTLZ7iTmt1r3N2cJLnaDk\" used to identify
  /// your app to Google servers.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* api_key() const { return api_key_.c_str(); }

  /// Set the Firebase Cloud Messaging sender ID.
  ///
  /// For example "012345678901", used to configure Firebase Cloud Messaging.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  void set_messaging_sender_id(const char* sender_id) {
    fcm_sender_id_ = sender_id;
  }

  /// Get the Firebase Cloud Messaging sender ID.
  ///
  /// @if cpp_examples
  /// @see set_messaging_sender_id().
  /// @endif
  ///
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="MessageSenderId">
  /// Gets or sets the messaging sender Id.
  ///
  /// This only needs to be specified if your application does not include
  /// google-services.json or GoogleService-Info.plist in its resources.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* messaging_sender_id() const { return fcm_sender_id_.c_str(); }

  /// Set the database root URL, e.g. @"http://abc-xyz-123.firebaseio.com".
  void set_database_url(const char* url) { database_url_ = url; }

  /// Get database root URL, e.g. @"http://abc-xyz-123.firebaseio.com".
  ///
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="DatabaseUrl">
  /// Gets or sets the database root URL, e.g.
  /// @\"http://abc-xyz-123.firebaseio.com\".
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* database_url() const { return database_url_.c_str(); }

  /// @cond FIREBASE_APP_INTERNAL

  /// Set the tracking ID for Google Analytics, e.g. @"UA-12345678-1".
  void set_ga_tracking_id(const char* id) { ga_tracking_id_ = id; }

  /// Get the tracking ID for Google Analytics,
  ///
  /// @if cpp_examples
  /// @see set_ga_tracking_id().
  /// @endif
  ///
  const char* ga_tracking_id() const { return ga_tracking_id_.c_str(); }

  /// @endcond

  /// Set the Google Cloud Storage bucket name,
  /// e.g. @\"abc-xyz-123.storage.firebase.com\".
  void set_storage_bucket(const char* bucket) { storage_bucket_ = bucket; }

  /// Get the Google Cloud Storage bucket name,
  /// @see set_storage_bucket().
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="StorageBucket">
  /// Gets or sets the Google Cloud Storage bucket name, e.g.
  /// @\"abc-xyz-123.storage.firebase.com\".
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* storage_bucket() const { return storage_bucket_.c_str(); }

  /// Set the Google Cloud project ID.
  void set_project_id(const char* project) { project_id_ = project; }

  /// Get the Google Cloud project ID.
  ///
  /// This is the project_id in the Android google-services.json config
  /// file or PROJECT_ID in the GoogleService-Info.plist.
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="ProjectID">
  /// Gets the Google Cloud project ID.
  ///
  /// This is the project_id in the Android google-services.json config
  /// file or PROJECT_ID in the GoogleService-Info.plist.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* project_id() const { return project_id_.c_str(); }

#ifdef INTERNAL_EXPERIMENTAL
  /// @brief set the iOS client ID.
  ///
  /// This is the clientID in the GoogleService-Info.plist.
  void set_client_id(const char* client_id) { client_id_ = client_id; }

  /// @brief Get the iOS client ID.
  ///
  /// This is the client_id in the GoogleService-Info.plist.
  const char* client_id() const { return client_id_.c_str(); }
#endif  // INTERNAL_EXPERIMENTAL

#ifdef INTERNAL_EXPERIMENTAL
  /// @brief Set the Android or iOS client project name.
  ///
  /// This is the project_name in the Android google-services.json config
  /// file or BUNDLE_ID in the GoogleService-Info.plist.
  void set_package_name(const char* package_name) {
    package_name_ = package_name;
  }

  /// @brief Get the Android or iOS client project name.
  ///
  /// This is the project_name in the Android google-services.json config
  /// file or BUNDLE_ID in the GoogleService-Info.plist.
  const char* package_name() const { return package_name_.c_str(); }
#endif  // INTERNAL_EXPERIMENTAL

  /// @brief Load options from a config string.
  ///
  /// @param[in] config A JSON string that contains Firebase configuration i.e.
  /// the content of the downloaded google-services.json file.
  /// @param[out] options Optional: If provided, load options into it.
  ///
  /// @returns An instance containing the loaded options if successful.
  /// If the options argument to this function is null, this method returns an
  /// AppOptions instance allocated from the heap.
  static AppOptions* LoadFromJsonConfig(const char* config,
                                        AppOptions* options = nullptr);

#if INTERNAL_EXPERIMENTAL
  /// @brief Determine whether the specified options match this set of options.
  ///
  /// Fields of this object that are empty are ignored in the comparison.
  ///
  /// @param[in] options Options to compare with.
  bool operator==(const AppOptions& options) const {
    return (package_name_.empty() || package_name_ == options.package_name_) &&
           (api_key_.empty() || api_key_ == options.api_key_) &&
           (app_id_.empty() || app_id_ == options.app_id_) &&
           (database_url_.empty() || database_url_ == options.database_url_) &&
           (ga_tracking_id_.empty() ||
            ga_tracking_id_ == options.ga_tracking_id_) &&
           (fcm_sender_id_.empty() ||
            fcm_sender_id_ == options.fcm_sender_id_) &&
           (storage_bucket_.empty() ||
            storage_bucket_ == options.storage_bucket_) &&
           (project_id_.empty() || project_id_ == options.project_id_);
  }
#endif  // INTERNAL_EXPERIMENTAL

#if INTERNAL_EXPERIMENTAL
  /// @brief Determine whether the specified options don't match this set of
  /// options.
  ///
  /// Fields of this object that are empty are ignored in the comparison.
  ///
  /// @param[in] options Options to compare with.
  bool operator!=(const AppOptions& options) const {
    return !operator==(options);
  }
#endif  // INTERNAL_EXPERIMENTAL

#if INTERNAL_EXPERIMENTAL
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Load default options from the resource file.
  ///
  /// @param[in] jni_env JNI environment required to allow Firebase services
  /// to interact with the Android framework.
  /// @param[in] activity JNI reference to the Android activity, required to
  /// allow Firebase services to interact with the Android application.
  /// @param options Options to populate from a resource file.
  ///
  /// @return An instance containing the loaded options if successful.
  /// If the options argument to this function is null, this method returns an
  /// AppOptions instance allocated from the heap..
  static AppOptions* LoadDefault(AppOptions* options, JNIEnv* jni_env,
                                 jobject activity);
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)

#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Load default options from the resource file.
  ///
  /// @param options Options to populate from a resource file.
  ///
  /// @return An instance containing the loaded options if successful.
  /// If the options argument to this function is null, this method returns an
  /// AppOptions instance allocated from the heap.
  static AppOptions* LoadDefault(AppOptions* options);
#endif  // !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // INTERNAL_EXPERIMENTAL

#if INTERNAL_EXPERIMENTAL
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Attempt to populate required options with default values if not
  /// specified.
  ///
  /// @param[in] jni_env JNI environment required to allow Firebase services
  /// to interact with the Android framework.
  /// @param[in] activity JNI reference to the Android activity, required to
  /// allow Firebase services to interact with the Android application.
  ///
  /// @return true if successful, false otherwise.
  bool PopulateRequiredWithDefaults(JNIEnv* jni_env, jobject activity);
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)

#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Attempt to populate required options with default values if not
  /// specified.
  ///
  /// @return true if successful, false otherwise.
  bool PopulateRequiredWithDefaults();
#endif  // !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // INTERNAL_EXPERIMENTAL

  /// @cond FIREBASE_APP_INTERNAL
 private:
  /// Application package name (e.g Android package name or iOS bundle ID).
  std::string package_name_;
  /// API key used to communicate with Google Servers.
  std::string api_key_;
  /// ID of the app.
  std::string app_id_;
  /// ClientID of the app.
  std::string client_id_;
  /// Database root URL.
  std::string database_url_;
  /// Google analytics tracking ID.
  std::string ga_tracking_id_;
  /// FCM sender ID.
  std::string fcm_sender_id_;
  /// Google Cloud Storage bucket name.
  std::string storage_bucket_;
  /// Google Cloud project ID.
  std::string project_id_;
  /// @endcond
};

/// @brief Firebase application object.
///
/// @if cpp_examples
/// firebase::App acts as a conduit for communication between all Firebase
/// services used by an application.
///
/// For example:
/// @code
/// #if defined(__ANDROID__)
/// firebase::App::Create(firebase::AppOptions(), jni_env, activity);
/// #else
/// firebase::App::Create(firebase::AppOptions());
/// #endif  // defined(__ANDROID__)
/// @endcode
/// @endif
///
/// @if swig_examples
/// FirebaseApp acts as a conduit for communication between all Firebase
/// services used by an application. A default instance is created
/// automatically, based on settings in your Firebase configuration file,
/// and all of the Firebase APIs connect with it automatically.
/// @endif
class App {
 public:
  ~App();

#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes the default firebase::App with default options.
  ///
  /// @note This method is specific to non-Android implementations.
  ///
  /// @return New App instance, the App should not be destroyed for the
  /// lifetime of the application.  If default options can't be loaded this
  /// will return null.
  static App* Create();
#endif  // !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)

#ifndef SWIG
// <SWIG>
// For Unity, we actually use the simpler, iOS version for both platforms
// </SWIG>
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes the default firebase::App with default options.
  ///
  /// @note This method is specific to the Android implementation.
  ///
  /// @param[in] jni_env JNI environment required to allow Firebase services
  /// to interact with the Android framework.
  /// @param[in] activity JNI reference to the Android activity, required to
  /// allow Firebase services to interact with the Android application.
  ///
  /// @return New App instance. The App should not be destroyed for the
  /// lifetime of the application.  If default options can't be loaded this
  /// will return null.
  static App* Create(JNIEnv* jni_env, jobject activity);
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // SWIG

#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes the default firebase::App with the given options.
  ///
  /// @note This method is specific to non-Android implementations.
  ///
  /// Options are copied at initialization time, so changes to the object are
  /// ignored.
  /// @param[in] options Options that control the creation of the App.
  ///
  /// @return New App instance, the App should not be destroyed for the
  /// lifetime of the application.
  static App* Create(const AppOptions& options);
#endif  // !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)

#ifndef SWIG
// <SWIG>
// For Unity, we actually use the simpler, iOS version for both platforms
// </SWIG>
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes the default firebase::App with the given options.
  ///
  /// @note This method is specific to the Android implementation.
  ///
  /// Options are copied at initialization time, so changes to the object are
  /// ignored.
  /// @param[in] options Options that control the creation of the App.
  /// @param[in] jni_env JNI environment required to allow Firebase services
  /// to interact with the Android framework.
  /// @param[in] activity JNI reference to the Android activity, required to
  /// allow Firebase services to interact with the Android application.
  ///
  /// @return New App instance. The App should not be destroyed for the
  /// lifetime of the application.
  static App* Create(const AppOptions& options, JNIEnv* jni_env,
                     jobject activity);
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // SWIG

#if !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes a firebase::App with the given options that operates
  /// on the named app.
  ///
  /// @note This method is specific to non-Android implementations.
  ///
  /// Options are copied at initialization time, so changes to the object are
  /// ignored.
  /// @param[in] options Options that control the creation of the App.
  /// @param[in] name Name of this App instance.  This is only required when
  /// one application uses multiple App instances.
  ///
  /// @return New App instance, the App should not be destroyed for the
  /// lifetime of the application.
  static App* Create(const AppOptions& options, const char* name);
#endif  // !FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)

#ifndef SWIG
// <SWIG>
// For Unity, we actually use the simpler iOS version for both platforms
// </SWIG>
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// @brief Initializes a firebase::App with the given options that operates
  /// on the named app.
  ///
  /// @note This method is specific to the Android implementation.
  ///
  /// Options are copied at initialization time, so changes to the object are
  /// ignored.
  /// @param[in] options Options that control the creation of the App.
  /// @param[in] name Name of this App instance.  This is only required when
  /// one application uses multiple App instances.
  /// @param[in] jni_env JNI environment required to allow Firebase services
  /// to interact with the Android framework.
  /// @param[in] activity JNI reference to the Android activity, required to
  /// allow Firebase services to interact with the Android application.
  ///
  /// @return New App instance. The App should not be destroyed for the
  /// lifetime of the application.
  static App* Create(const AppOptions& options, const char* name,
                     JNIEnv* jni_env, jobject activity);
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // SWIG

  /// Get the default App, or nullptr if none has been created.
  static App* GetInstance();

  /// Get the App with the given name, or nullptr if none have been created.
  static App* GetInstance(const char* name);

#ifndef SWIG
// <SWIG>
// Unity doesn't need the JNI from here, it has its method to access JNI.
// </SWIG>
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// Get Java virtual machine, retrieved from the initial JNI environment.
  /// @note This method is specific to the Android implementation.
  ///
  /// @return JNI Java virtual machine object.
  JavaVM* java_vm() const;
  /// Get JNI environment, needed for performing JNI calls, set on creation.
  /// This is not trivial as the correct environment needs to retrieved per
  /// thread.
  /// @note This method is specific to the Android implementation.
  ///
  /// @return JNI environment object.
  JNIEnv* GetJNIEnv() const;
  /// Get a global reference to the Android activity provided to the App on
  /// creation. Also serves as the Context needed for Firebase calls.
  /// @note This method is specific to the Android implementation.
  ///
  /// @return Global JNI reference to the Android activity used to create
  /// the App.  The reference count of the returned object is not increased.
  jobject activity() const { return activity_; }
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // SWIG

  /// Get the name of this App instance.
  ///
  /// @return The name of this App instance.  If a name wasn't provided via
  /// Create(), this returns @ref kDefaultAppName.
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="Name">
  /// Get the name of this FirebaseApp instance.
  /// If a name wasn't provided via Create(), this will match @ref DefaultName.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const char* name() const { return name_.c_str(); }

  /// Get options the App was created with.
  ///
  /// @return Options used to create the App.
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="AppOptions">
  /// @brief Get the AppOptions the FirebaseApp was created with.
  /// @return AppOptions used to create the FirebaseApp.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  const AppOptions& options() const { return options_; }

#ifdef INTERNAL_EXPERIMENTAL
  /// Sets whether automatic data collection is enabled for all products.
  ///
  /// By default, automatic data collection is enabled. To disable automatic
  /// data collection in your mobile app, add to your Android application's
  /// manifest:
  ///
  /// @if NOT_DOXYGEN
  ///   <meta-data android:name="firebase_data_collection_default_enabled"
  ///   android:value="false" />
  /// @else
  /// @code
  ///   &lt;meta-data android:name="firebase_data_collection_default_enabled"
  ///   android:value="false" /&gt;
  /// @endcode
  /// @endif
  ///
  /// or on iOS to your Info.plist:
  ///
  /// @if NOT_DOXYGEN
  ///   <key>FirebaseDataCollectionDefaultEnabled</key>
  ///   <false/>
  /// @else
  /// @code
  ///   &lt;key&gt;FirebaseDataCollectionDefaultEnabled&lt;/key&gt;
  ///   &lt;false/&gt;
  /// @endcode
  /// @endif
  ///
  /// Once your mobile app is set to disable automatic data collection, you can
  /// ask users to consent to data collection, and then enable it after their
  /// approval by calling this method.
  ///
  /// This value is persisted across runs of the app so that it can be set once
  /// when users have consented to collection.
  ///
  /// @param enabled Whether or not to enable automatic data collection.
  void SetDataCollectionDefaultEnabled(bool enabled);

  /// Gets whether automatic data collection is enabled for all
  /// products. Defaults to true unless
  /// "firebase_data_collection_default_enabled" is set to false in your
  /// Android manifest and FirebaseDataCollectionDefaultEnabled is set to NO
  /// in your iOS app's Info.plist.
  ///
  /// @return Whether or not automatic data collection is enabled for all
  /// products.
  bool IsDataCollectionDefaultEnabled() const;
#endif  // INTERNAL_EXPERIMENTAL
#ifdef SWIG
  void SetDataCollectionDefaultEnabled(bool enabled);
  bool IsDataCollectionDefaultEnabled() const;
#endif  // SWIG

#ifdef INTERNAL_EXPERIMENTAL
  // This is only visible to SWIG and internal users of firebase::App.
  /// Get the initialization results of modules that were initialized when
  /// creating this app.
  ///
  /// @return Initialization results of modules indexed by module name.
  const std::map<std::string, InitResult>& init_results() const {
    return init_results_;
  }

  // Returns a pointer to the function registry, used by components to expose
  // methods to one another without introducing linkage dependencies.
  internal::FunctionRegistry* function_registry();

  /// @brief Register a library which utilizes the Firebase C++ SDK.
  ///
  /// @param library Name of the library to register as a user of the Firebase
  /// C++ SDK.
  /// @param version Version of the library being registered.
  static void RegisterLibrary(const char* library, const char* version);

  // Internal method to retrieve the combined string of registered libraries.
  static const char* GetUserAgent();

  // On desktop, when App.Create() is invoked without parameters, it looks for a
  // file named 'google-services-desktop.json', to load parameters from.
  // This function sets the location to search in.
  // Note - when setting this, make sure to end the path with the appropriate
  // path separator!
  static void SetDefaultConfigPath(const char* path);
#endif  // INTERNAL_EXPERIMENTAL

#ifdef INTERNAL_EXPERIMENTAL
#if FIREBASE_PLATFORM_DESKTOP
  // These methods are only visible to SWIG and internal users of firebase::App.

  /// Logs a heartbeat using the internal HeartbeatController.
  void LogHeartbeat() const;

  /// Get a pointer to the HeartbeatController associated with this app.
  std::shared_ptr<heartbeat::HeartbeatController> GetHeartbeatController()
      const;
#endif  // FIREBASE_PLATFORM_DESKTOP
#endif  // INTERNAL_EXPERIMENTAL

#ifdef INTERNAL_EXPERIMENTAL
#if FIREBASE_PLATFORM_ANDROID
  /// Get the platform specific app implementation referenced by this object.
  ///
  /// @return Global reference to the FirebaseApp.  The returned reference
  /// most be deleted after use.
  jobject GetPlatformApp() const;
#elif FIREBASE_PLATFORM_IOS || FIREBASE_PLATFORM_TVOS
#ifdef __OBJC__
  /// Get the platform specific app implementation referenced by this object.
  ///
  /// @return Reference to the FIRApp object owned by this app.
  FIRApp* GetPlatformApp() const;
#endif  // __OBJC__
#endif  // FIREBASE_PLATFORM_ANDROID, FIREBASE_PLATFORM_IOS,
        // FIREBASE_PLATFORM_TVOS
#endif  // INTERNAL_EXPERIMENTAL

 private:
  /// Construct the object.
  App()
      :
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
        activity_(nullptr),
#endif
        internal_(nullptr) {
    Initialize();

#ifdef FIREBASE_LINUX_BUILD_CONFIG_STRING
    CheckCompilerString(FIREBASE_LINUX_BUILD_CONFIG_STRING);
#endif  // FIREBASE_LINUX_BUILD_CONFIG_STRING
  }

  /// Initialize internal implementation
  void Initialize();

#ifndef SWIG
// <SWIG>
// Unity doesn't need the JNI from here, it has its method to access JNI.
// </SWIG>
#if FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
  /// Android activity.
  /// @note This is specific to Android.
  jobject activity_;
#endif  // FIREBASE_PLATFORM_ANDROID || defined(DOXYGEN)
#endif  // SWIG

  /// Name of the App instance.
  std::string name_;
  /// Options used to create this App instance.
  AppOptions options_;
  /// Module initialization results.
  std::map<std::string, InitResult> init_results_;
  /// Pointer to other internal data used by this instance.
  internal::AppInternal* internal_;

  /// @endcond
};

}  // namespace firebase

#endif  // FIREBASE_APP_SRC_INCLUDE_FIREBASE_APP_H_
