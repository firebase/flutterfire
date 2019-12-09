// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Represents a user.
class FirebaseUser extends UserInfo {
  FirebaseUser._(PlatformUser data, FirebaseApp app)
      : providerData = data.providerData
            .map<UserInfo>((PlatformUserInfo item) => UserInfo._(item, app))
            .toList(),
        _metadata = FirebaseUserMetadata._(data),
        _userData = data,
        super._(data, app);

  final PlatformUser _userData;
  final List<UserInfo> providerData;
  final FirebaseUserMetadata _metadata;

  // Returns true if the user is anonymous; that is, the user account was
  // created with signInAnonymously() and has not been linked to another
  // account.
  FirebaseUserMetadata get metadata => _metadata;

  bool get isAnonymous => _userData.isAnonymous;

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _userData.isEmailVerified;

  /// Obtains the id token result for the current user, forcing a [refresh] if desired.
  ///
  /// Useful when authenticating against your own backend. Use our server
  /// SDKs or follow the official documentation to securely verify the
  /// integrity and validity of this token.
  ///
  /// Completes with an error if the user is signed out.
  Future<IdTokenResult> getIdToken({bool refresh = false}) async {
    final PlatformIdTokenResult result =
        await FirebaseAuthPlatform.instance.getIdToken(_app.name, refresh);
    return IdTokenResult._(result);
  }

  /// Associates a user account from a third-party identity provider with this
  /// user and returns additional identity provider data.
  ///
  /// This allows the user to sign in to this account in the future with
  /// the given account.
  ///
  /// Errors:
  ///
  ///  * `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///  * `ERROR_INVALID_CREDENTIAL` - If the credential is malformed or has expired.
  ///  * `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///  * `ERROR_CREDENTIAL_ALREADY_IN_USE` - If the account is already in use by a different account, e.g. with phone auth.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///  * `ERROR_PROVIDER_ALREADY_LINKED` - If the current user already has an account of this type linked.
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that this type of account is not enabled.
  ///  * `ERROR_INVALID_ACTION_CODE` - If the action code in the link is malformed, expired, or has already been used.
  ///       This can only occur when using [EmailAuthProvider.getCredentialWithLink] to obtain the credential.
  Future<AuthResult> linkWithCredential(AuthCredential credential) async {
    assert(credential != null);
    final PlatformAuthResult platformResult = await FirebaseAuthPlatform
        .instance
        .linkWithCredential(_app.name, credential);
    final AuthResult result = AuthResult._(platformResult, _app);
    return result;
  }

  /// Initiates email verification for the user.
  Future<void> sendEmailVerification() {
    return FirebaseAuthPlatform.instance.sendEmailVerification(_app.name);
  }

  /// Manually refreshes the data of the current user (for example,
  /// attached providers, display name, and so on).
  Future<void> reload() {
    return FirebaseAuthPlatform.instance.reload(_app.name);
  }

  /// Deletes the current user (also signs out the user).
  ///
  /// Errors:
  ///
  ///  * `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///  * `ERROR_INVALID_CREDENTIAL` - If the credential is malformed or has expired.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> delete() {
    return FirebaseAuthPlatform.instance.delete(_app.name);
  }

  /// Updates the email address of the user.
  ///
  /// The original email address recipient will receive an email that allows
  /// them to revoke the email address change, in order to protect them
  /// from account hijacking.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_CREDENTIAL` - If the email address is malformed.
  ///  * `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///  * `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updateEmail(String email) {
    assert(email != null);
    return FirebaseAuthPlatform.instance.updateEmail(_app.name, email);
  }

  /// Updates the phone number of the user.
  ///
  /// The new phone number credential corresponding to the phone number
  /// to be added to the Firebase account, if a phone number is already linked to the account.
  /// this new phone number will replace it.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  Future<void> updatePhoneNumberCredential(AuthCredential credential) {
    assert(credential != null);
    if (credential is! PhoneAuthCredential) {
      throw ArgumentError.value(
        credential,
        'Credential must be a phone credential, '
        'i.e. made with PhoneAuthProvider.getCredential()',
      );
    }
    return FirebaseAuthPlatform.instance
        .updatePhoneNumberCredential(_app.name, credential);
  }

  /// Updates the password of the user.
  ///
  /// Anonymous users who update both their email and password will no
  /// longer be anonymous. They will be able to log in with these credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///
  ///  * `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///  * `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updatePassword(String password) {
    assert(password != null);
    return FirebaseAuthPlatform.instance.updatePassword(_app.name, password);
  }

  /// Updates the user profile information.
  ///
  /// Errors:
  ///
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) {
    assert(userUpdateInfo != null);
    return FirebaseAuthPlatform.instance.updateProfile(
      _app.name,
      displayName: userUpdateInfo.displayName,
      photoUrl: userUpdateInfo.photoUrl,
    );
  }

  /// Renews the user’s authentication tokens by validating a fresh set of
  /// [credential]s supplied by the user and returns additional identity provider
  /// data.
  ///
  /// This is used to prevent or resolve `ERROR_REQUIRES_RECENT_LOGIN`
  /// response to operations that require a recent sign-in.
  ///
  /// If the user associated with the supplied credential is different from the
  /// current user, or if the validation of the supplied credentials fails; an
  /// error is returned and the current user remains signed in.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_CREDENTIAL` - If the [authToken] or [authTokenSecret] is malformed or has expired.
  ///  * `ERROR_WRONG_PASSWORD` - If the password is invalid or the user does not have a password.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<AuthResult> reauthenticateWithCredential(
      AuthCredential credential) async {
    assert(credential != null);
    final PlatformAuthResult result = await FirebaseAuthPlatform.instance
        .reauthenticateWithCredential(_app.name, credential);
    return AuthResult._(result, _app);
  }

  /// Detaches the [provider] account from the current user.
  ///
  /// This will prevent the user from signing in to this account with those
  /// credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Use the `providerId` method of an auth provider for [provider].
  ///
  /// Errors:
  ///
  ///  * `ERROR_NO_SUCH_PROVIDER` - If the user does not have a Github Account linked to their account.
  ///  * `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  Future<void> unlinkFromProvider(String provider) {
    assert(provider != null);
    return FirebaseAuthPlatform.instance
        .unlinkFromProvider(_app.name, provider);
  }

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
