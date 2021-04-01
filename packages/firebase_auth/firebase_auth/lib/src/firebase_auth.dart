// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// The entry point of the Firebase Authentication SDK.
class FirebaseAuth extends FirebasePluginPlatform {
  // Cached instances of [FirebaseAuth].
  static Map<String, FirebaseAuth> _firebaseAuthInstances = {};

  // Cached and lazily loaded instance of [FirebaseAuthPlatform] to avoid
  // creating a [MethodChannelFirebaseAuth] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseAuthPlatform? _delegatePackingProperty;

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  FirebaseAuthPlatform get _delegate {
    _delegatePackingProperty ??= FirebaseAuthPlatform.instanceFor(
      app: app,
      pluginConstants: pluginConstants,
    );
    return _delegatePackingProperty!;
  }

  /// The [FirebaseApp] for this current Auth instance.
  FirebaseApp app;

  FirebaseAuth._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_auth');

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseAuth get instance {
    FirebaseApp defaultAppInstance = Firebase.app();

    return FirebaseAuth.instanceFor(app: defaultAppInstance);
  }

  /// Returns an instance using a specified [FirebaseApp].
  factory FirebaseAuth.instanceFor({required FirebaseApp app}) {
    return _firebaseAuthInstances.putIfAbsent(app.name, () {
      return FirebaseAuth._(app: app);
    });
  }

  /// Returns the current [User] if they are currently signed-in, or `null` if
  /// not.
  ///
  /// You should not use this getter to determine the users current state,
  /// instead use [authStateChanges], [idTokenChanges] or [userChanges] to
  /// subscribe to updates.
  User? get currentUser {
    if (_delegate.currentUser != null) {
      return User._(this, _delegate.currentUser!);
    }

    return null;
  }

  /// The current Auth instance's language code.
  ///
  /// See [setLanguageCode] to update the language code.
  String? get languageCode {
    if (_delegate.languageCode != null) {
      return _delegate.languageCode;
    }

    return null;
  }

  /// Changes this instance to point to an Auth emulator running locally.
  ///
  /// Set the [origin] of the local emulator, such as "http://localhost:9099"
  ///
  /// Note: Must be called immediately, prior to accessing auth methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  ///
  /// Note: auth emulator is not supported for web yet. firebase-js-sdk does not support
  /// auth.useEmulator until v8.2.4, but FlutterFire does not support firebase-js-sdk v8+ yet
  Future<void> useEmulator(String origin) async {
    assert(origin.isNotEmpty);
    String mappedOrigin = origin;

    // Android considers localhost as 10.0.2.2 - automatically handle this for users.
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (mappedOrigin.startsWith('http://localhost')) {
        mappedOrigin =
            mappedOrigin.replaceFirst('http://localhost', 'http://10.0.2.2');
      } else if (mappedOrigin.startsWith('http://127.0.0.1')) {
        mappedOrigin =
            mappedOrigin.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
      }
    }

    // Native calls take the host and port split out
    final hostPortRegex = RegExp(r'^http:\/\/([\w\d.]+):(\d+)$');
    final RegExpMatch? match = hostPortRegex.firstMatch(mappedOrigin);
    if (match == null) {
      throw ArgumentError('firebase.auth().useEmulator() origin format error');
    }
    // Two non-empty groups in RegExp match - which is null-tested - these are non-null now
    final String host = match.group(1)!;
    final int port = int.parse(match.group(2)!);
    await _delegate.useEmulator(host, port);
  }

  /// Applies a verification code sent to the user by email or other out-of-band
  /// mechanism.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **expired-action-code**:
  ///  - Thrown if the action code has expired.
  /// - **invalid-action-code**:
  ///  - Thrown if the action code is invalid. This can happen if the code is
  ///    malformed or has already been used.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given action code has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the action code. This may
  ///    have happened if the user was deleted between when the action code was
  ///    issued and when this method was called.
  Future<void> applyActionCode(String code) async {
    await _delegate.applyActionCode(code);
  }

  /// Checks a verification code sent to the user by email or other out-of-band
  /// mechanism.
  ///
  /// Returns [ActionCodeInfo] about the code.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **expired-action-code**:
  ///  - Thrown if the action code has expired.
  /// - **invalid-action-code**:
  ///  - Thrown if the action code is invalid. This can happen if the code is
  ///    malformed or has already been used.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given action code has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the action code. This may
  ///    have happened if the user was deleted between when the action code was
  ///    issued and when this method was called.
  Future<ActionCodeInfo> checkActionCode(String code) {
    return _delegate.checkActionCode(code);
  }

  /// Completes the password reset process, given a confirmation code and new
  /// password.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **expired-action-code**:
  ///  - Thrown if the action code has expired.
  /// - **invalid-action-code**:
  ///  - Thrown if the action code is invalid. This can happen if the code is
  ///    malformed or has already been used.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given action code has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the action code. This may
  ///    have happened if the user was deleted between when the action code was
  ///    issued and when this method was called.
  /// - **weak-password**:
  ///  - Thrown if the new password is not strong enough.
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    await _delegate.confirmPasswordReset(code, newPassword);
  }

  /// Tries to create a new user account with the given email address and
  /// password.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **email-already-in-use**:
  ///  - Thrown if there already exists an account with the given email address.
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  /// - **operation-not-allowed**:
  ///  - Thrown if email/password accounts are not enabled. Enable
  ///    email/password accounts in the Firebase Console, under the Auth tab.
  /// - **weak-password**:
  ///  - Thrown if the password is not strong enough.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return UserCredential._(
      this,
      await _delegate.createUserWithEmailAndPassword(email, password),
    );
  }

  /// Returns a list of sign-in methods that can be used to sign in a given
  /// user (identified by its main email address).
  ///
  /// This method is useful when you support multiple authentication mechanisms
  /// if you want to implement an email-first authentication flow.
  ///
  /// An empty `List` is returned if the user could not be found.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return _delegate.fetchSignInMethodsForEmail(email);
  }

  /// Returns a UserCredential from the redirect-based sign-in flow.
  ///
  /// If sign-in succeeded, returns the signed in user. If sign-in was
  /// unsuccessful, fails with an error. If no redirect operation was called,
  /// returns a [UserCredential] with a null User.
  ///
  /// This method is only support on web platforms.
  Future<UserCredential> getRedirectResult() async {
    return UserCredential._(this, await _delegate.getRedirectResult());
  }

  /// Checks if an incoming link is a sign-in with email link.
  bool isSignInWithEmailLink(String emailLink) {
    return _delegate.isSignInWithEmailLink(emailLink);
  }

  /// Internal helper which pipes internal [Stream] events onto
  /// a users own Stream.
  Stream<User?> _pipeStreamChanges(Stream<UserPlatform?> stream) {
    Stream<User?> streamSync = stream.map((delegateUser) {
      if (delegateUser == null) {
        return null;
      }

      return User._(this, delegateUser);
    });

    StreamController<User?>? streamController;
    streamController = StreamController<User?>.broadcast(onListen: () {
      // Fire an event straight away
      streamController!.add(currentUser);
      // Pipe events of the broadcast stream into this stream
      streamSync.pipe(streamController);
    });

    return streamController.stream;
  }

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out).
  Stream<User?> authStateChanges() =>
      _pipeStreamChanges(_delegate.authStateChanges());

  /// Notifies about changes to the user's sign-in state (such as sign-in or
  /// sign-out) and also token refresh events.
  Stream<User?> idTokenChanges() =>
      _pipeStreamChanges(_delegate.idTokenChanges());

  /// Notifies about changes to any user updates.
  ///
  /// This is a superset of both [authStateChanges] and [idTokenChanges]. It
  /// provides events on all user changes, such as when credentials are linked,
  /// unlinked and when updates to the user profile are made. The purpose of
  /// this Stream is to for listening to realtime updates to the user without
  /// manually having to call [reload] and then rehydrating changes to your
  /// application.
  Stream<User?> userChanges() => _pipeStreamChanges(_delegate.userChanges());

  /// Triggers the Firebase Authentication backend to send a password-reset
  /// email to the given email address, which must correspond to an existing
  /// user of your app.
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    return _delegate.sendPasswordResetEmail(email, actionCodeSettings);
  }

  /// Sends a sign in with email link to provided email address.
  ///
  /// To complete the password reset, call [confirmPasswordReset] with the code
  /// supplied in the email sent to the user, along with the new password
  /// specified by the user.
  ///
  /// The [handleCodeInApp] of [actionCodeSettings] must be set to `true`
  /// otherwise an [ArgumentError] will be thrown.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the email address.
  Future<void> sendSignInLinkToEmail({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) async {
    if (actionCodeSettings.handleCodeInApp != true) {
      throw ArgumentError(
        'The [handleCodeInApp] value of [ActionCodeSettings] must be `true`.',
      );
    }

    await _delegate.sendSignInLinkToEmail(email, actionCodeSettings);
  }

  /// When set to null, the default Firebase Console language setting is
  /// applied.
  ///
  /// The language code will propagate to email action templates (password
  /// reset, email verification and email change revocation), SMS templates for
  /// phone authentication, reCAPTCHA verifier and OAuth popup/redirect
  /// operations provided the specified providers support localization with the
  /// language code specified.
  ///
  /// On web platforms, if `null` is provided as the [languageCode] the Firebase
  /// project default language will be used. On native platforms, the device
  /// language will be used.
  Future<void> setLanguageCode(String languageCode) {
    return _delegate.setLanguageCode(languageCode);
  }

  /// Updates the current instance with the provided settings.
  ///
  /// [appVerificationDisabledForTesting] This setting only applies to iOS and
  ///   web platforms. When set to `true`, this property disables app
  ///   verification for the purpose of testing phone authentication. For this
  ///   property to take effect, it needs to be set before handling a reCAPTCHA
  ///   app verifier. When this is disabled, a mock reCAPTCHA is rendered
  ///   instead. This is useful for manual testing during development or for
  ///   automated integration tests.
  ///
  ///   In order to use this feature, you will need to
  ///   [whitelist your phone number](https://firebase.google.com/docs/auth/web/phone-auth?authuser=0#test-with-whitelisted-phone-numbers)
  ///   via the Firebase Console.
  ///
  ///   The default value is `false` (app verification is enabled).
  ///
  /// [userAccessGroup] This setting only applies to iOS and MacOS platforms.
  ///   When set, it allows you to share authentication state between
  ///   applications. Set the property to your team group ID or set to `null` to
  ///   remove sharing capabilities.
  ///
  ///   Key Sharing capabilities must be enabled for your app via XCode (Project
  ///   settings > Capabilities). To learn more, visit the
  ///   [Apple documentation](https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps).
  Future<void> setSettings({
    bool? appVerificationDisabledForTesting,
    String? userAccessGroup,
  }) {
    return _delegate.setSettings(
      appVerificationDisabledForTesting: appVerificationDisabledForTesting,
      userAccessGroup: userAccessGroup,
    );
  }

  /// Changes the current type of persistence on the current Auth instance for
  /// the currently saved Auth session and applies this type of persistence for
  /// future sign-in requests, including sign-in with redirect requests.
  ///
  /// This will return a promise that will resolve once the state finishes
  /// copying from one type of storage to the other. Calling a sign-in method
  /// after changing persistence will wait for that persistence change to
  /// complete before applying it on the new Auth state.
  ///
  /// This makes it easy for a user signing in to specify whether their session
  /// should be remembered or not. It also makes it easier to never persist the
  /// Auth state for applications that are shared by other users or have
  /// sensitive data.
  ///
  /// This is only supported on web based platforms.
  Future<void> setPersistence(Persistence persistence) async {
    return _delegate.setPersistence(persistence);
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
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **operation-not-allowed**:
  ///  - Thrown if anonymous accounts are not enabled. Enable anonymous accounts
  /// in the Firebase Console, under the Auth tab.
  Future<UserCredential> signInAnonymously() async {
    return UserCredential._(this, await _delegate.signInAnonymously());
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// If the user doesn't have an account already, one will be created
  /// automatically.
  ///
  /// **Important**: You must enable the relevant accounts in the Auth section
  /// of the Firebase console before being able to use them.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **account-exists-with-different-credential**:
  ///  - Thrown if there already exists an account with the email address
  ///    asserted by the credential.
  ///    Resolve this by calling [fetchSignInMethodsForEmail] and then asking
  ///    the user to sign in using one of the returned providers.
  ///    Once the user is signed in, the original credential can be linked to
  ///    the user with [linkWithCredential].
  /// - **invalid-credential**:
  ///  - Thrown if the credential is malformed or has expired.
  /// - **operation-not-allowed**:
  ///  - Thrown if the type of account corresponding to the credential is not
  ///    enabled. Enable the account type in the Firebase Console, under the
  ///    Auth tab.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given credential has been
  ///    disabled.
  /// - **user-not-found**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Thrown if signing in with a credential from [EmailAuthProvider.credential]
  ///    and the password is invalid for the given email, or if the account
  ///    corresponding to the email does not have a password set.
  /// - **invalid-verification-code**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification code of the credential is not valid.
  /// - **invalid-verification-id**:
  ///  - Thrown if the credential is a [PhoneAuthProvider.credential] and the
  ///    verification ID of the credential is not valid.id.
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return UserCredential._(
      this,
      await _delegate.signInWithCredential(credential),
    );
  }

  /// Tries to sign in a user with a given custom token.
  ///
  /// Custom tokens are used to integrate Firebase Auth with existing auth
  /// systems, and must be generated by the auth backend.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// If the user identified by the [uid] specified in the token doesn't
  /// have an account already, one will be created automatically.
  ///
  /// Read how to use Custom Token authentication and the cases where it is
  /// useful in [the guides](https://firebase.google.com/docs/auth/android/custom-auth).
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **custom-token-mismatch**:
  ///  - Thrown if the custom token is for a different Firebase App.
  /// - **invalid-custom-token**:
  ///  - Thrown if the custom token format is incorrect.
  Future<UserCredential> signInWithCustomToken(String token) async {
    return UserCredential._(this, await _delegate.signInWithCustomToken(token));
  }

  /// Attempts to sign in a user with the given email address and password.
  ///
  /// If successful, it also signs the user in into the app and updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  ///
  /// **Important**: You must enable Email & Password accounts in the Auth
  /// section of the Firebase console before being able to use them.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///  - Thrown if the password is invalid for the given email, or the account
  ///    corresponding to the email does not have a password set.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return UserCredential._(
      this,
      await _delegate.signInWithEmailAndPassword(email, password),
    );
  }

  /// Signs in using an email address and email sign-in link.
  ///
  /// Fails with an error if the email address is invalid or OTP in email link
  /// expires.
  ///
  /// Confirm the link is a sign-in email link before calling this method,
  /// using [isSignInWithEmailLink].
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **expired-action-code**:
  ///  - Thrown if OTP in email link expires.
  /// - **invalid-email**:
  ///  - Thrown if the email address is not valid.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String emailLink,
  }) async {
    return UserCredential._(
      this,
      await _delegate.signInWithEmailLink(email, emailLink),
    );
  }

  /// Starts a sign-in flow for a phone number.
  ///
  /// You can optionally provide a [RecaptchaVerifier] instance to control the
  /// reCAPTCHA widget apperance and behaviour.
  ///
  /// Once the reCAPTCHA verification has completed, called [ConfirmationResult.confirm]
  /// with the users SMS verification code to complete the authentication flow.
  ///
  /// This method is only available on web based platforms.
  Future<ConfirmationResult> signInWithPhoneNumber(
    String phoneNumber, [
    RecaptchaVerifier? verifier,
  ]) async {
    assert(phoneNumber.isNotEmpty);

    verifier ??= RecaptchaVerifier();
    return ConfirmationResult._(
      this,
      await _delegate.signInWithPhoneNumber(phoneNumber, verifier.delegate),
    );
  }

  /// Authenticates a Firebase client using a popup-based OAuth authentication
  /// flow.
  ///
  /// If succeeds, returns the signed in user along with the provider's
  /// credential.
  ///
  /// This method is only available on web based platforms.
  Future<UserCredential> signInWithPopup(AuthProvider provider) async {
    return UserCredential._(this, await _delegate.signInWithPopup(provider));
  }

  /// Authenticates a Firebase client using a full-page redirect flow.
  ///
  /// To handle the results and errors for this operation, refer to
  /// [getRedirectResult].
  Future<void> signInWithRedirect(AuthProvider provider) {
    return _delegate.signInWithRedirect(provider);
  }

  /// Signs out the current user.
  ///
  /// If successful, it also updates
  /// any [authStateChanges], [idTokenChanges] or [userChanges] stream
  /// listeners.
  Future<void> signOut() async {
    await _delegate.signOut();
  }

  /// Checks a password reset code sent to the user by email or other
  /// out-of-band mechanism.
  ///
  /// Returns the user's email address if valid.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **expired-action-code**:
  ///  - Thrown if the password reset code has expired.
  /// - **invalid-action-code**:
  ///  - Thrown if the password reset code is invalid. This can happen if the
  ///    code is malformed or has already been used.
  /// - **user-disabled**:
  ///  - Thrown if the user corresponding to the given email has been disabled.
  /// - **user-not-found**:
  ///  - Thrown if there is no user corresponding to the password reset code.
  ///    This may have happened if the user was deleted between when the code
  ///    was issued and when this method was called.
  Future<String> verifyPasswordResetCode(String code) {
    return _delegate.verifyPasswordResetCode(code);
  }

  /// Starts a phone number verification process for the given phone number.
  ///
  /// This method is used to verify that the user-provided phone number belongs
  /// to the user. Firebase sends a code via SMS message to the phone number,
  /// where you must then prompt the user to enter the code. The code can be
  /// combined with the verification ID to create a [PhoneAuthProvider.credential]
  /// which you can then use to sign the user in, or link with their account (
  /// see [signInWithCredential] or [linkWithCredential]).
  ///
  /// On some Android devices, auto-verification can be handled by the device
  /// and a [PhoneAuthCredential] will be automatically provided.
  ///
  /// No duplicated SMS will be sent out unless a [forceResendingToken] is
  /// provided.
  ///
  /// [phoneNumber] The phone number for the account the user is signing up
  ///   for or signing into. Make sure to pass in a phone number with country
  ///   code prefixed with plus sign ('+').
  ///
  /// [timeout] The maximum amount of time you are willing to wait for SMS
  ///   auto-retrieval to be completed by the library. Maximum allowed value
  ///   is 2 minutes.
  ///
  /// [forceResendingToken] The [forceResendingToken] obtained from [codeSent]
  ///   callback to force re-sending another verification SMS before the
  ///   auto-retrieval timeout.
  ///
  /// [verificationCompleted] Triggered when an SMS is auto-retrieved or the
  ///   phone number has been instantly verified. The callback will receive an
  ///   [PhoneAuthCredential] that can be passed to [signInWithCredential] or
  ///   [linkWithCredential].
  ///
  /// [verificationFailed] Triggered when an error occurred during phone number
  ///   verification. A [FirebaseAuthException] is provided when this is
  ///   triggered.
  ///
  /// [codeSent] Triggered when an SMS has been sent to the users phone, and
  ///   will include a [verificationId] and [forceResendingToken].
  ///
  /// [codeAutoRetrievalTimeout] Triggered when SMS auto-retrieval times out and
  ///   provide a [verificationId].
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
  }) {
    return _delegate.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      // ignore: invalid_use_of_visible_for_testing_member
      autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
    );
  }

  @override
  String toString() {
    return 'FirebaseAuth(app: ${app.name})';
  }
}
