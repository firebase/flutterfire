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

#ifndef FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_H_
#define FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_H_

#include <vector>

#include "firebase/app.h"
#include "firebase/auth/user.h"
#include "firebase/future.h"
#include "firebase/internal/common.h"

#if !defined(DOXYGEN)
#ifndef SWIG
FIREBASE_APP_REGISTER_CALLBACKS_REFERENCE(auth)
#endif  // SWIG
#endif  // !defined(DOXYGEN)

namespace firebase {

/// @brief Firebase Authentication API.
///
/// Firebase Authentication provides backend services to securely authenticate
/// users. It can authenticate users using passwords and federated identity
/// provider credentials, and it can integrate with a custom auth backend.
namespace auth {

// Predeclarations.
struct AuthData;
class AuthStateListener;
class IdTokenListener;
class PhoneAuthProvider;
struct AuthCompletionHandle;
class FederatedAuthProvider;
class FederatedOAuthProvider;
struct SignInResult;

/// @brief Firebase authentication object.
///
/// <SWIG>
/// @if swig_examples
/// Firebase.Auth.FirebaseAuth is the gateway to the Firebase authentication
/// API. With it, you can reference @ref Firebase.Auth.FirebaseAuth objects to
/// manage user accounts and credentials.
///
/// Each @ref Firebase.FirebaseApp has up to one Firebase.Auth.FirebaseAuth
/// class. You acquire the Firebase.Auth.FirebaseAuth class through the static
/// function @ref Firebase.Auth.FirebaseAuth.GetAuth.
///
/// For example:
/// @code{.cs}
///  // Get the Auth class for your App.
///  Firebase.Auth.FirebaseAuth auth = Firebase.Auth.FirebaseAuth.GetAuth(app);
///
///  // Request anonymous sign-in and wait until asynchronous call completes.
///  auth.SignInAnonymouslyAsync().ContinueWith((authTask) => {
///  // Print sign in results.
///    if (authTask.IsCanceled) {
///      DebugLog("Sign-in canceled.");
///    } else if (authTask.IsFaulted) {
///      DebugLog("Sign-in encountered an error.");
///      DebugLog(authTask.Exception.ToString());
///    } else if (authTask.IsCompleted) {
///      Firebase.Auth.User user = authTask.Result;
///      DebugLog(String.Format("Signed in as {0} user.",
///          user.Anonymous ? "an anonymous" : "a non-anonymous"));
///      DebugLog("Signing out.");
///      auth.SignOut();
///  });
/// @endcode
/// @endif
/// </SWIG>
/// @if cpp_examples
///
/// firebase::auth::Auth is the gateway to the Firebase authentication API.
/// With it, you can reference @ref firebase::auth::User objects to manage user
/// accounts and credentials.
///
/// Each @ref firebase::App has up to one firebase::auth::Auth class. You
/// acquire the firebase::auth::Auth class through the static function
/// @ref firebase::auth::Auth::GetAuth.
///
/// For example:
/// @code{.cpp}
///
/// // Get the Auth class for your App.
/// firebase::auth::Auth* auth = firebase::auth::Auth::GetAuth(app);
///
/// // Request anonymous sign-in and wait until asynchronous call completes.
/// firebase::Future<firebase::auth::User*> sign_in_future =
///     auth->SignInAnonymously();
/// while(sign_in_future.status() == firebase::kFutureStatusPending) {
///     // when polling, like this, make sure you service your platform's
///     // message loop
///     // see https://github.com/firebase/quickstart-cpp for a sample
///     ProcessEvents(300);
///     std::cout << "Signing in...\n";
/// }
///
/// const firebase::auth::AuthError error =
///     static_cast<firebase::auth::AuthError>(sign_in_future.error());
/// if (error != firebase::auth::kAuthErrorNone) {
///     std::cout << "Sign in failed with error '"
///         << sign_in_future.error_message() << "'\n";
/// } else {
///     firebase::auth::User* user = *sign_in_future.result();
///     // is_anonymous from Anonymous
///     std::cout << "Signed in as "
///         << (user->is_anonymous() ? "an anonymous" : "a non-anonymous")
///         << " user\n";
/// }
/// @endcode
/// @endif
class Auth {
 public:
  /// @brief Results of calls @ref FetchProvidersForEmail.
  ///
  /// <SWIG>
  /// @if swig_examples
  /// @see FirebaseAuth.FetchProvidersForEmailAsync().
  /// @endif
  /// </SWIG>
  struct FetchProvidersResult {
    /// The IDPs (identity providers) that can be used for `email`.
    /// An array of length `num_providers` of null-terminated strings.
    /// <SWIG>
    /// The C# doc string is in the SWIG file because nested structs are
    /// causing problems b/35780150
    /// </SWIG>
    std::vector<std::string> providers;
  };

  ~Auth();

  /// Synchronously gets the cached current user, or nullptr if there is none.
  /// @note This function may block and wait until the Auth instance finishes
  /// loading the saved user's state. This should only happen for a short
  /// period of time after the Auth instance is created.
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="CurrentUser">
  /// Synchronously gets the cached current user, or null if there is none.
  /// @note This function may block and wait until the Auth instance finishes
  /// loading the saved user's state. This should only happen for a short
  /// period of time after the Auth instance is created.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  User* current_user();

  /// The current user language code. This can be set to the app’s current
  /// language by calling set_language_code. The string must be a language code
  /// that follows BCP 47.  This will return an empty string if the app default
  /// language code is being used.
  std::string language_code() const;

  /// Sets the user-facing language code for auth operations that can be
  /// internationalized, such as FirebaseUser.sendEmailVerification(). This
  /// language code should follow the conventions defined by the IETF in BCP 47.
  void set_language_code(const char* language_code);

  /// Sets the user-facing language code to be the default app language. This
  /// uses a language associated with the device's locale data.  On desktop
  /// this will set the language code to the Firebase service's default. You
  /// may subsequently customize the language code again by invoking
  /// set_language_code().
  void UseAppLanguage();

  // ----- Providers -------------------------------------------------------
  /// Asynchronously requests the IDPs (identity providers) that can be used
  /// for the given email address.
  ///
  /// Useful for an "identifier-first" login flow.
  ///
  /// @if cpp_examples
  /// The following sample code illustrates a possible login screen
  /// that allows the user to pick an identity provider.
  /// @code{.cpp}
  ///  // This function is called every frame to display the login screen.
  ///  // Returns the identity provider name, or "" if none selected.
  ///  const char* DisplayIdentityProviders(firebase::auth::Auth& auth,
  ///                                       const char* email) {
  ///    // Get results of most recent call to FetchProvidersForEmail().
  ///    firebase::Future<firebase::auth::Auth::FetchProvidersResult> future =
  ///        auth.FetchProvidersForEmailLastResult();
  ///    const firebase::auth::Auth::FetchProvidersResult* result =
  ///        future.result();
  ///
  ///    // Header.
  ///    ShowTextBox("Sign in %s", email);
  ///
  ///    // Fetch providers from the server if we need to.
  ///    const bool refetch =
  ///        future.status() == firebase::kFutureStatusInvalid ||
  ///        (result != nullptr && strcmp(email, result->email.c_str()) != 0);
  ///    if (refetch) {
  ///      auth.FetchProvidersForEmail(email);
  ///    }
  ///
  ///    // Show a waiting icon if we're waiting for the asynchronous call to
  ///    // complete.
  ///    if (future.status() != firebase::kFutureStatusComplete) {
  ///      ShowImage("waiting icon");
  ///      return "";
  ///    }
  ///
  ///    // Show error code if the call failed.
  ///    if (future.error() != firebase::auth::kAuthErrorNone) {
  ///      ShowTextBox("Error fetching providers: %s", future.error_message());
  ///    }
  ///
  ///    // Show a button for each provider available to this email.
  ///    // Return the provider for the button that's pressed.
  ///    for (size_t i = 0; i < result->providers.size(); ++i) {
  ///      const bool selected = ShowTextButton(result->providers[i].c_str());
  ///      if (selected) return result->providers[i].c_str();
  ///    }
  ///    return "";
  ///  }
  /// @endcode
  /// @endif
  Future<FetchProvidersResult> FetchProvidersForEmail(const char* email);

  /// Get results of the most recent call to @ref FetchProvidersForEmail.
  Future<FetchProvidersResult> FetchProvidersForEmailLastResult() const;

  // ----- Sign In ---------------------------------------------------------
  /// Asynchronously logs into Firebase with the given Auth token.
  ///
  /// An error is returned, if the token is invalid, expired or otherwise
  /// not accepted by the server.
  Future<User*> SignInWithCustomToken(const char* token);

  /// Get results of the most recent call to @ref SignInWithCustomToken.
  Future<User*> SignInWithCustomTokenLastResult() const;

  /// Convenience method for @ref SignInAndRetrieveDataWithCredential that
  /// doesn't return additional identity provider data.
  Future<User*> SignInWithCredential(const Credential& credential);

  /// Get results of the most recent call to @ref SignInWithCredential.
  Future<User*> SignInWithCredentialLastResult() const;

  /// Sign-in a user authenticated via a federated auth provider.
  ///
  /// @param[in] provider Contains information on the provider to authenticate
  /// with.
  ///
  /// @return A Future with the result of the sign-in request.
  ///
  /// @note: This operation is supported only on iOS, tvOS and Android
  /// platforms. On other platforms this method will return a Future with a
  /// preset error code: kAuthErrorUnimplemented.
  Future<SignInResult> SignInWithProvider(FederatedAuthProvider* provider);

  /// Asynchronously logs into Firebase with the given credentials.
  ///
  /// For example, the credential could wrap a Facebook login access token or
  /// a Twitter token/token-secret pair.
  ///
  /// The SignInResult contains both a reference to the User (which can be null
  /// if the sign in failed), and AdditionalUserInfo, which holds details
  /// specific to the Identity Provider used to sign in.
  ///
  /// An error is returned if the token is invalid, expired, or otherwise not
  /// accepted by the server.
  Future<SignInResult> SignInAndRetrieveDataWithCredential(
      const Credential& credential);

  /// Get results of the most recent call to
  /// @ref SignInAndRetrieveDataWithCredential.
  Future<SignInResult> SignInAndRetrieveDataWithCredentialLastResult() const;

  /// Asynchronously creates and becomes an anonymous user.
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead.
  /// If there is any other existing user, that user will be signed out.
  ///
  /// <SWIG>
  /// @if swig_examples
  /// @code{.cs}
  ///  bool SignIn(Firebase.Auth.FirebaseAuth auth) {
  ///    auth.SignInAnonymouslyAsync().ContinueWith((authTask) => {
  ///      if (authTask.IsCanceled) {
  ///        DebugLog("Anonymous sign in canceled.");
  ///      } else if (authTask.IsFaulted) {
  ///        DebugLog("Anonymous sign in encountered an error.");
  ///        DebugLog(authTask.Exception.ToString());
  ///      } else if (authTask.IsCompleted) {
  ///        DebugLog("Anonymous sign in successful!");
  ///      }
  ///    });
  ///  }
  /// @endcode
  /// @endif
  /// </SWIG>
  /// @if cpp_examples
  /// The following sample code illustrates the sign-in flow that might be
  /// used by a game or some other program with a regular (for example, 30Hz)
  /// update loop.
  ///
  /// The sample calls SignIn() every frame. We don’t maintain our own
  /// Futures but instead call SignInAnonymouslyLastResult() to get the Future
  /// of our most recent call.
  ///
  /// @code{.cpp}
  ///  // Try to ensure that we get logged in.
  ///  // This function is called every frame.
  ///  bool SignIn(firebase::auth::Auth& auth) {
  ///    // Grab the result of the latest sign-in attempt.
  ///    firebase::Future<firebase::auth::User*> future =
  ///        auth.SignInAnonymouslyLastResult();
  ///
  ///    // If we're in a state where we can try to sign in, do so.
  ///    if (future.status() == firebase::kFutureStatusInvalid ||
  ///        (future.status() == firebase::kFutureStatusComplete &&
  ///         future.error() != firebase::auth::kAuthErrorNone)) {
  ///      auth.SignInAnonymously();
  ///    }
  ///
  ///    // We're signed in if the most recent result was successful.
  ///    return future.status() == firebase::kFutureStatusComplete &&
  ///           future.error() == firebase::auth::kAuthErrorNone;
  ///  }
  /// @endcode
  /// @endif
  Future<User*> SignInAnonymously();

  /// Get results of the most recent call to @ref SignInAnonymously.
  Future<User*> SignInAnonymouslyLastResult() const;

  /// Signs in using provided email address and password.
  /// An error is returned if the password is wrong or otherwise not accepted
  /// by the server.
  Future<User*> SignInWithEmailAndPassword(const char* email,
                                           const char* password);

  /// Get results of the most recent call to @ref SignInWithEmailAndPassword.
  Future<User*> SignInWithEmailAndPasswordLastResult() const;

  /// Creates, and on success, logs in a user with the given email address
  /// and password.
  ///
  /// An error is returned when account creation is unsuccessful
  /// (due to another existing account, invalid password, etc.).
  Future<User*> CreateUserWithEmailAndPassword(const char* email,
                                               const char* password);

  /// Get results of the most recent call to
  /// @ref CreateUserWithEmailAndPassword.
  Future<User*> CreateUserWithEmailAndPasswordLastResult() const;

  /// Removes any existing authentication credentials from this client.
  /// This function always succeeds.
  void SignOut();

  // ----- Password Reset -------------------------------------------------
  /// Initiates a password reset for the given email address.
  ///
  /// If the email address is not registered, then the returned task has a
  /// status of IsFaulted.
  ///
  /// <SWIG>
  /// @if swig_examples
  /// @code{.cs}
  ///  void ResetPassword(string email) {
  ///    auth.SendPasswordResetEmail(email).ContinueWith((authTask) => {
  ///      if (authTask.IsCanceled) {
  ///        DebugLog("Password reset was canceled.");
  ///      } else if (authTask.IsFaulted) {
  ///        DebugLog("Password reset encountered an error.");
  ///        DebugLog(authTask.Exception.ToString());
  ///      } else if (authTask.IsCompleted) {
  ///        DebugLog("Password reset successful!");
  ///      }
  ///    });
  ///  }
  /// @endcode
  /// @endif
  /// </SWIG>
  /// @if cpp_examples
  /// The following sample code illustrating a possible password reset flow.
  /// Like in the Anonymous Sign-In example above, the ResetPasswordScreen()
  /// function is called once per frame (say 30 times per second).
  ///
  /// No state is persisted by the caller in this example. The state of the
  /// most recent calls are instead accessed through calls to functions like
  /// auth.SendPasswordResetEmailLastResult().
  /// @code{.cpp}
  ///  const char* ImageNameForStatus(const firebase::FutureBase& future) {
  ///    assert(future.status() != firebase::kFutureStatusInvalid);
  ///    return future.status() == firebase::kFutureStatusPending
  ///               ? "waiting icon"
  ///               : future.error() == firebase::auth::kAuthErrorNone
  ///                    ? "checkmark icon"
  ///                    : "x mark icon";
  ///  }
  ///
  ///  // This function is called once per frame.
  ///  void ResetPasswordScreen(firebase::auth::Auth& auth) {
  ///    // Gather email address.
  ///    // ShowInputBox() returns a value when `enter` is pressed.
  ///    const std::string email = ShowInputBox("Enter e-mail");
  ///    if (email != "") {
  ///      auth.SendPasswordResetEmail(email.c_str());
  ///    }
  ///
  ///    // Show checkmark, X-mark, or waiting icon beside the
  ///    // email input box, to indicate if email has been sent.
  ///    firebase::Future<void> send_future =
  ///        auth.SendPasswordResetEmailLastResult();
  ///    ShowImage(ImageNameForStatus(send_future));
  ///
  ///    // Display error message if the e-mail could not be sent.
  ///    if (send_future.status() == firebase::kFutureStatusComplete &&
  ///        send_future.error() != firebase::auth::kAuthErrorNone) {
  ///      ShowTextBox(send_future.error_message());
  ///    }
  ///  }
  /// @endcode
  /// @endif
  Future<void> SendPasswordResetEmail(const char* email);

  /// Get results of the most recent call to @ref SendPasswordResetEmail.
  Future<void> SendPasswordResetEmailLastResult() const;

#ifndef SWIG
  /// @brief Registers a listener to changes in the authentication state.
  ///
  /// There can be more than one listener registered at the same time.
  /// The listeners are called asynchronously, possibly on a different thread.
  ///
  /// Authentication state changes are:
  ///   - Right after the listener has been registered
  ///   - When a user signs in
  ///   - When the current user signs out
  ///   - When the current user changes
  ///
  /// It is a recommended practice to always listen to sign-out events, as you
  /// may want to prompt the user to sign in again and maybe restrict the
  /// information or actions they have access to.
  ///
  /// Use RemoveAuthStateListener to unregister a listener.
  ///
  /// @note The caller owns `listener` and is responsible for destroying it.
  /// When `listener` is destroyed, or when @ref Auth is destroyed,
  /// RemoveAuthStateListener is called automatically.
  void AddAuthStateListener(AuthStateListener* listener);

  /// @brief Unregisters a listener of authentication changes.
  ///
  /// Listener must previously been added with AddAuthStateListener.
  ///
  /// Note that listeners unregister themselves automatically when they
  /// are destroyed, and the Auth class unregisters its listeners when the
  /// Auth class itself is destroyed, so this function does not normally need
  /// to be called explicitly.
  void RemoveAuthStateListener(AuthStateListener* listener);

  /// @brief Registers a listener to changes in the ID token state.
  ///
  /// There can be more than one listener registered at the same time.
  /// The listeners are called asynchronously, possibly on a different thread.
  ///
  /// Authentication state changes are:
  ///   - Right after the listener has been registered
  ///   - When a user signs in
  ///   - When the current user signs out
  ///   - When the current user changes
  ///   - When there is a change in the current user's token
  ///
  /// Use RemoveIdTokenListener to unregister a listener.
  ///
  /// @note The caller owns `listener` and is responsible for destroying it.
  /// When `listener` is destroyed, or when @ref Auth is destroyed,
  /// RemoveIdTokenListener is called automatically.
  void AddIdTokenListener(IdTokenListener* listener);

  /// @brief Unregisters a listener of ID token changes.
  ///
  /// Listener must previously been added with AddIdTokenListener.
  ///
  /// Note that listeners unregister themselves automatically when they
  /// are destroyed, and the Auth class unregisters its listeners when the
  /// Auth class itself is destroyed, so this function does not normally need
  /// to be called explicitly.
  void RemoveIdTokenListener(IdTokenListener* listener);
#endif  // not SWIG

  /// Gets the App this auth object is connected to.
  App& app();

  /// Returns the Auth object for an App. Creates the Auth if required.
  ///
  /// To get the Auth object for the default app, use,
  /// GetAuth(GetDefaultFirebaseApp());
  ///
  /// If the library Auth fails to initialize, init_result_out will be
  /// written with the result status (if a pointer is given).
  ///
  /// @param[in] app The App to use for the Auth object.
  /// @param[out] init_result_out Optional: If provided, write the init result
  /// here. Will be set to kInitResultSuccess if initialization succeeded, or
  /// kInitResultFailedMissingDependency on Android if Google Play services is
  /// not available on the current device.
  static Auth* GetAuth(App* app, InitResult* init_result_out = nullptr);

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class ::firebase::App;
  friend class ::firebase::auth::PhoneAuthProvider;
  friend class IdTokenRefreshListener;
  friend class IdTokenRefreshThread;
  friend class UserDataPersist;
  friend class UserDesktopTest;
  friend class AuthDesktopTest;

  friend void EnableTokenAutoRefresh(AuthData* authData);
  friend void DisableTokenAutoRefresh(AuthData* authData);
  friend void ResetTokenRefreshCounter(AuthData* authData);
  friend void LogHeartbeat(Auth* auth);
  /// @endcond

  // Find Auth instance using App.  Return null if the instance does not exist.
  static Auth* FindAuth(App* app);

  // Provides access to the auth token for the current user.  Returns the
  // current user's auth token, or an empty string, if there isn't one.
  // Note that this can potentially return an expired token from the cache.
  static bool GetAuthTokenForRegistry(App* app, void* /*unused*/, void* out);

  // Provides asynchronous access to the auth token for the current user. Allow
  // the caller to force-refresh the token.  Even without force-refresh, this
  // ensure the future contain a fresh current user's auth token.  This function
  // returns invalid future if user data is not available.
  static bool GetAuthTokenAsyncForRegistry(App* app, void* force_refresh,
                                           void* out_future);

  // Provides access to the current user's uid, equivalent to calling
  // this->current_user()->uid(). Returns the current user's uid or an empty
  // string, if there isn't one. The out pointer is expected to point to an
  // instance of std::string.
  static bool GetCurrentUserUidForRegistry(App* app, void* /*unused*/,
                                           void* out);

  // Starts and stops a thread to ensure that the cached auth token is never
  // kept long enough for it to expire.  Refcounted, so multiple classes can
  // register this without causing problems.
  static bool StartTokenRefreshThreadForRegistry(App* app, void* /*unused*/,
                                                 void* /*unused*/);
  static bool StopTokenRefreshThreadForRegistry(App* app, void* /*unused*/,
                                                void* /*unused*/);

  // Adds an indirect auth state listener implemented as a callback and a
  // context object.
  //
  // @param callback a function pointer that takes a single void* argument and
  //     returns void (i.e. it has type void (*)(void*)).
  // @param context a pointer to an arbitrary object that Auth will pass to
  //     the callback when the auth state changes.
  static bool AddAuthStateListenerForRegistry(App* app, void* callback,
                                              void* context);

  // Removes the indirect auth state listener that was added with the same
  // arguments.
  static bool RemoveAuthStateListenerForRegistry(App* app, void* callback,
                                                 void* context);

  // Init and Destroy the platform specific auth data.
  void InitPlatformAuth(AuthData* const auth_data);
  void DestroyPlatformAuth(AuthData* const auth_data);

  // Call GetAuth() to create an Auth object.
  // Constructors and destructors don't make any external calls.
  // They just initialize and deinitialize internal variables.
  Auth(App* app, void* auth_impl);

  // Delete the internal AuthData object.
  void DeleteInternal();

  // This class uses the pimpl mechanism to avoid exposing platform-dependent
  // implementation.
  AuthData* auth_data_;
};

#ifndef SWIG
/// @brief Listener called when there is a change in the authentication state.
///
/// Override base class method to handle authentication state changes.
/// Methods are invoked asynchronously and may be invoked on other threads.
class AuthStateListener {
 public:
  /// @note: Destruction of the listener automatically calls
  /// RemoveAuthStateListener() from the Auths this listener is registered with,
  /// if those Auths have not yet been destroyed.
  virtual ~AuthStateListener();

  /// Called when the authentication state of `auth` changes.
  ///   - Right after the listener has been registered
  ///   - When a user is signed in
  ///   - When the current user is signed out
  ///   - When the current user changes
  ///
  /// @param[in] auth Disambiguates which @ref Auth instance the event
  /// corresponds to, in the case where you are using more than one at the same
  /// time.
  virtual void OnAuthStateChanged(Auth* auth) = 0;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class Auth;
  /// @endcond

  /// The Auths with which this listener has been registered.
  std::vector<Auth*> auths_;
};
#endif  // not SWIG

#ifndef SWIG
/// @brief Listener called when there is a change in the ID token.
///
/// Override base class method to handle ID token changes.
/// Methods are invoked asynchronously and may be invoked on other threads.
class IdTokenListener {
 public:
  /// @note: Destruction of the listener automatically calls
  /// RemoveIdTokenListener() from the Auths this listener is registered with,
  /// if those Auths have not yet been destroyed.
  virtual ~IdTokenListener();

  /// Called when there is a change in the current user's token.
  ///   - Right after the listener has been registered
  ///   - When a user signs in
  ///   - When the current user signs out
  ///   - When the current user changes
  ///   - When there is a change in the current user's token
  ///
  /// @param[in] auth Disambiguates which @ref Auth instance the event
  /// corresponds to, in the case where you are using more than one at the same
  /// time.
  virtual void OnIdTokenChanged(Auth* auth) = 0;

 private:
  /// @cond FIREBASE_APP_INTERNAL
  friend class Auth;
  /// @endcond

  /// The Auths with which this listener has been registered.
  std::vector<Auth*> auths_;
};

#endif  // not SWIG

/// @brief Used to authenticate with Federated Auth Providers.
///
/// The federated auth provider implementation may facilitate multiple provider
/// types in the future, with support for OAuth to start.
class FederatedAuthProvider {
 public:
#ifdef INTERNAL_EXPERIMENTAL
#ifndef SWIG
  /// @brief Contains resulting information of a user authenticated by a
  /// Federated Auth Provider.  This information will be used by the internal
  /// implementation to construct a corresponding User object.
  struct AuthenticatedUserData {
    /// The unique ID identifies the IdP account.
    const char* uid;

    /// [opt] The email of the account.
    const char* email;

    /// Whether the sign-in email is verified.
    bool is_email_verified;

    /// [opt] The display name for the account.
    const char* display_name;

    /// [opt] The username for the account.
    const char* user_name;

    /// [opt] The photo Url for the account, if one exists.
    const char* photo_url;

    /// The linked provider ID (e.g. "google.com" for the Google provider).
    const char* provider_id;

    /// A Firebase Auth ID token for the authenticated user.
    const char* access_token;

    /// A Firebase Auth refresh token for the authenticated user.
    const char* refresh_token;

    /// [opt] IdP user profile data corresponding to the provided credential.
    std::map<Variant, Variant> raw_user_info;

    /// The number of seconds in which the ID token expires.
    uint64_t token_expires_in_seconds;
  };

  /// @brief Handlers for client applications to facilitate federated auth
  /// requests on non-mobile systems.
  template <class T>
  class Handler {
   public:
    virtual ~Handler() {}

    /// @brief Application sign-in handler.
    ///
    /// The application must implement this method to handle federated auth user
    /// sign-in requests on non-mobile systems.
    ///
    /// @param[in] provider_data Contains information on the provider to
    /// authenticate with.
    /// @param[in] completion_handle Internal data pertaining to this operation
    /// which must be passed to SignInComplete once the handler has completed
    /// the sign in operation.
    ///
    /// @see Auth#SignInWithProvider
    /// @see SignInComplete
    virtual void OnSignIn(const T& provider_data,
                          AuthCompletionHandle* completion_handle) = 0;

    /// Completion for OnSignIn events.
    ///
    /// Invoke this method once the corresponding OnSignIn has been fulfilled.
    /// This method will trigger the associated Future<SignInResult> previously
    /// returned from the Auth::SignInWithProvider method.
    ///
    /// @param[in] completion_handle The handle provided to the application's
    /// FederatedAuthProvider::Handler::OnSignIn method.
    /// @param[in] user_data The application's resulting Firebase user
    /// values following the authorization request.
    /// @param[in] auth_error The enumerated status code of the authorization
    /// request.
    /// @param[in] error_message An optional error message to be set in the
    ///  Future.
    ///
    /// @see OnSignIn
    /// @see Auth::SignInWithProvider
    void SignInComplete(AuthCompletionHandle* completion_handle,
                        const AuthenticatedUserData& user_data,
                        AuthError auth_error, const char* error_message);

    /// @brief Application user account link handler.
    ///
    /// The application must implement this method to handle federated auth user
    /// link requests on non-mobile systems.
    ///
    /// @param[in] provider_data Contains information on the provider to
    /// authenticate with.
    /// @param[in] completion_handle Internal data pertaining to this operation
    /// which must be passed to LinkComplete once the handler has completed the
    /// user link operation.
    ///
    /// @see User#LinkWithProvider
    virtual void OnLink(const T& provider_data,
                        AuthCompletionHandle* completion_handle) = 0;

    /// Completion for non-mobile user authorization handlers.
    ///
    /// Invoke this method once the OnLine process has been fulfilled. This
    /// method will trigger the associated Future<SignInResult> previously
    /// returned from an invocation of User::LinkWithProvider.
    ///
    /// @param[in] completion_handle The handle provided to the
    /// application's FederatedAuthProvider::Handler::OnLink method.
    /// @param[in] user_data The application's resulting Firebase user
    /// values following the user link request.
    /// @param[in] auth_error The enumerated status code of the user link
    /// request.
    /// @param[in] error_message An optional error message to be set in the
    ///  Future.
    ///
    /// @see OnLink
    /// @see User#LinkWithProvider
    void LinkComplete(AuthCompletionHandle* completion_handle,
                      const AuthenticatedUserData& user_data,
                      AuthError auth_error, const char* error_message);

    /// @brief Application user re-authentication handler.
    ///
    /// The application must implement this method to handle federated auth user
    /// re-authentication requests on non-mobile systems.
    ///
    /// @param[in] provider_data Contains information on the provider to
    /// authenticate with.
    /// @param[in] completion_handle Internal data pertaining to this operation
    /// which must be passed to ReauthenticateComplete once the handler has
    /// completed the reauthentication operation.
    ///
    /// @see User#ReauthenticateWithProviderComplete
    virtual void OnReauthenticate(const T& provider_data,
                                  AuthCompletionHandle* completion_handle) = 0;

    /// Completion for non-mobile user authorization handlers.
    ///
    /// Invoke this method once the OnReauthenticate process has been
    /// fulfilled. This method will trigger the associated Future<SignInResult>
    /// previously returned from an invocation of
    /// User::ReauthenticateWithProvider.
    ///
    /// @param[in] completion_handle The handle provided to the application's
    /// FederatedAuthProvider::Handler::OnReauthenticate method.
    /// @param[in] user_data The application's resulting Firebase user
    /// values following the user re-authentication request.
    /// @param[in] auth_error The enumerated status code of the reauthentication
    /// request.
    /// @param[in] error_message An optional error message to be set in the
    ///  Future.
    ///
    /// @see OnReauthenticate
    /// @see User#ReuthenticateWithProvider
    void ReauthenticateComplete(AuthCompletionHandle* completion_handle,
                                const AuthenticatedUserData& user_data,
                                AuthError auth_error,
                                const char* error_message);
  };
#endif  // not SWIG
#endif  // INTERNAL_EXPERIMENTAL

  FederatedAuthProvider() {}
  virtual ~FederatedAuthProvider() {}

 private:
  friend class ::firebase::auth::Auth;
  friend class ::firebase::auth::User;
  virtual Future<SignInResult> SignIn(AuthData* auth_data) = 0;
  virtual Future<SignInResult> Link(AuthData* auth_data) = 0;
  virtual Future<SignInResult> Reauthenticate(AuthData* auth_data) = 0;
};

/// @brief Authenticates with Federated OAuth Providers via the
/// firebase::auth::Auth and firebase::auth::User classes.
///
/// Once configured with a provider id, and with OAuth scope and OAuth custom
/// parameters via an FedeartedOAuthProviderData structure, an object of
/// this class may be used via Auth::SignInWithProvider to sign-in users, or via
/// User::LinkWithProvider and User::ReauthenticateWithProvider for cross
/// account linking and user reauthentication, respectively.
class FederatedOAuthProvider : public FederatedAuthProvider {
 public:
#ifdef INTERNAL_EXPERIMENTAL
#ifndef SWIG
  /// @brief A FederatedAuthProvider typed specifically for OAuth Authentication
  /// handling.
  ///
  /// To be used on non-mobile environments for custom OAuth implementations and
  /// UI flows.
  typedef FederatedAuthProvider::Handler<FederatedOAuthProviderData>
      AuthHandler;
#endif  // !SWIG
#endif  // INTERNAL_EXPERIMENTAL

  /// Constructs an unconfigured provider.
  FederatedOAuthProvider();

  /// Constructs a FederatedOAuthProvider preconfigured with provider data.
  ///
  /// @param[in] provider_data Contains the federated provider id and OAuth
  /// scopes and OAuth custom parameters required for user authentication and
  /// user linking.
  explicit FederatedOAuthProvider(
      const FederatedOAuthProviderData& provider_data);

#ifdef INTERNAL_EXPERIMENTAL
#ifndef SWIG
  /// @brief Constructs a provider with the required information to authenticate
  /// using an OAuth Provider.
  ///
  /// An AuthHandler is required on desktop platforms to facilitate custom
  /// implementations of OAuth authentication. The AuthHandler must outlive the
  /// instance of this OAuthProvider on desktop systems and is ignored on iOS,
  /// tvOS, and Android platforms.
  ///
  /// @param[in] provider_data Contains information on the provider to
  /// authenticate with.
  /// @param[in] handler An FederatedOAuthProviderData typed
  /// FederatedAuthProvider::Handler which be invoked on non-mobile systems
  /// to handle authentication requests.
  FederatedOAuthProvider(const FederatedOAuthProviderData& provider_data,
                         AuthHandler* handler);
#endif  // !SWIG
#endif  // INTERNAL_EXPERIMENTAL

  ~FederatedOAuthProvider() override;

  /// @brief Configures the provider with OAuth provider information.
  ///
  /// @param[in] provider_data Contains the federated provider id and OAuth
  /// scopes and OAuth custom parameters required for user authentication and
  /// user linking.
  void SetProviderData(const FederatedOAuthProviderData& provider_data);

#ifdef INTERNAL_EXPERIMENTAL
#ifndef SWIG
  /// @brief Configures the use of an AuthHandler for non-mobile systems.
  ///
  /// The existence of a handler is required for non-mobile systems, and is
  /// ignored on iOS, tvOS and Android platforms.
  ///
  /// @param[in] handler An FederatedOAuthProviderData typed
  /// FederatedAuthProvider::Handler which be invoked on non-mobile systems
  /// to handle authentication requests. The handler must outlive the instance
  /// of this FederatedOAuthProvider.
  void SetAuthHandler(AuthHandler* handler);
#endif  // !SWIG
#endif  // INTERNAL_EXPERIMENTAL

 private:
  friend class ::firebase::auth::Auth;

  Future<SignInResult> SignIn(AuthData* auth_data) override;
  Future<SignInResult> Link(AuthData* auth_data) override;
  Future<SignInResult> Reauthenticate(AuthData* auth_data) override;

  FederatedOAuthProviderData provider_data_;
#ifdef INTERNAL_EXPERIMENTAL
  AuthHandler* handler_;
#endif  // INTERNAL_EXPERIMENTAL
};

}  // namespace auth
}  // namespace firebase

#endif  // FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_H_
