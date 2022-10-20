Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Add multi-factor authentication to your Flutter app

If you've upgraded to Firebase Authentication with Identity Platform,
 you can add SMS multi-factor authentication to your Flutter app.

Multi-factor authentication (MFA) increases the security of your app. While attackers
often compromise passwords and social accounts, intercepting a text message is
more difficult.

## Before you begin

Note: Using multi-factor authentication with
[multiple tenants](https://cloud.google.com/identity-platform/docs/multi-tenancy)
is not supported on Flutter.

1.  Enable at least one provider that supports multi-factor authentication.
    Every provider supports MFA, **except** phone auth, anonymous auth, and
    Apple Game Center.

1.  Ensure your app is verifying user emails. MFA requires email verification.
    This prevents malicious actors from registering for a service with an email
    they don't own, and then locking out the real owner by adding a second
    factor.

1. **Android**: If you haven't already set your app's SHA-256 hash in the
 [Firebase console](https://console.firebase.google.com/), do so.
 See [Authenticating Your Client](https://developers.google.com/android/guides/client-auth)
  for information about finding your app's SHA-256 hash.
1. **iOS**: In Xcode, [enable push notifications](http://help.apple.com/xcode/mac/current/#/devdfd3d04a1) for your project & ensure
   your APNs authentication key is [configured with Firebase Cloud Messaging (FCM)](/docs/cloud-messaging/ios/certs).
   To view an in-depth explanation of this step, view the [Firebase iOS Phone Auth](/docs/auth/ios/phone-auth) documentation.
1. **Web**: Ensure that you have added your applications domain on the [Firebase console](https://console.firebase.google.com/), under
   **OAuth redirect domains**.

## Enabling multi-factor authentication

1.  Open the [**Authentication > Sign-in method**](https://console.firebase.google.com/project/_/authentication/providers)
    page of the Firebase console.

1.  In the **Advanced** section, enable **SMS Multi-factor Authentication**.

    You should also enter the phone numbers you'll be testing your app with.
    While optional, registering test phone numbers is strongly recommended to
    avoid throttling during development.

1.  If you haven't already authorized your app's domain, add it to the allow
    list on the [**Authentication > Settings**](https://console.firebase.google.com/project/_/authentication/settings)
    page of the Firebase console.

## Choosing an enrollment pattern

You can choose whether your app requires multi-factor authentication, and how
and when to enroll your users. Some common patterns include:

* Enroll the user's second factor as part of registration. Use this
  method if your app requires multi-factor authentication for all users.

* Offer a skippable option to enroll a second factor during registration. Apps
  that want to encourage, but not require, multi-factor authentication might
  prefer this approach.

* Provide the ability to add a second factor from the user's account or profile
  management page, instead of the sign up screen. This minimizes friction during
  the registration process, while still making multi-factor authentication
  available for security-sensitive users.

* Require adding a second factor incrementally when the user wants to access
  features with increased security requirements.

## Enrolling a second factor

To enroll a new secondary factor for a user:

1.  Re-authenticate the user.

1.  Ask the user enter their phone number.

    Note: Google stores and uses phone numbers to improve spam and abuse
    prevention across all Google services. Ensure you obtain appropriate consent
    from your users before sending their phone numbers to
    Firebase.

1.  Get a multi-factor session for the user:

  ```dart
  final multiFactorSession = await user.multiFactor.getSession();
  ```


1.  Verify the phone number with a multi factor session and your callbacks:

  ```dart
  await FirebaseAuth.instance.verifyPhoneNumber(
    multiFactorSession: multiFactorSession,
    phoneNumber: phoneNumber,
    verificationCompleted: (_) {},
    verificationFailed: (_) {},
    codeSent: (String verificationId, int? resendToken) async {
      // The SMS verification code has been sent to the provided phone number.
      // ...
    },
    codeAutoRetrievalTimeout: (_) {},
  ); 
  ```

1. Once the SMS code is sent, ask the user to verify the code:

  ```dart
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );
  ```

1. Complete the enrollment:

  ```dart
  await user.multiFactor.enroll(
    PhoneMultiFactorGenerator.getAssertion(
      credential,
    ),
  );
  ```

The code below shows a complete example of enrolling a second factor:

  ```dart
  final session = await user.multiFactor.getSession();
  final auth = FirebaseAuth.instance;
  await auth.verifyPhoneNumber(
    multiFactorSession: session,
    phoneNumber: phoneController.text,
    verificationCompleted: (_) {},
    verificationFailed: (_) {},
    codeSent: (String verificationId, int? resendToken) async {
      // See `firebase_auth` example app for a method of retrieving user's sms code: 
      // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
      final smsCode = await getSmsCodeFromUser(context);

      if (smsCode != null) {
        // Create a PhoneAuthCredential with the code
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        try {
          await user.multiFactor.enroll(
            PhoneMultiFactorGenerator.getAssertion(
              credential,
            ),
          );
        } on FirebaseAuthException catch (e) {
          print(e.message);
        }
      }
    },
    codeAutoRetrievalTimeout: (_) {},
  );
  ```

Congratulations! You successfully registered a second authentication factor for
a user.

Important: You should strongly encourage your users to register more than one
second factor for account recovery purposes. If a user only registers a single
second factor and later loses access to it, they will be locked out of their
account.

## Signing users in with a second factor

To sign in a user with two-factor SMS verification:

1.  Sign the user in with their first factor, then catch the
    `FirebaseAuthMultiFactorException` exception. This error contains a
    resolver, which you can use to obtain the user's enrolled second factors.
    It also contains an underlying session proving the user successfully
    authenticated with their first factor.

    For example, if the user's first factor was an email and password:

    ```dart
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
      );
      // User is not enrolled with a second factor and is successfully
      // signed in.
      // ...
    } on FirebaseAuthMultiFactorException catch (e) {
      // The user is a multi-factor user. Second factor challenge is required
      final resolver = e.resolver
      // ...
    }
    ```

1.  If the user has multiple secondary factors enrolled, ask them which one
    to use:

    ```dart
    final session = e.resolver.session;

    final hint = e.resolver.hints[selectedHint];
    ```

1.  Send a verification message to the user's phone with the hint and
  multi-factor session:

    ```dart
    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: session,
      multiFactorInfo: hint,
      verificationCompleted: (_) {},
      verificationFailed: (_) {},
      codeSent: (String verificationId, int? resendToken) async {
        // ...
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    ```

1.  Call `resolver.resolveSignIn()` to complete secondary authentication:

    ```dart
    final smsCode = await getSmsCodeFromUser(context);
    if (smsCode != null) {
      // Create a PhoneAuthCredential with the code
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      try {
        await e.resolver.resolveSignIn(
          PhoneMultiFactorGenerator.getAssertion(credential)
        );
      } on FirebaseAuthException catch (e) {
        print(e.message);
      }
    }
    ```

The code below shows a complete example of signing in a multi-factor user:

```dart
try {
  await _auth.signInWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text,
  );
} on FirebaseAuthMultiFactorException catch (e) {
  setState(() {
    error = '${e.message}';
  });
  final firstHint = e.resolver.hints.first;
  if (firstHint is! PhoneMultiFactorInfo) {
    return;
  }
  await FirebaseAuth.instance.verifyPhoneNumber(
    multiFactorSession: e.resolver.session,
    multiFactorInfo: firstHint,
    verificationCompleted: (_) {},
    verificationFailed: (_) {},
    codeSent: (String verificationId, int? resendToken) async {
      // See `firebase_auth` example app for a method of retrieving user's sms code: 
      // https://github.com/firebase/flutterfire/blob/master/packages/firebase_auth/firebase_auth/example/lib/auth.dart#L591
      final smsCode = await getSmsCodeFromUser(context);

      if (smsCode != null) {
        // Create a PhoneAuthCredential with the code
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );

        try {
          await e.resolver.resolveSignIn(
            PhoneMultiFactorGenerator.getAssertion(
              credential,
            ),
          );
        } on FirebaseAuthException catch (e) {
          print(e.message);
        }
      }
    },
    codeAutoRetrievalTimeout: (_) {},
  );
} catch (e) {
  ...
} 
```

Congratulations! You successfully signed in a user using multi-factor
authentication.

## What's next

* [Manage multi-factor users](/docs/auth/admin/manage-mfa-users)
  programmatically with the Admin SDK.
