Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Error Handling

The Firebase Authentication SDKs for Flutter report errors by throwing a
`FirebaseAuthException`. Every exception has a `code` and a `message`. Some
exceptions also carry an `email`, `phoneNumber`, `tenantId` or `credential`
that you can use to resolve the error.

```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: "barry.allen@example.com",
    password: "SuperSecretPassword!",
  );
} on FirebaseAuthException catch (e) {
  final String error = switch (e.code) {
    'invalid-email' => 'The email address is not valid.',
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'user-not-found' ||
    'wrong-password' =>
      'The email address or password is incorrect.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' ||
    'network-request-failed' =>
      'Something went wrong. Try again later.',
    _ => 'Sign-in failed (${e.code}).',
  };
  print(error);
}
```

Branch on `code`, not on `message`. Messages come from the native SDKs, differ
between platforms and can change between SDK versions.

## How error codes are formatted {:#error-code-format}

- Codes are lowercase and hyphen-separated, such as `invalid-email`. They do
  not include the `auth/` prefix used by the Firebase JavaScript SDK or the
  `ERROR_` prefix used by the Android and Apple SDKs.
- Most codes come from the native Firebase SDK of the platform the app runs on,
  so the set of possible codes differs between Android, Apple platforms (iOS
  and macOS), web and Windows. The [error code reference](#error-code-reference)
  lists the platforms on which each code can be thrown, and
  [Platform differences](#platform-differences) lists the cases where the same
  error has a different code on different platforms.
- Some methods also throw errors that are not a `FirebaseAuthException`. For
  example, `sendSignInLinkToEmail` throws an `ArgumentError` when
  `ActionCodeSettings.handleCodeInApp` is not `true`.
- On Android and Apple platforms, `verifyPhoneNumber` does not throw. Errors are
  passed to the `verificationFailed` callback as a `FirebaseAuthException`.

## Email enumeration protection {:#email-enumeration-protection}

[Email enumeration protection](https://cloud.google.com/identity-platform/docs/admin/email-enumeration-protection)
is enabled by default for Firebase projects created on or after September 15,
2023. When it is enabled, email and password sign-in throws
`invalid-credential` instead of `user-not-found` or `wrong-password`, and
`sendPasswordResetEmail` completes without throwing `user-not-found`. On
Windows, the code is `unknown-error`. Older versions of the native SDKs
reported `invalid-login-credentials`. Handle `invalid-credential`,
`invalid-login-credentials`, `user-not-found` and `wrong-password` if your app
must work with both settings.

## Multi-factor authentication {:#multi-factor}

When a user who has enrolled a second factor signs in, the sign-in method
throws a `FirebaseAuthMultiFactorException`. It is a subclass of
`FirebaseAuthException` whose `resolver` completes the sign-in. Its code is
`second-factor-required` on Android and Apple platforms, and
`multi-factor-auth-required` on web. Catch it by type rather than by code:

```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthMultiFactorException catch (e) {
  // Ask the user to complete the second factor with e.resolver.
} on FirebaseAuthException catch (e) {
  // Handle other errors.
}
```

`signInWithRedirect`, `getRedirectResult` and `reauthenticateWithPopup` throw
a plain `FirebaseAuthException` with the multi-factor code instead, without a
`resolver`.

See [Multi-factor authentication](/docs/auth/flutter/multi-factor) for the
complete flow. Multi-factor authentication is not supported on Windows.

## Handling `account-exists-with-different-credential` errors {:#handling_account-exists-with-different-credential_errors}

If you enabled the **One account per email address** setting in the
[Firebase console](https://console.firebase.google.com/project/_/authentication/providers),
signing in with a provider (such as Google) using an email address that already
belongs to an account with another provider (such as Facebook) throws
`account-exists-with-different-credential`. The exception's `email` is the
conflicting email address and its `credential` is the credential of the
provider the user just tried.

To complete the sign-in, sign the user in with the provider their account
already uses, then link the pending credential to that account:

```dart
FirebaseAuth auth = FirebaseAuth.instance;

try {
  // Attempt to sign the user in with Google.
  await auth.signInWithCredential(googleAuthCredential);
} on FirebaseAuthException catch (e) {
  if (e.code == 'account-exists-with-different-credential') {
    // The email address of the existing account.
    String? email = e.email;
    // The Google credential the user just tried to sign in with.
    AuthCredential? pendingCredential = e.credential;

    // Ask the user to sign in to `email` with the provider they used before,
    // for example Facebook. With email enumeration protection enabled,
    // Firebase does not tell you which provider that is, so let the user
    // choose.
    print('Sign in to $email with the provider you used before.');
    UserCredential userCredential = await auth.signInWithCredential(
      FacebookAuthProvider.credential(facebookAccessToken),
    );

    // Link the Google credential to the existing account, so the user can
    // sign in with either provider from now on.
    if (pendingCredential != null) {
      await userCredential.user!.linkWithCredential(pendingCredential);
    }
  }
}
```

On Windows, this error has the code `account-exists-with-different-credentials`.

## `recaptcha-sdk-not-linked` (iOS phone auth) {:#recaptcha-sdk-not-linked}

If `e.code` is **`recaptcha-sdk-not-linked`** during **`verifyPhoneNumber`** on **iOS**, the native layer expects **reCAPTCHA Enterprise**
to be linked or your **Identity Platform** project configuration must be adjusted. This is not fixed from Dart alone.

See [Phone Authentication — iOS: reCAPTCHA SDK and Identity Platform](/docs/auth/flutter/phone-auth#ios-recaptcha-sdk-and-identity-platform) for
recommended setup, the Safari flow, and a documented **GCP / Identity Toolkit** workaround with trade-offs.

## Platform differences {:#platform-differences}

The same situation can produce a different code depending on the platform.

Situation | Android | Apple | Web | Windows
----------|---------|-------|-----|--------
Wrong email or password, with email enumeration protection enabled | `invalid-credential` | `invalid-credential` | `invalid-credential` | `unknown-error`
Error without a more specific code | `unknown` | `unknown` or `internal-error` | `unknown` or `internal-error` | `unknown-error`
A blocking function rejected the operation | `blocking-function-error-response` | `blocking-cloud-function-returned-error` | `internal-error` | `unknown-error`
Password does not meet the password policy | `unknown` | `password-does-not-meet-requirements` | `password-does-not-meet-requirements` | `unknown-error`
SMS quota exceeded | `too-many-requests` | `quota-exceeded` | `quota-exceeded` | Not supported
No user signed in | `no-current-user` | `no-current-user` | `no-current-user` | `no-signed-in-user`
Account exists with a different credential | `account-exists-with-different-credential` | `account-exists-with-different-credential` | `account-exists-with-different-credential` | `account-exists-with-different-credentials`
Second factor already enrolled | `second-factor-already-enrolled` | `enroll-failed` | `second-factor-already-in-use` | Not supported
Multi-factor enrollment or sign-in resolution failed | The SDK code, such as `invalid-verification-code` | `enroll-failed`, `unenroll-failed`, `resolve-signin-failed` or `generate-secret-failed` | The SDK code, such as `invalid-verification-code` | Not supported
`signInWithProvider`, `linkWithProvider` or `reauthenticateWithProvider` failed | The SDK code | `sign-in-failed` on iOS, except `account-exists-with-different-credential` | The SDK code | Not supported
Continue URL domain not authorized | `unauthorized-domain` | `unauthorized-domain` | `unauthorized-continue-uri` | Not supported
Invalid app verifier in a phone verification request | `app-not-authorized` | `invalid-app-credential` | `invalid-app-credential` | Not supported
Empty SMS code | `missing-verification-code` | `missing-verification-code` | `missing-code` | Not supported
User cancelled a sign-in web view | `web-context-canceled` | `web-context-cancelled` | `popup-closed-by-user` or `redirect-cancelled-by-user` | Not supported

On Apple platforms, the multi-factor methods replace the SDK code with
`enroll-failed`, `unenroll-failed`, `resolve-signin-failed` or
`generate-secret-failed`. The underlying error is in `message`. Errors from
the phone verification step of multi-factor enrollment or sign-in are passed to
`verificationFailed` with the SDK code.

## Error code reference {:#error-code-reference}

The tables below list the codes a `FirebaseAuthException` can have, grouped
by feature. **Platforms** lists where the code can be thrown: Android, Apple
(iOS and macOS), Web and Windows. The list is based on the Firebase Android SDK
(BoM 34.19.0), Firebase Apple SDK 12.19.0, Firebase JavaScript SDK 12.19.0 and
Firebase C++ SDK 13.13.0. Codes that the SDKs define but never throw, and codes that only apply to
Cordova apps, are omitted. On web, an error code from the backend that the
JavaScript SDK does not recognize is passed through in lowercase. On Android, an unexpected
native exception that is not a Firebase error is reported with its lowercased
class name as the code, for example `illegalstateexception`.

For the errors each method throws, see the
[API reference](https://pub.dev/documentation/firebase_auth/latest/). For the
native definitions, see the
[Android](https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseAuthException),
[Apple](https://firebase.google.com/docs/reference/swift/firebaseauth/api/reference/Enums/AuthErrorCode),
[JavaScript](https://firebase.google.com/docs/reference/js/auth#autherrorcodes) and
[C++](https://firebase.google.com/docs/reference/cpp/namespace/firebase/auth#autherror)
references.

### General and configuration

Code | Description | Platforms
-----|-------------|----------
`unknown` | An error that could not be mapped to a more specific code. Check `message` for details. | Android, Apple, Web
`unknown-error` | Windows equivalent of `unknown`: the C++ SDK returned an error that has no specific code. | Windows
`internal-error` | An internal error occurred in the Firebase SDK or backend. On web, a rejection from a blocking function is also reported with this code. | Apple, Web
`unimplemented` | The method is not supported on Windows. | Windows
`unsupported-platform` | The method is not supported on macOS (for example `signInWithProvider` or phone authentication). | Apple
`unsupported-platform-operation` | The method is not supported on this Apple platform (for example `revokeAccessToken`). | Apple
`api-not-available` | The API is not available on this device, for example because Google Play services are missing. | Android
`invalid-api-key` | The API key in your Firebase options is invalid. | Apple, Web, Windows
`app-not-authorized` | This app is not authorized to use Firebase Authentication with the provided API key. On Android, check the package name and SHA-1/SHA-256 fingerprints registered in the Firebase console. | All
`argument-error` | An invalid argument was passed to a Firebase Authentication method. | Web
`already-initialized` | Auth was already initialized with different options. | Web
`dependent-sdk-initialized-before-auth` | Another Firebase SDK used Auth before Auth was initialized. | Web
`auth-domain-config-required` | `authDomain` is missing from your Firebase options. | Web
`emulator-config-failed` | `useAuthEmulator` was called after Auth already made a network request. Call it earlier. | Web
`invalid-emulator-scheme` | The emulator URL must start with `http://` or `https://`. | Web
`operation-not-supported-in-this-environment` | The operation is not supported in this environment (the page must be served over http, https or chrome-extension, with web storage enabled). | Web
`web-storage-unsupported` | The browser is not supported, or third-party cookies and data are disabled. | Android, Web
`keychain-error` | An error occurred while accessing the keychain. Check `message` for the underlying keychain error. | Apple
`malformed-jwt` | A JWT returned by the backend could not be parsed. | Apple
`unsupported-passthrough-operation` | The operation is not supported in passthrough mode. | Android
`admin-restricted-operation` | The operation is restricted to administrators (for example, anonymous sign-up is disabled for the project). | Android, Apple, Web
`operation-not-allowed` | The sign-in provider or operation is disabled for this project. Enable it in the Firebase console under **Authentication > Sign-in method**. | All
`null-user` | A null user was passed to an operation that requires a user. | Apple

### Network, quota and abuse protection

Code | Description | Platforms
-----|-------------|----------
`network-request-failed` | A network error occurred (timeout, interrupted connection or unreachable host). | All
`too-many-requests` | Requests from this device were blocked because of unusual activity, or a quota was exceeded. Try again later. | All
`quota-exceeded` | The project's quota for this operation (for example, SMS messages) has been exceeded. | Apple, Web
`timeout` | The operation timed out. | Web

### Users and sessions

Code | Description | Platforms
-----|-------------|----------
`user-not-found` | There is no user corresponding to this identifier; the user may have been deleted. Not thrown for email/password sign-in when email enumeration protection is enabled. | All
`user-disabled` | The user account has been disabled by an administrator. | All
`user-token-expired` | The user's credential is no longer valid. The user must sign in again. | All
`invalid-user-token` | The user's credential is not valid for this project, for example because the token was tampered with or belongs to another project. | All
`requires-recent-login` | The operation is security sensitive and requires a recent sign-in. Reauthenticate the user, then retry. | All
`user-mismatch` | The credential passed to a reauthenticate method does not belong to the current user. | All
`no-current-user` | No user is signed in. Thrown by `User` methods called after the user signed out. | Android, Apple, Web
`no-signed-in-user` | Windows equivalent of `no-current-user`. | Windows

### Email and password

Code | Description | Platforms
-----|-------------|----------
`invalid-email` | The email address is badly formatted. | All
`missing-email` | An email address is required but was not provided. | All
`wrong-password` | The password is invalid, or the account has no password. Not thrown when email enumeration protection is enabled; `invalid-credential` is thrown instead. | All
`missing-password` | A non-empty password is required. | Android, Web
`invalid-password` | Thrown by `validatePassword` when the password is null or empty. | All
`weak-password` | The password is too weak. On Android, `message` explains the reason. | All
`password-does-not-meet-requirements` | The password does not satisfy the project's password policy. | Apple, Web
`unsupported-password-policy-schema-version` | The password policy returned by the backend uses a schema this SDK version does not support. | Web
`email-already-in-use` | The email address is already used by another account. | All

### Credentials, tokens and account linking

Code | Description | Platforms
-----|-------------|----------
`invalid-credential` | The supplied credential is incorrect, malformed or has expired. With email enumeration protection enabled, this is also thrown for an unknown email or a wrong password. | All
`invalid-login-credentials` | Reported instead of the SDK code when the error message contains `INVALID_LOGIN_CREDENTIALS`. Older versions of the native SDKs did this for wrong email/password sign-ins; current versions report `invalid-credential`. Handle it like `invalid-credential`. | Android, Apple
`rejected-credential` | The request contains malformed or mismatching credentials. | Android, Web
`invalid-custom-token` | The custom token format is incorrect. | All
`custom-token-mismatch` | The custom token was created for a different project. | All
`account-exists-with-different-credential` | An account already exists with the same email address but a different sign-in provider. See [below](#handling_account-exists-with-different-credential_errors). | Android, Apple, Web
`account-exists-with-different-credentials` | Windows spelling of `account-exists-with-different-credential`. | Windows
`credential-already-in-use` | The credential is already linked to a different user account. | All
`provider-already-linked` | The user is already linked to an account for this provider. | All
`no-such-provider` | The user is not linked to an account with the given provider. | All
`missing-or-invalid-nonce` | The nonce is missing, or the SHA-256 hash of the raw nonce does not match the nonce in the ID token. | Android, Apple, Web
`invalid-provider-id` | The provider ID is invalid. | Android, Apple, Web
`invalid-oauth-client-id` | The OAuth client ID is invalid or does not match the API key. | Web
`invalid-client-id` | The client ID used for the web sign-in flow is invalid. | Apple
`user-cancelled` | The user did not grant the permissions your app requested. | Android, Web
`sign-in-failed` | On iOS, `signInWithProvider`, `linkWithProvider` or `reauthenticateWithProvider` with an OAuth provider failed. The SDK code is replaced by this code; check `message` for the underlying error. | Apple
`login-blocked` | Sign-in was blocked by a user-provided method. | Web

### Blocking functions

Code | Description | Platforms
-----|-------------|----------
`blocking-function-error-response` | A blocking function (such as `beforeUserCreated` or `beforeUserSignedIn`) rejected the operation. `message` contains the error returned by the function. | Android
`blocking-cloud-function-returned-error` | A blocking function rejected the operation. `message` contains the error returned by the function. | Apple

### Email actions and links

Code | Description | Platforms
-----|-------------|----------
`expired-action-code` | The action code (password reset, email verification or email link) has expired. | Android, Apple, Web
`invalid-action-code` | The action code is invalid: it is malformed, expired or has already been used. | Android, Apple, Web
`invalid-continue-uri` | The continue URL in `ActionCodeSettings` is invalid. | Apple, Web
`missing-continue-uri` | A continue URL must be provided in `ActionCodeSettings`. | Android, Apple
`unauthorized-continue-uri` | The domain of the continue URL is not authorized. Add it to the authorized domains in the Firebase console. Android and Apple platforms report `unauthorized-domain` instead. | Web
`missing-android-pkg-name` | An Android package name must be provided when `androidInstallApp` is `true`. | Apple, Web
`missing-ios-bundle-id` | An iOS bundle ID must be provided. | Apple, Web
`invalid-dynamic-link-domain` | The dynamic link domain is not configured or authorized for this project. | Android, Web
`invalid-hosting-link-domain` | The Hosting link domain is not configured in Firebase Hosting or not owned by this project. | Android, Apple, Web
`dynamic-link-not-activated` | Dynamic Links is not activated for this project. | Android, Web
`invalid-message-payload` | The email template for this action contains invalid characters. Fix it in the Auth email templates in the Firebase console. | All
`invalid-sender` | The email template for this action has an invalid sender email or name. | All
`invalid-recipient-email` | The email could not be sent because the recipient address is invalid. | All
`unverified-email` | The operation requires a verified email address. | Android, Apple, Web
`email-change-needs-verification` | Multi-factor users must always have a verified email address. | Android, Apple, Web

### Phone authentication and app verification

Code | Description | Platforms
-----|-------------|----------
`invalid-phone-number` | The phone number is not in a valid format. Use E.164 (`+[country code][number]`). | Android, Apple, Web
`missing-phone-number` | A phone number is required. | Android, Apple, Web
`invalid-verification-code` | The SMS verification code is invalid. | Android, Apple, Web
`missing-verification-code` | The phone credential was created with an empty SMS code. | Android, Apple
`missing-code` | Web equivalent of `missing-verification-code`. | Web
`invalid-verification-id` | The verification ID is invalid. | Android, Apple, Web
`missing-verification-id` | The phone credential was created with an empty verification ID. | Android, Apple, Web
`session-expired` | The SMS code has expired. Resend the verification code. | Android, Apple
`code-expired` | The SMS code has expired. Resend the verification code. | Web
`retry-phone-auth` | An error occurred with the phone credential. Retry the verification. | Android
`missing-app-credential` | The phone verification request is missing an app verifier (reCAPTCHA token or APNs token). | Apple, Web
`invalid-app-credential` | The app verifier (reCAPTCHA token or APNs token) in the phone verification request is invalid or has expired. | Apple, Web
`missing-app-token` | The APNs device token could not be obtained. Check that push notifications are configured. | Apple
`notification-not-forwarded` | The app did not forward the silent APNs notification to Firebase Authentication. | Apple
`app-not-verified` | The app could not be verified for phone authentication. | Apple
`app-verification-failed` | App verification failed. | Apple
`missing-client-identifier` | The request is missing a client identifier. On Android, both Play Integrity and reCAPTCHA verification failed. | Android, Apple
`alternate-client-identifier-required` | The app identifier could not be verified. Retry with another verification method, such as reCAPTCHA. | Android
`invalid-cert-hash` | The SHA-1 certificate hash is invalid or could not be read. | Android, Web
`invalid-app-id` | The mobile app identifier is not registered for this project. | Web
`missing-activity` | An Android `Activity` is required to show the reCAPTCHA flow. | Android

### reCAPTCHA

Code | Description | Platforms
-----|-------------|----------
`captcha-check-failed` | The reCAPTCHA response is invalid, expired, already used, or its domain is not authorized. | Android, Apple, Web
`recaptcha-not-enabled` | reCAPTCHA Enterprise is not enabled for this project. | Android, Apple, Web
`recaptcha-sdk-not-linked` | The reCAPTCHA Enterprise SDK is not linked in the iOS app. See [below](#recaptcha-sdk-not-linked). | Apple
`recaptcha-site-key-missing` | The reCAPTCHA site key could not be found. | Apple
`recaptcha-action-creation-failed` | The reCAPTCHA action could not be created. | Apple
`missing-recaptcha-token` | The request to the backend is missing a reCAPTCHA token. | Android, Web
`invalid-recaptcha-token` | The reCAPTCHA token sent to the backend is invalid. | Android, Web
`missing-recaptcha-version` | The request to the backend is missing the reCAPTCHA version. | Android, Web
`invalid-recaptcha-version` | The reCAPTCHA version sent to the backend is invalid. | Android, Web
`invalid-recaptcha-action` | The reCAPTCHA action sent to the backend is invalid. | Android, Web
`missing-client-type` | The request to the backend is missing the reCAPTCHA client type. | Android, Web
`invalid-req-type` | The request is invalid (missing or malformed parameters). | Android, Web

### Multi-factor authentication

Code | Description | Platforms
-----|-------------|----------
`second-factor-required` | The user must complete a second-factor challenge. Thrown as a `FirebaseAuthMultiFactorException`. | Android, Apple
`multi-factor-auth-required` | Web equivalent of `second-factor-required`. Thrown as a `FirebaseAuthMultiFactorException`. | Web
`invalid-multi-factor-session` | The request does not contain a valid proof of first-factor sign-in. | Android, Apple, Web
`missing-multi-factor-session` | The request is missing proof of first-factor sign-in. | Android, Apple, Web
`missing-multi-factor-info` | No second-factor identifier was provided. | Android, Apple, Web
`multi-factor-info-not-found` | The user has no second factor matching the identifier. | Android, Apple, Web
`second-factor-already-enrolled` | This second factor is already enrolled on the account. | Android
`second-factor-already-in-use` | Web equivalent of `second-factor-already-enrolled`. | Web
`maximum-second-factor-count-exceeded` | The maximum number of second factors for a user has been reached. | Android, Web
`unsupported-first-factor` | Enrolling or signing in with a second factor requires a supported first factor (such as email/password). | Android, Apple, Web
`enroll-failed` | Enrolling the second factor failed. Check `message` for the underlying error. | Apple
`unenroll-failed` | Unenrolling the second factor failed. Check `message` for the underlying error. | Apple
`resolve-signin-failed` | Resolving the multi-factor sign-in failed. Check `message` for the underlying error. | Apple
`generate-secret-failed` | Generating the TOTP secret failed. Check `message` for the underlying error. | Apple

### Web sign-in flows (popup, redirect, in-app browser)

Code | Description | Platforms
-----|-------------|----------
`popup-blocked` | The popup was blocked by the browser. | Web
`popup-closed-by-user` | The user closed the popup before completing sign-in. | Web
`cancelled-popup-request` | The popup request was cancelled because another popup was opened. | Web
`redirect-cancelled-by-user` | The user cancelled the redirect before completing sign-in. | Web
`unauthorized-domain` | The domain is not authorized. On web, the app's domain is not authorized for OAuth sign-in. On Android and Apple platforms, the domain of the continue URL in `ActionCodeSettings` is not authorized. Add the domain to the authorized domains in the Firebase console. | Android, Apple, Web
`web-context-already-presented` | A sign-in web view is already being presented. | Android
`web-context-canceled` | The user cancelled the sign-in web view (Android spelling). | Android
`web-context-cancelled` | The user cancelled the sign-in web view (Apple spelling). | Apple
`web-internal-error` | An internal error occurred in the sign-in web view. | Android, Apple
`web-network-request-failed` | A network error occurred in the sign-in web view. | Apple
`web-user-interaction-failure` | The sign-in web view failed. | Apple
`invalid-auth-event` | An internal error occurred in the web sign-in flow. | Web
`no-auth-event` | An internal error occurred in the web sign-in flow. | Web

### Sign in with Apple and Game Center

Code | Description | Platforms
-----|-------------|----------
`canceled` | The user cancelled Sign in with Apple. | Apple
`invalid-response` | Sign in with Apple returned an invalid response. | Apple
`not-handled` | The Sign in with Apple request was not handled. | Apple
`failed` | The Sign in with Apple request failed. | Apple
`sign-in-failure` | `signInWithProvider` was called with the Game Center provider. Use `GameCenterAuthProvider.credential()` with `signInWithCredential` instead. | Apple
`provider-link-failure` | `linkWithProvider` was called with the Game Center provider. Use `GameCenterAuthProvider.credential()` with `linkWithCredential` instead. | Apple
`local-player-not-authenticated` | The local Game Center player is not authenticated. | Apple
`game-kit-not-linked` | GameKit is not linked in the app. | Apple

### Multi-tenancy

Code | Description | Platforms
-----|-------------|----------
`invalid-tenant-id` | The tenant ID set on the Auth instance is invalid. | Android, Web
`tenant-id-mismatch` | The tenant ID of the credential does not match the Auth instance's tenant ID. | Android, Apple, Web
`unsupported-tenant-operation` | The operation is not supported in a multi-tenant context. | Android, Apple, Web

