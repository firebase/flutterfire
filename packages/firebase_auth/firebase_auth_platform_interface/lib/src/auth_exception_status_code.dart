/// The codes of the auth exceptions.
enum AuthExceptionStatusCode {
  /// Used if the email address is not valid.
  invalidEmail,

  /// Used if the user corresponding to the given email has been disabled.
  userDisabled,

  /// Used if there is no user corresponding to the given email.
  userNotFound,

  /// Used if the password is invalid for the given email, or the account corresponding to the email does not have a password set.
  wrongPassword,

  /// Used if the Firebase Authentication quota is reached.
  tooManyRequests,

  /// Used if specific auth provider is not enabled.
  operationNotAllowed,

  /// Used if the email exists for multiple Firebase user's providers.
  accountExistsWithDifferentCredential,

  /// Used if the request failed due to network issues.
  networkRequestFailed,

  /// Used if a user being created already exists.
  emailAlreadyInUse,

  /// Used if the request to create a user has a weak password.
  weakPassword,

  /// Used if the phone verification fails with an invalid phone number.
  invalidPhoneNumber,

  /// Used if the verification ID used to create the phone auth credential is invalid.
  invalidVerificationId,

  /// Used if the supplied credentials do not correspond to the previously signed in user.
  userMismatch,

  /// Used if the user was not linked to an account with the given provider.
  noSuchProvider,

  /// Used if there is no user currently signed in.
  noCurrentUser,

  /// Used if the status is unknown.
  unknown
}
