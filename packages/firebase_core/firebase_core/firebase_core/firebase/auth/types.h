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

#ifndef FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_TYPES_H_
#define FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_TYPES_H_

#include <map>
#include <string>
#include <vector>

namespace firebase {
namespace auth {

/// All possible error codes from asynchronous calls.
/// For error details,
/// @if cpp_examples
/// call Future::ErrorMessage().
/// @endif
/// <SWIG>
/// @if swig_examples
/// use the FirebaseException.Message property.
/// @endif
/// </SWIG>
enum AuthError {
  /// Success.
  kAuthErrorNone = 0,

  /// Function will be implemented in a later revision of the API.
  kAuthErrorUnimplemented = -1,

  /// This indicates an internal error.
  /// Common error code for all API Methods.
  kAuthErrorFailure = 1,

  /// Indicates a validation error with the custom token.
  /// This error originates from "bring your own auth" methods.
  kAuthErrorInvalidCustomToken,

  /// Indicates the service account and the API key belong to different
  /// projects.
  /// Caused by "Bring your own auth" methods.
  kAuthErrorCustomTokenMismatch,

  /// Indicates the IDP token or requestUri is invalid.
  /// Caused by "Sign in with credential" methods.
  kAuthErrorInvalidCredential,

  /// Indicates the user’s account is disabled on the server.
  /// Caused by "Sign in with credential" methods.
  kAuthErrorUserDisabled,

  /// Indicates an account already exists with the same email address but using
  /// different sign-in credentials. Account linking is required.
  /// Caused by "Sign in with credential" methods.
  kAuthErrorAccountExistsWithDifferentCredentials,

  /// Indicates the administrator disabled sign in with the specified identity
  /// provider.
  /// Caused by "Set account info" methods.
  kAuthErrorOperationNotAllowed,

  /// Indicates the email used to attempt a sign up is already in use.
  /// Caused by "Set account info" methods.
  kAuthErrorEmailAlreadyInUse,

  /// Indicates the user has attemped to change email or password more than 5
  /// minutes after signing in, and will need to refresh the credentials.
  /// Caused by "Set account info" methods.
  kAuthErrorRequiresRecentLogin,

  /// Indicates an attempt to link with a credential that has already been
  /// linked with a different Firebase account.
  /// Caused by "Set account info" methods.
  kAuthErrorCredentialAlreadyInUse,

  /// Indicates an invalid email address.
  /// Caused by "Sign in with password" methods.
  kAuthErrorInvalidEmail,

  /// Indicates the user attempted sign in with a wrong password.
  /// Caused by "Sign in with password" methods.
  kAuthErrorWrongPassword,

  /// Indicates that too many requests were made to a server method.
  /// Common error code for all API methods.
  kAuthErrorTooManyRequests,

  /// Indicates the user account was not found.
  /// Send password request email error code.
  /// Common error code for all API methods.
  kAuthErrorUserNotFound,

  /// Indicates an attempt to link a provider to which the account is already
  /// linked.
  /// Caused by "Link credential" methods.
  kAuthErrorProviderAlreadyLinked,

  /// Indicates an attempt to unlink a provider that is not linked.
  /// Caused by "Link credential" methods.
  kAuthErrorNoSuchProvider,

  /// Indicates user's saved auth credential is invalid, the user needs to sign
  /// in again.
  /// Caused by requests with an STS id token.
  kAuthErrorInvalidUserToken,

  /// Indicates the saved token has expired.
  /// For example, the user may have changed account password on another device.
  /// The user needs to sign in again on the device that made this request.
  /// Caused by requests with an STS id token.
  kAuthErrorUserTokenExpired,

  /// Indicates a network error occurred (such as a timeout, interrupted
  /// connection, or unreachable host). These types of errors are often
  /// recoverable with a retry.
  /// Common error code for all API Methods.
  kAuthErrorNetworkRequestFailed,

  /// Indicates an invalid API key was supplied in the request.
  /// For Android these should no longer occur (as of 2016 v3).
  /// Common error code for all API Methods.
  kAuthErrorInvalidApiKey,

  /// Indicates the App is not authorized to use Firebase Authentication with
  /// the provided API Key.
  /// Common error code for all API Methods.
  /// On Android this error should no longer occur (as of 2016 v3).
  /// Common error code for all API Methods.
  kAuthErrorAppNotAuthorized,

  /// Indicates that an attempt was made to reauthenticate with a user which is
  /// not the current user.
  kAuthErrorUserMismatch,

  /// Indicates an attempt to set a password that is considered too weak.
  kAuthErrorWeakPassword,

  /// Internal api usage error code when there is no signed-in user
  /// and getAccessToken is called.
  ///
  /// @note This error is only reported on Android.
  kAuthErrorNoSignedInUser,

  /// This can happen when certain methods on App are performed, when the auth
  /// API is not loaded.
  ///
  /// @note This error is only reported on Android.
  kAuthErrorApiNotAvailable,

  /// Indicates the out-of-band authentication code is expired.
  kAuthErrorExpiredActionCode,

  /// Indicates the out-of-band authentication code is invalid.
  kAuthErrorInvalidActionCode,

  /// Indicates that there are invalid parameters in the payload during a
  /// "send password reset email" attempt.
  kAuthErrorInvalidMessagePayload,

  /// Indicates that an invalid phone number was provided.
  /// This is caused when the user is entering a phone number for verification.
  kAuthErrorInvalidPhoneNumber,

  /// Indicates that a phone number was not provided during phone number
  /// verification.
  ///
  /// @note This error is iOS-specific.
  kAuthErrorMissingPhoneNumber,

  /// Indicates that the recipient email is invalid.
  kAuthErrorInvalidRecipientEmail,

  /// Indicates that the sender email is invalid during a "send password reset
  /// email" attempt.
  kAuthErrorInvalidSender,

  /// Indicates that an invalid verification code was used in the
  /// verifyPhoneNumber request.
  kAuthErrorInvalidVerificationCode,

  /// Indicates that an invalid verification ID was used in the
  /// verifyPhoneNumber request.
  kAuthErrorInvalidVerificationId,

  /// Indicates that the phone auth credential was created with an empty
  /// verification code.
  kAuthErrorMissingVerificationCode,

  /// Indicates that the phone auth credential was created with an empty
  /// verification ID.
  kAuthErrorMissingVerificationId,

  /// Indicates that an email address was expected but one was not provided.
  kAuthErrorMissingEmail,

  /// Represents the error code for when an application attempts to create an
  /// email/password account with an empty/null password field.
  ///
  /// @note This error is only reported on Android.
  kAuthErrorMissingPassword,

  /// Indicates that the project's quota for this operation (SMS messages,
  /// sign-ins, account creation) has been exceeded. Try again later.
  kAuthErrorQuotaExceeded,

  /// Thrown when one or more of the credentials passed to a method fail to
  /// identify and/or authenticate the user subject of that operation. Inspect
  /// the error message to find out the specific cause.
  /// @note This error is only reported on Android.
  kAuthErrorRetryPhoneAuth,

  /// Indicates that the SMS code has expired.
  kAuthErrorSessionExpired,

  /// Indicates that the app could not be verified by Firebase during phone
  /// number authentication.
  ///
  /// @note This error is iOS-specific.
  kAuthErrorAppNotVerified,

  /// Indicates a general failure during the app verification flow.
  ///
  /// @note This error is iOS-specific.
  kAuthErrorAppVerificationFailed,

  /// Indicates that the reCAPTCHA token is not valid.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorCaptchaCheckFailed,

  /// Indicates that an invalid APNS device token was used in the verifyClient
  /// request.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorInvalidAppCredential,

  /// Indicates that the APNS device token is missing in the verifyClient
  /// request.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorMissingAppCredential,

  /// Indicates that the clientID used to invoke a web flow is invalid.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorInvalidClientId,

  /// Indicates that the domain specified in the continue URI is not valid.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorInvalidContinueUri,

  /// Indicates that a continue URI was not provided in a request to the backend
  /// which requires one.
  kAuthErrorMissingContinueUri,

  /// Indicates an error occurred while attempting to access the keychain.
  /// Common error code for all API Methods.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorKeychainError,

  /// Indicates that the APNs device token could not be obtained. The app may
  /// not have set up remote notification correctly, or may have failed to
  /// forward the APNs device token to FIRAuth if app delegate swizzling is
  /// disabled.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorMissingAppToken,

  /// Indicates that the iOS bundle ID is missing when an iOS App Store ID is
  /// provided.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorMissingIosBundleId,

  /// Indicates that the app fails to forward remote notification to FIRAuth.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorNotificationNotForwarded,

  /// Indicates that the domain specified in the continue URL is not white-
  /// listed in the Firebase console.
  ///
  /// @note This error is iOS and tvOS-specific.
  kAuthErrorUnauthorizedDomain,

  /// Indicates that an attempt was made to present a new web context while one
  /// was already being presented.
  kAuthErrorWebContextAlreadyPresented,

  /// Indicates that the URL presentation was cancelled prematurely by the user.
  kAuthErrorWebContextCancelled,

  /// Indicates that Dynamic Links in the Firebase Console is not activated.
  kAuthErrorDynamicLinkNotActivated,

  /// Indicates that the operation was cancelled.
  kAuthErrorCancelled,

  /// Indicates that the provider id given for the web operation is invalid.
  kAuthErrorInvalidProviderId,

  /// Indicates that an internal error occurred during a web operation.
  kAuthErrorWebInternalError,

  /// Indicates that 3rd party cookies or data are disabled, or that there was
  /// a problem with the browser.
  kAuthErrorWebStorateUnsupported,

  /// Indicates that the provided tenant ID does not match the Auth instance's
  /// tenant ID.
  kAuthErrorTenantIdMismatch,

  /// Indicates that a request was made to the backend with an associated tenant
  /// ID for an operation that does not support multi-tenancy.
  kAuthErrorUnsupportedTenantOperation,

  /// Indicates that an FDL domain used for an out of band code flow is either
  /// not configured or is unauthorized for the current project.
  kAuthErrorInvalidLinkDomain,

  /// Indicates that credential related request data is invalid. This can occur
  /// when there is a project number mismatch (sessionInfo, spatula header,
  /// temporary proof),
  /// an incorrect temporary proof phone number, or during game center sign in
  /// when the user is
  /// already signed into a different game center account.
  kAuthErrorRejectedCredential,

  /// Indicates that the phone number provided in the MFA sign in flow to be
  /// verified does not correspond to a phone second factor for the user.
  kAuthErrorPhoneNumberNotFound,

  /// Indicates that a request was made to the backend with an invalid tenant
  /// ID.
  kAuthErrorInvalidTenantId,

  /// Indicates that a request was made to the backend without a valid client
  /// identifier.
  kAuthErrorMissingClientIdentifier,

  /// Indicates that a second factor challenge request was made without proof of
  /// a successful first factor sign-in.
  kAuthErrorMissingMultiFactorSession,

  /// Indicates that a second factor challenge request was made where a second
  /// factor identifier was not provided.
  kAuthErrorMissingMultiFactorInfo,

  /// Indicates that a second factor challenge request was made containing an
  /// invalid proof of first factor sign-in.
  kAuthErrorInvalidMultiFactorSession,

  /// Indicates that the user does not have a second factor matching the
  /// provided identifier.
  kAuthErrorMultiFactorInfoNotFound,

  /// Indicates that a request was made that is restricted to administrators
  /// only.
  kAuthErrorAdminRestrictedOperation,

  /// Indicates that the user's email must be verified to perform that request.
  kAuthErrorUnverifiedEmail,

  /// Indicates that the user is trying to enroll a second factor that already
  /// exists on their account.
  kAuthErrorSecondFactorAlreadyEnrolled,

  /// Indicates that the user has reached the maximum number of allowed second
  /// factors and is attempting to enroll another one.
  kAuthErrorMaximumSecondFactorCountExceeded,

  /// Indicates that a user either attempted to enroll in 2FA with an
  /// unsupported first factor or is enrolled and attempts a first factor sign
  /// in that is not supported for 2FA users.
  kAuthErrorUnsupportedFirstFactor,

  /// Indicates that a second factor users attempted to change their email with
  /// updateEmail instead of verifyBeforeUpdateEmail.
  kAuthErrorEmailChangeNeedsVerification,

#ifdef INTERNAL_EXPERIMENTAL
  /// Indicates that the provided event handler is null or invalid.
  kAuthErrorInvalidEventHandler,

  /// Indicates that the federated provider is busy with a previous
  /// authorization request. Try again when the previous authorization request
  /// completes.
  kAuthErrorFederatedProviderAreadyInUse,

  /// Indicates that one or more fields of the provided AuthenticatedUserData
  /// are invalid.
  kAuthErrorInvalidAuthenticatedUserData,

  /// Indicates that an error occurred during a Federated Auth UI Flow when the
  /// user was prompted to enter their credentials.
  kAuthErrorFederatedSignInUserInteractionFailure,

  /// Indicates that a request was made with a missing or invalid nonce.
  /// This can happen if the hash of the provided raw nonce did not match the
  /// hashed nonce in the OIDC ID token payload.
  kAuthErrorMissingOrInvalidNonce,

  /// Indicates that the user did not authorize the application during Generic
  /// IDP sign-in.
  kAuthErrorUserCancelled,

  /// Indicates that a request was made to an unsupported backend endpoint in
  /// passthrough mode.
  kAuthErrorUnsupportedPassthroughOperation,

  /// Indicates that a token refresh was requested, but neither a refresh token
  /// nor a custom token provider is available.
  kAuthErrorTokenRefreshUnavailable,

#endif  // INTERNAL_EXEPERIMENTAL
};

/// @brief Contains information required to authenticate with a third party
/// provider.
struct FederatedProviderData {
  /// @brief contains the id of the provider to be used during sign-in, link, or
  /// reauthentication requests.
  std::string provider_id;
};

/// @brief Contains information to identify an OAuth povider.
struct FederatedOAuthProviderData : FederatedProviderData {
  /// Initailizes an empty provider data structure.
  FederatedOAuthProviderData() {}

  /// Initializes the provider data structure with a provider id.
  explicit FederatedOAuthProviderData(const std::string& provider) {
    this->provider_id = provider;
  }

#ifndef SWIG
  /// @brief Initializes the provider data structure with the specified provider
  /// id, scopes and custom parameters.
  FederatedOAuthProviderData(
      const std::string& provider, std::vector<std::string> scopes,
      std::map<std::string, std::string> custom_parameters) {
    this->provider_id = provider;
    this->scopes = scopes;
    this->custom_parameters = custom_parameters;
  }
#endif

  /// OAuth parmeters which specify which rights of access are being requested.
  std::vector<std::string> scopes;

  /// OAuth parameters which are provided to the federated provider service.
  std::map<std::string, std::string> custom_parameters;
};

}  // namespace auth
}  // namespace firebase

#endif  // FIREBASE_AUTH_SRC_INCLUDE_FIREBASE_AUTH_TYPES_H_
