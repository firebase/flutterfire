Project: /docs/_project.yaml
Book: /docs/_book.yaml

<link rel="stylesheet" type="text/css" href="/styles/docs.css" />

# Authenticate with Firebase Using Email Links

You can use Firebase Authentication to sign in a user by sending them an email
containing a link, which they can click to sign in. In the process, the user's
email address is also verified.

There are numerous benefits to signing in by email:

* Low friction sign-up and sign-in.
* Lower risk of password reuse across applications, which can undermine security
  of even well-selected passwords.
* The ability to authenticate a user while also verifying that the user is the
  legitimate owner of an email address.
* A user only needs an accessible email account to sign in. No ownership of a
  phone number or social media account is required.
* A user can sign in securely without the need to provide (or remember) a
  password, which can be cumbersome on a mobile device.
* An existing user who previously signed in with an email identifier (password
  or federated) can be upgraded to sign in with just the email. For example, a
  user who has forgotten their password can still sign in without needing to
  reset their password.


## Before you begin

1.  If you haven't already, follow the steps in the [Get started](start) guide.

1.  Enable Email Link sign-in for your Firebase project.

    To sign in users by email link, you must first enable the Email provider
    and Email link sign-in method for your Firebase project:

    1.  In the [Firebase console](https://console.firebase.google.com/), open the **Auth** section.
    1.  On the **Sign in method** tab, enable the **Email/Password** provider.
        Note that email/password sign-in must be enabled to use email link
        sign-in.
    1.  In the same section, enable **Email link (passwordless sign-in)**
        sign-in method.
    1.  Click **Save**.


## Send an authentication link to the user's email address

To initiate the authentication flow, present an interface that prompts the user to provide their email address and then call `sendSignInLinkToEmail()` to request that Firebase send the authentication link to the user's email.

1.  Construct the ActionCodeSettings object, which provides Firebase with instructions on how to construct the email link. Set the following fields:

    * `url`: The deep link to embed and any additional state to be passed along. The link's domain has to be whitelisted in the Firebase Console list of authorized domains, which can be found by going to the Sign-in method tab (Authentication -> Sign-in method). The link will redirect the user to this URL if the app is not installed on their device and the app was not able to be installed.

    * `androidPackageName` and `IOSBundleId`: The apps to use when the sign-in link is opened on an Android or iOS device. Learn more on how to configure Firebase Dynamic Links to open email action links via mobile apps.

    * `handleCodeInApp`: Set to `true`. The sign-in operation has to always be completed in the app unlike other out of band email actions (password reset and email verifications). This is because, at the end of the flow, the user is expected to be signed in and their Auth state persisted within the app.

    * `dynamicLinkDomain`: When multiple custom dynamic link domains are defined for a project, specify which one to use when the link is to be opened via a specified mobile app (for example, `example.page.link`). Otherwise the first domain is automatically selected.

    ```dart
    var acs = ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        url: 'https://www.example.com/finishSignUp?cartId=1234',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.android',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '12');
    ```

1.  Ask the user for their email.

1.  Send the authentication link to the user's email, and save the user's email in case the user completes the email sign-in on the same device.

    ```dart
    var emailAuth = 'someemail@domain.com';
    FirebaseAuth.instance.sendSignInLinkToEmail(
            email: emailAuth, actionCodeSettings: acs)
        .catchError((onError) => print('Error sending email verification $onError'))
        .then((value) => print('Successfully sent email verification'));
    });
    ```


## Complete sign in with the email link

### Security concerns


To prevent a sign-in link from being used to sign in as an unintended user or on
an unintended device, Firebase Auth requires the user's email address to be
provided when completing the sign-in flow. For sign-in to succeed, this email
address must match the address to which the sign-in link was originally sent.

You can streamline this flow for users who open the sign-in link on the same
device they request the link, by storing their email address locally - for
instance using SharedPreferences - when you send the sign-in email. Then,
use this address to complete the flow.
Do not pass the user's email in the redirect URL parameters and re-use it as
this may enable session injections.

After sign-in completion, any previous unverified mechanism of sign-in will be
removed from the user and any existing sessions will be invalidated.
For example, if someone previously created an unverified account with the same
email and password, the user's password will be removed to prevent the
impersonator who claimed ownership and created that unverified account from
signing in again with the unverified email and password.

Also make sure you use an HTTPS URL in production to avoid your link being
potentially intercepted by intermediary servers.

### Verify email link and sign in

Firebase Authentication uses Firebase Dynamic Links to send the email link to a mobile device. For sign-in completion via mobile application, the application has to be configured to detect the incoming application link, parse the underlying deep link and then complete the sign-in.

1.  Set up your app to receive Dynamic Links on Flutter in the [guide](docs/dynamic-links/flutter/receive).

1.  In your link handler, check if the link is meant for email link authentication and, if so, complete the sign-in process.

    ```dart
    // Confirm the link is a sign-in with email link.
    if (FirebaseAuth.instance.isSignInWithEmailLink(emailLink)) {
      try {
        // The client SDK will parse the code from the link for you.
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailLink(email: emailAuth, emailLink: emailLink);

        // You can access the new user via userCredential.user.
        final emailAddress = userCredential.user?.email;

        print('Successfully signed in with email link!');
      } catch (error) {
        print('Error signing in with email link.');
      }
    }
    ```

### Linking/re-authentication with email link

You can also link this method of authentication to an existing user. For example
a user previously authenticated with another provider, such as a phone number,
can add this method of sign-in to their existing account.

The difference would be in the second half of the operation:

```dart
final authCredential = EmailAuthProvider
    .credentialWithLink(email: emailAuth, emailLink: emailLink.toString());
try {
    await FirebaseAuth.instance.currentUser
        ?.linkWithCredential(authCredential);
} catch (error) {
    print("Error linking emailLink credential.");
}
```

This can also be used to re-authenticate an email link user before running a
sensitive operation.

```dart
final authCredential = EmailAuthProvider
    .credentialWithLink(email: emailAuth, emailLink: emailLink.toString());
try {
    await FirebaseAuth.instance.currentUser
        ?.reauthenticateWithCredential(authCredential);
} catch (error) {
    print("Error reauthenticating credential.");
}
```

However, as the flow could end up on a different device where the original user
was not logged in, this flow might not be completed. In that case, an error can
be shown to the user to force them to open the link on the same device. Some
state can be passed in the link to provide information on the type of operation
and the user uid.


## Differentiating email/password from email link

In case you support both password and link-based sign in with email, to
differentiate the method of sign in for a password/link user, use
`fetchSignInMethodsForEmail`. This is useful for identifier-first flows where
the user is first asked to provide their email and then presented with the
method of sign-in:

```dart
try {
    final signInMethods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAuth);
    final userExists = signInMethods.isNotEmpty;
    final canSignInWithLink = signInMethods
        .contains(EmailAuthProvider.EMAIL_LINK_SIGN_IN_METHOD);
    final canSignInWithPassword = signInMethods
        .contains(EmailAuthProvider.EMAIL_PASSWORD_SIGN_IN_METHOD);
} on FirebaseAuthException catch (exception) {
    switch (exception.code) {
        case "invalid-email":
            print("Not a valid email address.");
            break;
        default:
            print("Unknown error.");
    }
}
```

As described above email/password and email/link are considered the same
`EmailAuthProvider` (same `PROVIDER_ID`) with different methods of
sign-in.


## Next steps

After a user creates a new account, this account is stored as part of your
Firebase project, and can be used to identify a user across every app in your
project, regardless of what sign-in method the user used.

In your apps, you can get the user's basic profile information from the
`User` object. See [Manage Users](manage-users).

In your Firebase Realtime Database and Cloud Storage Security Rules, you can
get the signed-in user's unique user ID from the `auth` variable, and use it to
control what data a user can access.

You can allow users to sign in to your app using multiple authentication
providers by [linking auth provider credentials](account-linking)) to an
existing user account.

To sign out a user, call `signOut()`:

```dart
await FirebaseAuth.instance.signOut();
```
