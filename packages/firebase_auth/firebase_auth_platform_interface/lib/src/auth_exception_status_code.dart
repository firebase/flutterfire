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

  /// Used if the status is undefined.
  undefined
}
