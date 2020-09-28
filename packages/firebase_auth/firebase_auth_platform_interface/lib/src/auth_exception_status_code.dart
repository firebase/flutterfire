// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The codes of the auth exceptions.
enum AuthExceptionStatusCode {
  /// Thrown if the email address is not valid.
  invalidEmail,

  /// Thrown if the user corresponding to the given email has been disabled.
  userDisabled,

  /// Thrown if there is no user corresponding to the given email.
  userNotFound,

  /// Thrown if the password is invalid for the given email, or the account corresponding to the email does not have a password set.
  wrongPassword,

  /// Thrown if the Firebase Authentication quota is reached.
  tooManyRequests,

  /// Thrown if specific auth provider is not enabled.
  operationNotAllowed,

  /// Thrown if the email exists for multiple Firebase user's providers.
  accountExistsWithDifferentCredential,

  /// Thrown if the request failed due to network issues.
  networkRequestFailed,

  /// Thrown if a user being created already exists.
  emailAlreadyInUse,

  /// Thrown if the request to create a user has a weak password.
  weakPassword,

  /// Thrown if the phone verification fails with an invalid phone number.
  invalidPhoneNumber,

  /// Thrown if the verification ID used to create the phone auth credential is invalid.
  invalidVerificationId,

  /// Thrown if the supplied credentials do not correspond to the previously signed in user.
  userMismatch,

  /// Thrown if the user does not have this provider linked or when the provider ID given does not exist.
  noSuchProvider,

  /// Thrown if there is no user currently signed in.
  noCurrentUser,

  /// Thrown if the supplied action code has expired.
  expiredActionCode,

  /// Thrown if the supplied action code is not a valid format.
  invalidActionCode,

  /// Thrown if the custom token is for a different Firebase App.
  customTokenMismatch,

  /// Thrown if the custom token format is incorrect.
  invalidCustomToken,

  /// Thrown if the credential is a [PhoneAuthProvider.credential] and the verification
  /// code of the credential is not valid.
  invalidVerificationCode,

  /// Thrown if the credential is malformed or has expired.
  invalidCredential,

  ///  if the user's last sign-in time does not meet the security threshold.
  /// 
  /// Use [User.reauthenticateWithCredential] to resolve. This does not apply if the user is anonymous.
  requiresRecentLogin,

  /// Thrown if the provider has already been linked to the user.
  /// 
  /// This error is thrown even if this is not the same provider's account that is currently linked to the user.
  providerAlreadyLinked,

  /// Thrown if the provider's credential is not valid.
  /// 
  /// This can happen if it has already expired when calling link, or if it used
  /// invalid token(s). See the Firebase documentation for your provider, and make
  /// sure you pass in the correct parameters to the credential method.
  credentialAlreadyInUse,

  /// Thrown if the status is unknown.
  unknown,
}
