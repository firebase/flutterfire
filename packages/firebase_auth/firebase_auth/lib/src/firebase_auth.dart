// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// The entry point of the Firebase Authentication SDK.
class FirebaseAuth {
  FirebaseAuth._(this.app);

  /// Provides an instance of this class corresponding to `app`.
  factory FirebaseAuth.fromApp(FirebaseApp app) {
    assert(app != null);
    return FirebaseAuth._(app);
  }

  /// Provides an instance of this class corresponding to the default app.
  static final FirebaseAuth instance = FirebaseAuth._(FirebaseApp.instance);

  final FirebaseApp app;

  /// Receive [FirebaseUser] each time the user signIn or signOut
  Stream<FirebaseUser> get onAuthStateChanged {
    return FirebaseAuthPlatform.instance.onAuthStateChanged(app.name).map(
        (PlatformUser user) => user == null ? null : FirebaseUser._(user, app));
  }

  /// Asynchronously creates and becomes an anonymous user.
  ///
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead. If there is any other existing user signed in, that
  /// user will be signed out.
  ///
  /// **Important**: You must enable Anonymous accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Anonymous accounts are not enabled.
  Future<AuthResult> signInAnonymously() async {
    final PlatformAuthResult data =
        await FirebaseAuthPlatform.instance.signInAnonymously(app.name);
    final AuthResult authResult = AuthResult._(data, app);
    return authResult;
  }

  /// Tries to create a new user account with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Errors:
  ///
  ///  * `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///  * `ERROR_INVALID_EMAIL` - If the email address is malformed.
  ///  * `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  Future<AuthResult> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null);
    assert(password != null);
    final PlatformAuthResult data = await FirebaseAuthPlatform.instance
        .createUserWithEmailAndPassword(app.name, email, password);
    final AuthResult authResult = AuthResult._(data, app);
    return authResult;
  }

  /// Returns a list of sign-in methods that can be used to sign in a given
  /// user (identified by its main email address).
  ///
  /// This method is useful when you support multiple authentication mechanisms
  /// if you want to implement an email-first authentication flow.
  ///
  /// An empty `List` is returned if the user could not be found.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_CREDENTIAL` - If the [email] address is malformed.
  Future<List<String>> fetchSignInMethodsForEmail({
    @required String email,
  }) {
    assert(email != null);
    return FirebaseAuthPlatform.instance
        .fetchSignInMethodsForEmail(app.name, email);
  }

  /// Triggers the Firebase Authentication backend to send a password-reset
  /// email to the given email address, which must correspond to an existing
  /// user of your app.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
  ///  * `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address.
  Future<void> sendPasswordResetEmail({
    @required String email,
  }) {
    assert(email != null);
    return FirebaseAuthPlatform.instance
        .sendPasswordResetEmail(app.name, email);
  }

  /// Sends a sign in with email link to provided email address.
  Future<void> sendSignInWithEmailLink({
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleID,
    @required String androidPackageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) {
    assert(email != null);
    assert(url != null);
    assert(handleCodeInApp != null);
    assert(iOSBundleID != null);
    assert(androidPackageName != null);
    assert(androidInstallIfNotAvailable != null);
    assert(androidMinimumVersion != null);
    return FirebaseAuthPlatform.instance.sendLinkToEmail(
      app.name,
      email: email,
      url: url,
      handleCodeInApp: handleCodeInApp,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: androidInstallIfNotAvailable,
      androidMinimumVersion: androidMinimumVersion,
    );
  }

  /// Checks if link is an email sign-in link.
  Future<bool> isSignInWithEmailLink(String link) {
    return FirebaseAuthPlatform.instance.isSignInWithEmailLink(app.name, link);
  }

  /// Signs in using an email address and email sign-in link.
  ///
  /// Errors:
  ///
  ///  * `ERROR_NOT_ALLOWED` - Indicates that email and email sign-in link
  ///      accounts are not enabled. Enable them in the Auth section of the
  ///      Firebase console.
  ///  * `ERROR_DISABLED` - Indicates the user's account is disabled.
  ///  * `ERROR_INVALID` - Indicates the email address is invalid.
  Future<AuthResult> signInWithEmailAndLink({String email, String link}) async {
    final PlatformAuthResult data = await FirebaseAuthPlatform.instance
        .signInWithEmailAndLink(app.name, email, link);
    final AuthResult authResult = AuthResult._(data, app);
    return authResult;
  }

  /// Tries to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// **Important**: You must enable Email & Password accounts in the Auth
  /// section of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
  ///  * `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
  ///  * `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<AuthResult> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) {
    assert(email != null);
    assert(password != null);
    final AuthCredential credential = EmailAuthProvider.getCredential(
      email: email,
      password: password,
    );
    return signInWithCredential(credential);
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// If the user doesn't have an account already, one will be created automatically.
  ///
  /// **Important**: You must enable the relevant accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_CREDENTIAL` - If the credential data is malformed or has expired.
  ///  * `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///  * `ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL` - If there already exists an account with the email address asserted by Google.
  ///       Resolve this case by calling [fetchSignInMethodsForEmail] and then asking the user to sign in using one of them.
  ///       This error will only be thrown if the "One account per email address" setting is enabled in the Firebase console (recommended).
  ///  * `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Google accounts are not enabled.
  ///  * `ERROR_INVALID_ACTION_CODE` - If the action code in the link is malformed, expired, or has already been used.
  ///       This can only occur when using [EmailAuthProvider.getCredentialWithLink] to obtain the credential.
  Future<AuthResult> signInWithCredential(AuthCredential credential) async {
    assert(credential != null);
    final PlatformAuthResult data = await FirebaseAuthPlatform.instance
        .signInWithCredential(app.name, credential);
    final AuthResult authResult = AuthResult._(data, app);
    return authResult;
  }

  /// Starts the phone number verification process for the given phone number.
  ///
  /// Either sends an SMS with a 6 digit code to the phone number specified,
  /// or sign's the user in and [verificationCompleted] is called.
  ///
  /// No duplicated SMS will be sent out upon re-entry (before timeout).
  ///
  /// Make sure to test all scenarios below:
  ///
  ///  * You directly get logged in if Google Play Services verified the phone
  ///     number instantly or helped you auto-retrieve the verification code.
  ///  * Auto-retrieve verification code timed out.
  ///  * Error cases when you receive [verificationFailed] callback.
  ///
  /// [phoneNumber] The phone number for the account the user is signing up
  ///   for or signing into. Make sure to pass in a phone number with country
  ///   code prefixed with plus sign ('+').
  ///
  /// [timeout] The maximum amount of time you are willing to wait for SMS
  ///   auto-retrieval to be completed by the library. Maximum allowed value
  ///   is 2 minutes. Use 0 to disable SMS-auto-retrieval. Setting this to 0
  ///   will also cause [codeAutoRetrievalTimeout] to be called immediately.
  ///   If you specified a positive value less than 30 seconds, library will
  ///   default to 30 seconds.
  ///
  /// [forceResendingToken] The [forceResendingToken] obtained from [codeSent]
  ///   callback to force re-sending another verification SMS before the
  ///   auto-retrieval timeout.
  ///
  /// [verificationCompleted] This callback must be implemented.
  ///   It will trigger when an SMS is auto-retrieved or the phone number has
  ///   been instantly verified. The callback will receive an [AuthCredential]
  ///   that can be passed to [signInWithCredential] or [linkWithCredential].
  ///
  /// [verificationFailed] This callback must be implemented.
  ///   Triggered when an error occurred during phone number verification.
  ///
  /// [codeSent] Optional callback.
  ///   It will trigger when an SMS has been sent to the users phone,
  ///   and will include a [verificationId] and [forceResendingToken].
  ///
  /// [codeAutoRetrievalTimeout] Optional callback.
  ///   It will trigger when SMS auto-retrieval times out and provide a
  ///   [verificationId].
  Future<void> verifyPhoneNumber({
    @required String phoneNumber,
    @required Duration timeout,
    int forceResendingToken,
    @required PhoneVerificationCompleted verificationCompleted,
    @required PhoneVerificationFailed verificationFailed,
    @required PhoneCodeSent codeSent,
    @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) {
    return FirebaseAuthPlatform.instance.verifyPhoneNumber(
      app.name,
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Tries to sign in a user with a given Custom Token [token].
  ///
  /// If successful, it also signs the user in into the app and updates
  /// the [onAuthStateChanged] stream.
  ///
  /// Use this method after you retrieve a Firebase Auth Custom Token from your server.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  ///
  /// Errors:
  ///
  ///  * `ERROR_INVALID_CUSTOM_TOKEN` - The custom token format is incorrect.
  ///     Please check the documentation.
  ///  * `ERROR_CUSTOM_TOKEN_MISMATCH` - Invalid configuration.
  ///     Ensure your app's SHA1 is correct in the Firebase console.
  Future<AuthResult> signInWithCustomToken({@required String token}) async {
    assert(token != null);
    final PlatformAuthResult data = await FirebaseAuthPlatform.instance
        .signInWithCustomToken(app.name, token);
    final AuthResult authResult = AuthResult._(data, app);
    return authResult;
  }

  /// Signs out the current user and clears it from the disk cache.
  ///
  /// If successful, it signs the user out of the app and updates
  /// the [onAuthStateChanged] stream.
  Future<void> signOut() {
    return FirebaseAuthPlatform.instance.signOut(app.name);
  }

  /// Returns the currently signed-in [FirebaseUser] or [null] if there is none.
  Future<FirebaseUser> currentUser() async {
    final PlatformUser data =
        await FirebaseAuthPlatform.instance.getCurrentUser(app.name);
    final FirebaseUser currentUser =
        data == null ? null : FirebaseUser._(data, app);
    return currentUser;
  }

  /// Sets the user-facing language code for auth operations that can be
  /// internationalized, such as [sendEmailVerification]. This language
  /// code should follow the conventions defined by the IETF in BCP47.
  Future<void> setLanguageCode(String language) {
    assert(language != null);
    return FirebaseAuthPlatform.instance.setLanguageCode(app.name, language);
  }

  /// Completes the password reset process, given a confirmation code and new password.
  ///
  /// Errors:
  /// `EXPIRED_ACTION_CODE` - if the password reset code has expired.
  /// `INVALID_ACTION_CODE` - if the password reset code is invalid. This can happen if the code is malformed or has already been used.
  /// `USER_DISABLED` - if the user corresponding to the given password reset code has been disabled.
  /// `USER_NOT_FOUND` - if there is no user corresponding to the password reset code. This may have happened if the user was deleted between when the code was issued and when this method was called.
  /// `WEAK_PASSWORD` - if the new password is not strong enough.
  Future<void> confirmPasswordReset(String oobCode, String newPassword) {
    return FirebaseAuthPlatform.instance
        .confirmPasswordReset(app.name, oobCode, newPassword);
  }
}
