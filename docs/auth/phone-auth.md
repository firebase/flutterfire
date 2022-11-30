Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Phone Authentication

Phone authentication allows users to sign in to Firebase using their phone as the authenticator. An SMS message is sent
to the user (using the provided phone number) containing a unique code. Once the code has been authorized, the user is able to sign
into Firebase.

> Phone numbers that end users provide for authentication will be sent and stored by Google to improve spam and abuse
> prevention across Google service, including to, but not limited to Firebase. Developers should ensure they have the
> appropriate end-user consent prior to using the Firebase Authentication phone number sign-in service.authentication

Firebase Phone Authentication is not supported in all countries. Please see their [FAQs](/support/faq/#develop) for more information.

## Setup

Before starting with Phone Authentication, ensure you have followed these steps:

1. Enable Phone as a Sign-In method in the [Firebase console](https://console.firebase.google.com/u/0/project/_/authentication/providers).
2. **Android**: If you haven't already set your app's SHA-1 hash in the [Firebase console](https://console.firebase.google.com/), do so.
   See [Authenticating Your Client](https://developers.google.com/android/guides/client-auth) for information about finding your app's SHA-1 hash.
3. **iOS**: In Xcode, [enable push notifications](http://help.apple.com/xcode/mac/current/#/devdfd3d04a1) for your project & ensure
   your APNs authentication key is [configured with Firebase Cloud Messaging (FCM)](/docs/cloud-messaging/ios/certs).
   To view an in-depth explanation of this step, view the [Firebase iOS Phone Auth](/docs/auth/ios/phone-auth) documentation.
4. **Web**: Ensure that you have added your applications domain on the [Firebase console](https://console.firebase.google.com/), under
   **OAuth redirect domains**.

**Note**; Phone number sign-in is only available for use on real devices and the web. To test your authentication flow on device emulators,
please see [Testing](#testing).

## Usage

The Firebase Authentication SDK for Flutter provides two individual ways to sign a user in with their phone number. Native (e.g. Android & iOS) platforms provide
different functionality to validating a phone number than the web, therefore two methods exist for each platform exclusively:

- **Native Platform**: `verifyPhoneNumber`.
- **Web Platform**: `signInWithPhoneNumber`.

### Native: `verifyPhoneNumber`

On native platforms, the user's phone number must be first verified and then the user can either sign-in or link their account with a
`PhoneAuthCredential`.

First you must prompt the user for their phone number. Once provided, call the `verifyPhoneNumber()` method:

```dart
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+44 7123 123 456',
  verificationCompleted: (PhoneAuthCredential credential) {},
  verificationFailed: (FirebaseAuthException e) {},
  codeSent: (String verificationId, int? resendToken) {},
  codeAutoRetrievalTimeout: (String verificationId) {},
);
```

Note: Depending on your billing plan, you might be limited to a daily quota of
SMS messages sent. See [Firebase Auth Limits](/docs/auth/limits#phone-auth).

There are 4 separate callbacks that you must handle, each will determine how you update the application UI:

1. **[verificationCompleted](#verificationCompleted)**: Automatic handling of the SMS code on Android devices.
2. **[verificationFailed](#verificationFailed)**: Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
3. **[codeSent](#codeSent)**: Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
4. **[codeAutoRetrievalTimeout](#codeAutoRetrievalTimeout)**: Handle a timeout of when automatic SMS code handling fails.

#### verificationCompleted

This handler will only be called on Android devices which support automatic SMS code resolution.

When the SMS code is delivered to the device, Android will automatically verify the SMS code without
requiring the user to manually input the code. If this event occurs, a `PhoneAuthCredential` is automatically provided which can be
used to sign-in with or link the user's phone number.

```dart
FirebaseAuth auth = FirebaseAuth.instance;

await auth.verifyPhoneNumber(
  phoneNumber: '+44 7123 123 456',
  verificationCompleted: (PhoneAuthCredential credential) async {
    // ANDROID ONLY!

    // Sign the user in (or link) with the auto-generated credential
    await auth.signInWithCredential(credential);
  },
);
```

#### verificationFailed

If Firebase returns an error, for example for an incorrect phone number or if the SMS quota for the project has exceeded,
a `FirebaseAuthException` will be sent to this handler. In this case, you would prompt your user something went wrong depending on the error
code.

```dart
FirebaseAuth auth = FirebaseAuth.instance;

await auth.verifyPhoneNumber(
  phoneNumber: '+44 7123 123 456',
  verificationFailed: (FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      print('The provided phone number is not valid.');
    }

    // Handle other errors
  },
);
```

#### codeSent

When Firebase sends an SMS code to the device, this handler is triggered with a `verificationId` and `resendToken` (A `resendToken`
is only supported on Android devices, iOS devices will _always_ return a `null` value).

Once triggered, it would be a good time to update your application UI to prompt the user to enter the SMS code they're expecting.
Once the SMS code has been entered, you can combine the verification ID with the SMS code to create a new `PhoneAuthCredential`:

```dart
FirebaseAuth auth = FirebaseAuth.instance;

await auth.verifyPhoneNumber(
  phoneNumber: '+44 7123 123 456',
  codeSent: (String verificationId, int? resendToken) async {
    // Update the UI - wait for the user to enter the SMS code
    String smsCode = 'xxxx';

    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

    // Sign the user in (or link) with the credential
    await auth.signInWithCredential(credential);
  },
);
```

By default, Firebase will not re-send a new SMS message if it has been recently sent. You can however override this behavior
by re-calling the `verifyPhoneNumber` method with the resend token to the `forceResendingToken` argument.
If successful, the SMS message will be resent.

#### codeAutoRetrievalTimeout

On Android devices which support automatic SMS code resolution, this handler will be called if the device has not automatically
resolved an SMS message within a certain timeframe. Once the timeframe has passed, the device will no longer attempt to resolve
any incoming messages.

By default, the device waits for 30 seconds however this can be customized with the `timeout` argument:

```dart
FirebaseAuth auth = FirebaseAuth.instance;

await auth.verifyPhoneNumber(
  phoneNumber: '+44 7123 123 456',
  timeout: const Duration(seconds: 60),
  codeAutoRetrievalTimeout: (String verificationId) {
    // Auto-resolution timed out...
  },
);
```

### Web: `signInWithPhoneNumber`

On web platforms, users can sign-in by confirming they have access to a phone by entering the SMS code sent to the provided phone number.
For added security and spam prevention, users are requested to prove they are human by completing a [Google reCAPTCHA](https://www.google.com/recaptcha/about/)
widget. Once confirmed, the SMS code will be sent.

The Firebase Authentication SDK for Flutter will manage the reCAPTCHA widget out of the box by default, however provides control over how it is displayed and configured if required.
To get started, call the `signInWithPhoneNumber` method with the phone number.

```dart
FirebaseAuth auth = FirebaseAuth.instance;

// Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber('+44 7123 123 456');
```

Calling the method will first trigger the reCAPTCHA widget to display. The user must complete the
test before an SMS code is sent. Once complete, you can then sign the user in by providing the
SMS code to the `confirm` method on the resolved `ConfirmationResult` response:

```dart
UserCredential userCredential = await confirmationResult.confirm('123456');
```

Like other sign-in flows, a successful sign-in will trigger any authentication state listeners
you have subscribed throughout your application.

#### reCAPTCHA Configuration

The reCAPTCHA widget is a fully managed flow which provides security to your web application.

The second argument of `signInWithPhoneNumber` accepts an optional `RecaptchaVerifier` instance which can be used
to manage the widget. By default, the widget will render as an invisible widget when the sign-in flow is triggered.
An "invisible" widget will appear as a full-page modal on-top of your application.

It is however possible to display an inline widget which the user has to explicitly press to verify themselves.

To add an inline widget, specify a DOM element ID to the `container` argument of the `RecaptchaVerifier` instance.
The element must exist and be empty otherwise an error will be thrown.
If no `container` argument is provided, the widget will be rendered as "invisible".

```dart
ConfirmationResult confirmationResult = await auth.signInWithPhoneNumber('+44 7123 123 456', RecaptchaVerifier(
  container: 'recaptcha',
  size: RecaptchaVerifierSize.compact,
  theme: RecaptchaVerifierTheme.dark,
));
```

You can optionally change the size and theme by customizing the `size` and `theme` arguments as shown above.

It is also possible to listen to events, such as whether the reCAPTCHA has been completed by the user, whether
the reCAPTCHA has expired or an error was thrown:

```dart
RecaptchaVerifier(
  onSuccess: () => print('reCAPTCHA Completed!'),
  onError: (FirebaseAuthException error) => print(error),
  onExpired: () => print('reCAPTCHA Expired!'),
);
```

## Testing

Firebase provides support for locally testing phone numbers:

1. On the Firebase Console, select the "Phone" authentication provider and click on the "Phone numbers for testing" dropdown.
2. Enter a new phone number (e.g. `+44 7444 555666`) and a test code (e.g. `123456`).

If providing a test phone number to either the `verifyPhoneNumber` or `signInWithPhoneNumber` methods, no SMS will actually be sent. You
can instead provide the test code directly to the `PhoneAuthProvider` or with `signInWithPhoneNumber`s confirmation result handler.
