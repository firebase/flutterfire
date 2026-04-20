Project: /docs/\_project.yaml
Book: /docs/\_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Error Handling

The Firebase Authentication SDKs provide a simple way for catching the various errors which may occur which using
authentication methods. The SDKs for Flutter expose these errors via the `FirebaseAuthException`
class.

At a minimum, a `code` and `message` are provided, however in some cases additional properties such as an email address
and credential are also provided. For example, if the user is attempting to sign in with an email and password,
any errors thrown can be explicitly caught:

```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: "barry.allen@example.com",
    password: "SuperSecretPassword!"
  );
} on FirebaseAuthException catch  (e) {
  print('Failed with error code: ${e.code}');
  print(e.message);
}
```

Each method provides various error codes and messages depending on the type of authentication invocation type. The
[Reference API](https://pub.dev/documentation/firebase_auth/latest/) provides up-to-date details on the errors for each method.

Other errors such as `too-many-requests` or `operation-not-allowed` may be thrown if you reach the Firebase Authentication quota,
or have not enabled a specific auth provider.

## Handling `account-exists-with-different-credential` Errors

If you enabled the One account per email address setting in the [Firebase console](https://console.firebase.google.com/project/_/authentication/providers),
when a user tries to sign in a to a provider (such as Google) with an email that already exists for another Firebase user's provider
(such as Facebook), the error `auth/account-exists-with-different-credential` is thrown along with an `AuthCredential` class (Google ID token).
To complete the sign-in flow to the intended provider, the user has to first sign in to the existing provider (e.g. Facebook) and then link to the former
`AuthCredential` (Google ID token).

```dart
FirebaseAuth auth = FirebaseAuth.instance;

// Create a credential from a Google Sign-in Request
var googleAuthCredential = GoogleAuthProvider.credential(accessToken: 'xxxx');

try {
  // Attempt to sign in the user in with Google
  await auth.signInWithCredential(googleAuthCredential);
} on FirebaseAuthException catch (e) {
  if (e.code == 'account-exists-with-different-credential') {
    // The account already exists with a different credential
    String email = e.email!;
    AuthCredential pendingCredential = e.credential!;

    // Note: fetchSignInMethodsForEmail() is deprecated.
    // Instead, attempt sign-in directly with known providers
    // and handle the linking flow accordingly.

    // Try signing in with email/password if applicable
    try {
      String password = '...';
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Link the pending credential with the existing account
      await userCredential.user!.linkWithCredential(pendingCredential);
      // Success! Go back to your application flow
      return goToApplication();
    } on FirebaseAuthException catch (_) {
      // Email/password sign-in failed, try another provider
    }

    // Try signing in with Facebook if applicable
    String accessToken = await triggerFacebookAuthentication();
    var facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken);

    UserCredential userCredential =
        await auth.signInWithCredential(facebookAuthCredential);

    // Link the pending credential with the existing account
    await userCredential.user!.linkWithCredential(pendingCredential);

    // Success! Go back to your application flow
    return goToApplication();
  }
}
```

## `recaptcha-sdk-not-linked` (iOS phone auth)

If `e.code` is **`recaptcha-sdk-not-linked`** during **`verifyPhoneNumber`** on **iOS**, the native layer expects **reCAPTCHA Enterprise**
to be linked or your **Identity Platform** project configuration must be adjusted. This is not fixed from Dart alone.

See [Phone Authentication — iOS: reCAPTCHA SDK and Identity Platform](/docs/auth/phone-auth#ios-recaptcha-sdk-and-identity-platform) for
recommended setup, the Safari flow, and a documented **GCP / Identity Toolkit** workaround with trade-offs.
