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

#ifndef FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_CREDENTIAL_H_
#define FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_CREDENTIAL_H_

#include <stdint.h>

#include <string>

#include "firebase/auth/types.h"
#include "firebase/internal/common.h"

namespace firebase {

// Predeclarations.
class App;

/// @cond FIREBASE_APP_INTERNAL
template <typename T>
class Future;
/// @endcond

namespace auth {

// Predeclarations.
class Auth;
class User;

// Opaque internal types.
struct AuthData;
class ForceResendingTokenData;
struct PhoneAuthProviderData;
struct PhoneListenerData;

/// @brief Authentication credentials for an authentication provider.
///
/// An authentication provider is a service that allows you to authenticate
/// a user. Firebase provides email/password authentication, but there are also
/// external authentication providers such as Facebook.
class Credential {
#ifndef SWIG
  /// @cond FIREBASE_APP_INTERNAL
  friend class EmailAuthProvider;
  friend class FacebookAuthProvider;
  friend class GameCenterAuthProvider;
  friend class GitHubAuthProvider;
  friend class GoogleAuthProvider;
  friend class JniAuthPhoneListener;
  friend class MicrosoftAuthProvider;
  friend class OAuthProvider;
  friend class PhoneAuthProvider;
  friend class PlayGamesAuthProvider;
  friend class TwitterAuthProvider;
  friend class YahooAuthProvider;
  friend class ServiceUpdatedCredentialProvider;
  /// @endcond
#endif  // !SWIG

 private:
  /// Should only be created by `Provider` classes.
  ///
  /// @see EmailAuthProvider::GetCredential()
  /// @see FacebookAuthProvider::GetCredential()
  /// @see GoogleAuthProvider::GetCredential()
  explicit Credential(void* impl) : impl_(impl), error_code_(kAuthErrorNone) {}

 public:
  Credential() : impl_(nullptr), error_code_(kAuthErrorNone) {}
  ~Credential();

  /// Copy constructor.
  Credential(const Credential& rhs);

  /// Copy a Credential.
  Credential& operator=(const Credential& rhs);

  /// Gets the name of the Identification Provider (IDP) for the credential.
  ///
  /// <SWIG>
  /// @xmlonly
  /// <csproperty name="Provider">
  /// Gets the name of the Identification Provider (IDP) for the credential.
  /// </csproperty>
  /// @endxmlonly
  /// </SWIG>
  std::string provider() const;

  /// Get whether this credential is valid. A credential can be
  /// invalid in an error condition, e.g. empty username/password.
  ///
  /// @returns True if the credential is valid, false otherwise.
  bool is_valid() const;

 protected:
  /// @cond FIREBASE_APP_INTERNAL
  friend class Auth;
  friend class User;

  /// Platform-specific implementation.
  /// For example, FIRAuthCredential* on iOS.
  void* impl_;

  // If not kAuthErrorNone, then use this error code and string to override
  // whatever error we would normally return when trying to sign-in with this
  // credential.
  AuthError error_code_;
  std::string error_message_;
  /// @endcond
};

/// @brief Use email and password to authenticate.
///
/// Allows developers to use the email and password credentials as they could
/// other auth providers.  For example, this can be used to change passwords,
/// log in, etc.
class EmailAuthProvider {
 public:
  /// Generate a credential from the given email and password.
  ///
  /// @param email E-mail to generate the credential from.
  /// @param password Password to use for the new credential.
  ///
  /// @returns New Credential.
  static Credential GetCredential(const char* email, const char* password);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use an access token provided by Facebook to authenticate.
class FacebookAuthProvider {
 public:
  /// Generate a credential from the given Facebook token.
  ///
  /// @param access_token Facebook token to generate the credential from.
  ///
  /// @returns New Credential.
  static Credential GetCredential(const char* access_token);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief GameCenter (Apple) auth provider
class GameCenterAuthProvider {
 public:
  /// Generate a credential from GameCenter for the current user.
  ///
  /// @return a Future that will be fulfilled with the resulting credential.
  static Future<Credential> GetCredential();

  /// Get the result of the most recent GetCredential() call.
  ///
  /// @return an object which can be used to retrieve the Credential.
  static Future<Credential> GetCredentialLastResult();

  /// Tests to see if the current user is signed in to GameCenter.
  ///
  /// @return true if the user is signed in, false otherwise.
  static bool IsPlayerAuthenticated();

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use an access token provided by GitHub to authenticate.
class GitHubAuthProvider {
 public:
  /// Generate a credential from the given GitHub token.
  ///
  /// @param token The GitHub OAuth access token.
  ///
  /// @returns New Credential.
  static Credential GetCredential(const char* token);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use an ID token and access token provided by Google to authenticate.
class GoogleAuthProvider {
 public:
  /// Generate a credential from the given Google ID token and/or access token.
  ///
  /// @param id_token Google Sign-In ID token.
  /// @param access_token Google Sign-In access token.
  ///
  /// @returns New Credential.
  static Credential GetCredential(const char* id_token,
                                  const char* access_token);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use an access token provided by Microsoft to authenticate.
class MicrosoftAuthProvider {
 public:
  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief OAuth2.0+UserInfo auth provider (OIDC compliant and non-compliant).
class OAuthProvider {
 public:
  /// Generate a credential for an OAuth2 provider.
  ///
  /// @param provider_id Name of the OAuth2 provider
  ///    TODO(jsanmiya) add examples.
  /// @param id_token The authentication token (OIDC only).
  /// @param access_token TODO(jsanmiya) add explanation (currently missing
  ///    from Android and iOS implementations).
  static Credential GetCredential(const char* provider_id, const char* id_token,
                                  const char* access_token);

  /// Generate a credential for an OAuth2 provider.
  ///
  /// @param provider_id Name of the OAuth2 provider.
  /// @param id_token The authentication token (OIDC only).
  /// @param raw_nonce The raw nonce associated with the Auth credential being
  /// created.
  /// @param access_token The access token associated with the Auth credential
  /// to be created, if available.  This value may be null.
  static Credential GetCredential(const char* provider_id, const char* id_token,
                                  const char* raw_nonce,
                                  const char* access_token);
};

/// @brief Use phone number text messages to authenticate.
///
/// Allows developers to use the phone number and SMS verification codes
/// to authenticate a user on a mobile device.
///
/// This class is not supported on tvOS and Desktop platforms.
///
/// The verification flow results in a Credential that can be used to,
/// * Sign in to an existing phone number account/sign up with a new
///   phone number
/// * Link a phone number to a current user. This provider will be added to
///   the user.
/// * Update a phone number on an existing user.
/// * Re-authenticate an existing user. This may be needed when a sensitive
///   operation requires the user to be recently logged in.
///
/// Possible verification flows:
/// (1) User manually enters verification code.
/// @if cpp_examples
///     - App calls @ref VerifyPhoneNumber.
///     - Web verification page is displayed to user where they may need to
///       solve a CAPTCHA. [iOS only].
///     - Auth server sends the verification code via SMS to the provided
///       phone number. App receives verification id via Listener::OnCodeSent().
///     - User receives SMS and enters verification code in app's GUI.
///     - App uses user's verification code to call
///       @ref PhoneAuthProvider::GetCredential.
/// @endif
/// <SWIG>
/// @if swig_examples
///     - App calls @ref VerifyPhoneNumber.
///     - Web verification page is displayed to user where they may need to
///       solve a CAPTCHA. [iOS only].
///     - Auth server sends the verification code via SMS to the provided
///       phone number. App receives verification id via @ref CodeSent.
///     - User receives SMS and enters verification code in app's GUI.
///     - App uses user's verification code to call
///       @ref PhoneAuthProvider::GetCredential.
/// @endif
/// </SWIG>
///
/// (2) SMS is automatically retrieved (Android only).
///     - App calls @ref VerifyPhoneNumber with `timeout_ms` > 0.
///     - Auth server sends the verification code via SMS to the provided
///       phone number.
///     - SMS arrives and is automatically retrieved by the operating system.
///       Credential is automatically created and passed to the app via
///       @if cpp_examples
///       Listener::OnVerificationCompleted().
///       @endif
///       <SWIG>
///       @if swig_examples
///       @ref VerificationCompleted.
///       @endif
///       </SWIG>
///
/// (3) Phone number is instantly verified (Android only).
///     - App calls @ref VerifyPhoneNumber.
///     - The operating system validates the phone number without having to
///       send an SMS. Credential is automatically created and passed to
///       the app via
///       @if cpp_examples
///       Listener::OnVerificationCompleted().
///       @endif
///       <SWIG>
///       @if swig_examples
///       @ref VerificationCompleted.
///       @endif
///       </SWIG>
///
/// @if cpp_examples
/// All three flows can be handled with the example code below.
/// The flow is complete when PhoneVerifier::credential() returns non-NULL.
///
/// @code{.cpp}
/// class PhoneVerifier : public PhoneAuthProvider::Listener {
///  public:
///   PhoneVerifier(const char* phone_number,
///                 PhoneAuthProvider* phone_auth_provider)
///     : display_message_("Sending SMS with verification code"),
///       display_verification_code_input_box_(false),
///       display_resend_sms_button_(false),
///       phone_auth_provider_(phone_auth_provider),
///       phone_number_(phone_number) {
///     SendSms();
///   }
///
///   ~PhoneVerifier() override {}
///
///   void OnVerificationCompleted(Credential credential) override {
///     // Grab `mutex_` for the scope of `lock`. Callbacks can be called on
///     // other threads, so this mutex ensures data access is atomic.
///     MutexLock lock(mutex_);
///     credential_ = credential;
///   }
///
///   void OnVerificationFailed(const std::string& error) override {
///     MutexLock lock(mutex_);
///     display_message_ = "Verification failed with error: " + error;
///   }
///
///   void OnCodeSent(const std::string& verification_id,
///                   const PhoneAuthProvider::ForceResendingToken&
///                       force_resending_token) override {
///     MutexLock lock(mutex_);
///     verification_id_ = verification_id;
///     force_resending_token_ = force_resending_token;
///
///     display_verification_code_input_box_ = true;
///     display_message_ = "Waiting for SMS";
///   }
///
///   void OnCodeAutoRetrievalTimeOut(
///       const std::string& verification_id) override {
///     MutexLock lock(mutex_);
///     display_resend_sms_button_ = true;
///   }
///
///   // Draw the verification GUI on screen and process input events.
///   void Draw() {
///     MutexLock lock(mutex_);
///
///     // Draw an informative message describing what's currently happening.
///     ShowTextBox(display_message_.c_str());
///
///     // Once the time out expires, display a button to resend the SMS.
///     // If the button is pressed, call VerifyPhoneNumber again using the
///     // force_resending_token_.
///     if (display_resend_sms_button_ && !verification_id_.empty()) {
///       const bool resend_sms = ShowTextButton("Resend SMS");
///       if (resend_sms) {
///         SendSms();
///       }
///     }
///
///     // Once the SMS has been sent, allow the user to enter the SMS
///     // verification code into a text box. When the user has completed
///     // entering it, call GetCredential() to complete the flow.
///     if (display_verification_code_input_box_) {
///       const std::string verification_code =
///         ShowInputBox("Verification code");
///       if (!verification_code.empty()) {
///         credential_ = phone_auth_provider_->GetCredential(
///             verification_id_.c_str(), verification_code.c_str());
///       }
///     }
///   }
///
///   // The phone number verification flow is complete when this returns
///   // non-NULL.
///   Credential* credential() {
///     MutexLock lock(mutex_);
///     return credential_.is_valid() ? &credential_ : nullptr;
///   }
///
///  private:
///   void SendSms() {
///     static const uint32_t kAutoVerifyTimeOut = 2000;
///     MutexLock lock(mutex_);
///     phone_auth_provider_->VerifyPhoneNumber(
///         phone_number_.c_str(), kAutoVerifyTimeOut, &force_resending_token_,
///         this);
///     display_resend_sms_button_ = false;
///   }
///
///   // GUI-related variables.
///   std::string display_message_;
///   bool display_verification_code_input_box_;
///   bool display_resend_sms_button_;
///
///   // Phone flow related variables.
///   PhoneAuthProvider* phone_auth_provider_;
///   std::string phone_number_;
///   std::string verification_id_;
///   PhoneAuthProvider::ForceResendingToken force_resending_token_;
///   Credential credential_;
///
///   // Callbacks can be called on other threads, so guard them with a mutex.
///   Mutex mutex_;
/// };
/// @endcode
/// @endif
class PhoneAuthProvider {
 public:
  /// @brief Token to maintain current phone number verification session.
  /// Acquired via @ref Listener::OnCodeSent. Used in @ref VerifyPhoneNumber.
  class ForceResendingToken {
   public:
    /// This token will be invalid until it is assigned a value sent via
    /// @ref Listener::OnCodeSent. It can still be passed into
    /// @ref VerifyPhoneNumber, but it will be ignored.
    ForceResendingToken();

    /// Make `this` token refer to the same phone session as `rhs`.
    ForceResendingToken(const ForceResendingToken& rhs);

    /// Releases internal resources when destructing.
    ~ForceResendingToken();

    /// Make `this` token refer to the same phone session as `rhs`.
    ForceResendingToken& operator=(const ForceResendingToken& rhs);

    /// Return true if `rhs` is refers to the same phone number session as
    /// `this`.
    bool operator==(const ForceResendingToken& rhs) const;

    /// Return true if `rhs` is refers to a different phone number session as
    /// `this`.
    bool operator!=(const ForceResendingToken& rhs) const;

   private:
    friend class JniAuthPhoneListener;
    friend class PhoneAuthProvider;
    ForceResendingTokenData* data_;
  };

  /// @brief Receive callbacks from @ref VerifyPhoneNumber events.
  ///
  /// Please see @ref PhoneAuthProvider for a sample implementation.
  class Listener {
   public:
    Listener();
    virtual ~Listener();

    /// @brief Phone number auto-verification succeeded.
    ///
    /// Called when,
    ///  - auto-sms-retrieval has succeeded--flow (2) in @ref PhoneAuthProvider
    ///  - instant validation has succeeded--flow (3) in @ref PhoneAuthProvider
    ///
    /// @note This callback is never called on iOS, since iOS does not have
    ///    auto-validation. It is always called immediately in the stub desktop
    ///    implementation, however, since it fakes immediate success.
    ///
    /// @param[in] credential The completed credential from the phone number
    ///    verification flow.
    virtual void OnVerificationCompleted(Credential credential) = 0;

    /// @brief Phone number verification failed with an error.
    ///
    /// Called when and error occurred doing phone number authentication.
    /// For example,
    ///  - quota exceeded
    ///  - unknown phone number format
    ///
    /// @param[in] error A description of the failure.
    virtual void OnVerificationFailed(const std::string& error) = 0;

    /// @brief SMS message with verification code sent to phone number.
    ///
    /// Called immediately after Auth server sends a verification SMS.
    /// Once receiving this, you can allow users to manually input the
    /// verification code (even if you're also performing auto-verification).
    /// For user manual input case, get the SMS verification code from the user
    /// and then call @ref GetCredential with the user's code.
    ///
    /// @param[in] verification_id Pass to @ref GetCredential along with the
    ///   user-input verification code to complete the phone number verification
    ///   flow.
    /// @param[in] force_resending_token If the user requests that another SMS
    ///    message be sent, use this when you recall @ref VerifyPhoneNumber.
    virtual void OnCodeSent(const std::string& verification_id,
                            const ForceResendingToken& force_resending_token);

    /// @brief The timeout specified in @ref VerifyPhoneNumber has expired.
    ///
    /// Called once `auto_verify_time_out_ms` has passed.
    /// If using auto SMS retrieval, you can choose to block the UI (do not
    /// allow manual input of the verification code) until timeout is hit.
    ///
    /// @note This callback is called immediately on iOS, since iOS does not
    ///    have auto-validation.
    ///
    /// @param[in] verification_id Identify the transaction that has timed out.
    virtual void OnCodeAutoRetrievalTimeOut(const std::string& verification_id);

   private:
    friend class PhoneAuthProvider;

    /// Back-pointer to the data of the PhoneAuthProvider that
    /// @ref VerifyPhoneNumber was called with. Used internally.
    PhoneListenerData* data_;
  };

  /// Maximum value of `auto_verify_time_out_ms` in @ref VerifyPhoneNumber.
  /// Larger values will be clamped.
  ///
  /// @deprecated This value is no longer used to clamp
  /// `auto_verify_time_out_ms` in VerifyPhoneNumber. The range is
  /// determined by the underlying SDK, ex. <a
  /// href="/docs/reference/android/com/google/firebase/auth/PhoneAuthOptions.Builder"><code>PhoneAuthOptions.Build</code>
  /// in Android SDK</a>
  static const uint32_t kMaxTimeoutMs;

  /// Start the phone number authentication operation.
  ///
  /// @param[in] phone_number The phone number identifier supplied by the user.
  ///    Its format is normalized on the server, so it can be in any format
  ///    here.
  /// @param[in] auto_verify_time_out_ms The time out for SMS auto retrieval, in
  ///    miliseconds. Currently SMS auto retrieval is only supported on Android.
  ///    If 0, do not do SMS auto retrieval.
  ///    If positive, try to auto-retrieve the SMS verification code.
  ///    When the time out is exceeded, listener->OnCodeAutoRetrievalTimeOut()
  ///    is called.
  /// @param[in] force_resending_token If NULL, assume this is a new phone
  ///    number to verify. If not-NULL, bypass the verification session deduping
  ///    and force resending a new SMS.
  ///    This token is received in @ref Listener::OnCodeSent.
  ///    This should only be used when the user presses a Resend SMS button.
  /// @param[in,out] listener Class that receives notification whenever an SMS
  ///    verification event occurs. See sample code at top of class.
  void VerifyPhoneNumber(const char* phone_number,
                         uint32_t auto_verify_time_out_ms,
                         const ForceResendingToken* force_resending_token,
                         Listener* listener);

  /// Generate a credential for the given phone number.
  ///
  /// @param[in] verification_id The id returned when sending the verification
  ///    code. Sent to the caller via @ref Listener::OnCodeSent.
  /// @param[in] verification_code The verification code supplied by the user,
  ///    most likely by a GUI where the user manually enters the code
  ///    received in the SMS sent by @ref VerifyPhoneNumber.
  ///
  /// @returns New Credential.
  Credential GetCredential(const char* verification_id,
                           const char* verification_code);

  /// Return the PhoneAuthProvider for the specified `auth`.
  ///
  /// @param[in] auth The Auth session for which we want to get a
  ///    PhoneAuthProvider.
  static PhoneAuthProvider& GetInstance(Auth* auth);

  /// The string used to identify this provider.
  static const char* const kProviderId;

 private:
  friend struct AuthData;
  friend class JniAuthPhoneListener;

  // Use @ref GetInstance to access the PhoneAuthProvider.
  PhoneAuthProvider();

  // The PhoneAuthProvider is owned by the Auth class.
  ~PhoneAuthProvider();

  PhoneAuthProviderData* data_;
};

/// @brief Use a server auth code provided by Google Play Games to authenticate.
class PlayGamesAuthProvider {
 public:
  /// Generate a credential from the given Server Auth Code.
  ///
  /// @param server_auth_code Play Games Sign in Server Auth Code.
  ///
  /// @return New Credential.
  static Credential GetCredential(const char* server_auth_code);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use a token and secret provided by Twitter to authenticate.
class TwitterAuthProvider {
 public:
  /// Generate a credential from the given Twitter token and password.
  ///
  /// @param token The Twitter OAuth token.
  /// @param secret The Twitter OAuth secret.
  ///
  /// @return New Credential.
  static Credential GetCredential(const char* token, const char* secret);

  /// The string used to identify this provider.
  static const char* const kProviderId;
};

/// @brief Use an access token provided by Yahoo to authenticate.
class YahooAuthProvider {
 public:
  /// The string used to identify this provider.
  static const char* const kProviderId;
};

}  // namespace auth
}  // namespace firebase

#endif  // FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_CREDENTIAL_H_
